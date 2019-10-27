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
    var offers: [OfferModel]?
    var searchConditions: [String:Any]?
    var locationManager: CLLocationManager!
    let offersDb = Firestore.firestore().collection("offers")
    let Usersdb = Firestore.firestore().collection("Users")

    @IBOutlet weak var targetLanguage: UILabel!
    @IBOutlet weak var numOfOnline: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var MapView: MKMapView!

    override func viewDidLoad() {
//        var config = Realm.Configuration()
//        config.deleteRealmIfMigrationNeeded = true
//        let realm = try! Realm(configuration: config)
        super.viewDidLoad()
        setupLocationManager()
        self.MapView.region.span.latitudeDelta = 120
        self.MapView.region.span.longitudeDelta = 120
        self.MapView.isZoomEnabled = false
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
        print(self.getUserData().lastLoginBonus.timeIntervalSinceNow)
        if -self.getUserData().lastLoginBonus.timeIntervalSinceNow > 60*60*24 {
            self.Usersdb.whereField("uid", isEqualTo: getUserUid()).getDocuments() { snapshot, error in
                if let _error = error {
                    self.showError(_error)
                    return
                }
                guard let documents = snapshot?.documents else {
                return
                }
                let downloadedUserData = documents.map{ UserModel(from: $0) }
                self.Usersdb.document(self.getUserUid()).setData([
                    "point" : downloadedUserData[0].point+5
                ], merge: true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
        let targetLanguage = self.getUserData().secondLanguage
        self.targetLanguage.text = Language.strings[targetLanguage]
        self.offersDb.whereField("targetLanguage", isEqualTo: targetLanguage).whereField("isOnline", isEqualTo: true).addSnapshotListener() { snapshot, error in
             if let _error = error {
                 print("error\(_error)")
                 return
             }
             guard let documents = snapshot?.documents else {
             print("error")
                return
            }
             self.offers = documents.map{ OfferModel(from: $0) }
            self.numOfOnline.text = String(self.offers!.count)
            self.MapView.removeAnnotations(self.MapView.annotations)
            for offer in self.offers! {
                print(offer.nativeLocation)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(offer.nativeLocation.latitude, offer.nativeLocation.longitude)
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
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
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
            //print(city + ", " + country)
        }
    }

    func fetchCityAndCountry(location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality, placemarks?.first?.country, error)
        }
    }
}

