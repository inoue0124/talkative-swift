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
import SCLAlertView

class SearchViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var offers: [OfferModel]?
    var searchConditions: [String:Any]?
    var locationManager: CLLocationManager!
    let offersDb = Firestore.firestore().collection("offers")
    let Usersdb = Firestore.firestore().collection("Users")
    let loginBonus: Double = 5.0
    var myLocation: CLLocation?
    var window: UIWindow?
    var offerPrice: Int = 10

    @IBOutlet weak var targetLanguage: UILabel!
    @IBOutlet weak var numOfOnline: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var instructionLabel: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeStepper: UIStepper!

    @IBAction func changeStepperValue(_ sender: UIStepper) {
        timeLabel.text = "\(Int(sender.value))"
        offerPrice = Int(sender.value)
    }

    override func viewDidLoad() {
        setupLocationManager()
        self.MapView.region.span.latitudeDelta = 120
        self.MapView.region.span.longitudeDelta = 120
        //self.MapView.isZoomEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
        timeStepper.value = Double(offerPrice)
        self.instructionLabel.center.y = -65
        UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
            self.instructionLabel.center.y = 65
        }, completion: nil)
        let pointHistoryDB = Usersdb.document(self.getUserUid()).collection("pointHistory")
        self.Usersdb.whereField("uid", isEqualTo: getUserUid()).getDocuments() { snapshot, error in
            if let _error = error {
                self.showError(_error)
                return
            }
            guard let documents = snapshot?.documents else {
            return
            }
            let downloadedUserData = documents.map{ UserModel(from: $0) }
            let realm = try! Realm()
            let UserData = realm.objects(RealmUserModel.self)
            if let UserData = UserData.first {
                try! realm.write {
                    UserData.ratingAsLearner = downloadedUserData[0].ratingAsLearner
                }
            }
            if -downloadedUserData[0].lastLoginBonus.timeIntervalSinceNow > 60*60*24 {
                self.Usersdb.document(self.getUserUid()).setData([
                    "point" : downloadedUserData[0].point+self.loginBonus,
                    "lastLoginBonus": FieldValue.serverTimestamp()
                ], merge: true)
                pointHistoryDB.document().setData([
                    "point": self.loginBonus,
                    "method": Method.Bonus.rawValue,
                    "createdAt": FieldValue.serverTimestamp()
                ], merge: true)
                SCLAlertView().showSuccess(self.LString("Login bonus!"), subTitle: String(format: self.LString("Got %.1f points!"), self.loginBonus))
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.instructionLabel.center.y = -65
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
        self.offersDb.whereField("targetLanguage", isEqualTo: targetLanguage).whereField("isOnline", isEqualTo: true).getDocuments() { snapshot, error in
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
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(offer.nativeLocation.latitude, offer.nativeLocation.longitude)
                self.MapView.addAnnotation(annotation)
            }
        }
    }

    @IBAction func presentConditions(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            user.reload()
            if self.myLocation == nil {
                self.setupLocationManager()
                //self.timeStepper.isEnabled = true
                return
            }
            if user.isEmailVerified {
                performSegue(withIdentifier: "showResult", sender: nil)
            } else {
                self.sendEmailVerification(to: user)
                SCLAlertView().showInfo(LString("Sent a verification Email"), subTitle: LString("Please verify your Email address"))
            }
        }
    }

    private func sendEmailVerification(to user: User) {
        Auth.auth().useAppLanguage()
        user.sendEmailVerification() { [weak self] error in
            guard let self = self else { return }
            if error != nil {
            }
            self.showError(error)
        }
    }

    func showSearchResult() {
        performSegue(withIdentifier: "showResult", sender: nil)
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            let ResultVC = segue.destination as! SearchResultViewController
            ResultVC.searchConditions = ["targetLanguage": getUserData().secondLanguage, "maxPrice": self.offerPrice]
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
        self.myLocation = locations.first
        self.Usersdb.document(self.getUserUid()).setData([
            "location": GeoPoint(latitude: self.myLocation!.coordinate.latitude, longitude: self.myLocation!.coordinate.longitude)
        ], merge: true)
    }
}

