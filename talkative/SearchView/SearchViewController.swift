//
//  FirstViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/08.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseAuth
import RealmSwift
import CoreLocation
import FirebaseFirestore
import MapKit

class SearchViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var natives: [UserModel]?
    var searchConditions: [String:Any]?
    var locationManager: CLLocationManager!
    let UsersDb = Firestore.firestore().collection("Users")

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var MapView: MKMapView!

    override func viewDidLoad() {
//        var config = Realm.Configuration()
//        config.deleteRealmIfMigrationNeeded = true
//        let realm = try! Realm(configuration: config)
//        do {
//            try Auth.auth().signOut()
//        } catch let error {
//            print(error)
//        }
        super.viewDidLoad()
        setupLocationManager()
        self.MapView.region.span.latitudeDelta = 120
        self.MapView.region.span.longitudeDelta = 120
        self.MapView.isZoomEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        self.UsersDb.whereField("isOnline", isEqualTo: true).addSnapshotListener() { snapshot, error in
             if let _error = error {
                 print("error\(_error)")
                 return
             }
             guard let documents = snapshot?.documents else {
             print("error")
                return
            }
             self.natives = documents.map{ UserModel(from: $0) }
            for native in self.natives! {
                print(native.location)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(native.location.latitude, native.location.longitude)
                self.MapView.addAnnotation(annotation)
            }
        }
    }

    @IBAction func presentConditions(_ sender: Any) {
        performSegue(withIdentifier: "presentConditions", sender: nil)
    }

    func showSearchResult() {
        performSegue(withIdentifier: "showResult", sender: nil)
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            let ResultVC = segue.destination as! SearchResultViewController
            ResultVC.searchConditions = self.searchConditions
        }
    }

    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()

        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        self.fetchCityAndCountry(location: location!) { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            print(city + ", " + country)
        }
    }

    func fetchCityAndCountry(location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality, placemarks?.first?.country, error)
        }
    }
}

