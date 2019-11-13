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
import Firebase
import FirebaseFirestore
import SkyWay
import CoreLocation
import MapKit
import SCLAlertView
import FirebaseMessaging

class teachSearchViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var learners: [UserModel]?
    var isOnline = false
    let offersDb = Firestore.firestore().collection("offers")
    let Usersdb = Firestore.firestore().collection("Users")
    let loginBonus: Double = 5.0
    var offerID: String?
    var peerID: String?
    var peer: SKWPeer?
    var mediaConnection: SKWMediaConnection?
    var offer: OfferModel?
    var locationManager: CLLocationManager!
    var myLocation: CLLocation?
    var window: UIWindow?
    var offerPrice: Int = 10
    var offerListener: ListenerRegistration?
    var incomingAlert: SCLAlertView?
    let chatroomsDb = Firestore.firestore().collection("chatrooms")
    var selectedChatroom: ChatroomModel?
    var avatarImage: UIImage?

    @IBOutlet weak var searchButton: UIImageView!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var numOfLearners: UILabel!
    @IBOutlet weak var targetLanguage: UILabel!
    @IBOutlet weak var instructionLabel: UIView!
    @IBOutlet weak var instructionLabel2: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeStepper: UIStepper!

    @IBAction func changeStepperValue(_ sender: UIStepper) {
        timeLabel.text = "\(Int(sender.value))"
        offerPrice = Int(sender.value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocationManager()
        self.MapView.region.span.latitudeDelta = 120
        self.MapView.region.span.longitudeDelta = 120
        //self.MapView.isZoomEnabled = false
    }

    @objc func applicationWillTerminate(_ notification: Notification?) {
        if let offerID = self.offerID {
            self.offersDb.document(offerID).setData(["isOnline" : false], merge: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
        self.targetLanguage.text = Language.strings[self.getUserData().motherLanguage]
        searchButton.isUserInteractionEnabled = true
        searchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(teachSearchViewController.searchButtonTapped(_:))))
        if isOnline {
            self.instructionLabel2.text = LString("Searching...")
            searchButton.image = UIImage.gif(name: "searchButton")
            searchButton.layer.cornerRadius = 50
            self.timeStepper.isEnabled = false
        } else {
            self.instructionLabel2.text = LString("Tap to start searching learners!")
            searchButton.image = UIImage(named: "gray")
            searchButton.layer.cornerRadius = 50
            self.timeStepper.isEnabled = true
        }
        self.Usersdb.whereField("secondLanguage", isEqualTo: self.getUserData().motherLanguage).whereField("isOnline", isEqualTo: true).getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.learners = documents.map{ UserModel(from: $0) }
            self.numOfLearners.text = String(self.learners!.count)
            self.MapView.removeAnnotations(self.MapView.annotations)
            for learner in self.learners! {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(learner.location.latitude, learner.location.longitude)
                self.MapView.addAnnotation(annotation)
            }
        }
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
                    UserData.ratingAsNative = downloadedUserData[0].ratingAsNative
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
                SCLAlertView().showSuccess(self.LString("Login bonus!"), subTitle: String(format: self.LString("Got %f points!"), self.loginBonus))
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.instructionLabel.center.y = -65
    }

    @objc func searchButtonTapped(_ sender: UITapGestureRecognizer) {
        self.offerListener?.remove()
        self.searchButton.image = UIImage.gif(name: "Preloader3")
        self.searchButton.isUserInteractionEnabled = false
        self.timeStepper.isEnabled = false
        if let user = Auth.auth().currentUser {
            user.reload()
            if self.myLocation == nil {
                self.setupLocationManager()
                self.searchButton.isUserInteractionEnabled = true
                self.timeStepper.isEnabled = true
                self.searchButton.image = UIImage(named: "gray")
                return
            }
            if user.isEmailVerified {
                self.isOnline.toggle()
                if self.isOnline {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                      granted, error in
                        
                    }
                    self.instructionLabel2.text = LString("Searching...")
                    self.offerID = self.offersDb.document().documentID
                    self.offersDb.document(self.offerID!).setData([
                        "offerID" : self.offerID!,
                        "nativeID" : self.getUserUid(),
                        "nativeName" : self.getUserData().name,
                        "nativeNationality" : self.getUserData().nationality,
                        "nativeMotherLanguage" : self.getUserData().motherLanguage,
                        "nativeRating" : self.getUserData().ratingAsNative,
                        "nativeImageURL" : self.getUserData().imageURL,
                        "nativeLocation" : GeoPoint(latitude: self.myLocation!.coordinate.latitude, longitude: self.myLocation!.coordinate.longitude),
                        "offerPrice" : self.offerPrice,
                        "offerTime" : self.offerPrice,
                        "targetLanguage" : self.getUserData().motherLanguage,
                        "supportLanguage" : self.getUserData().secondLanguage,
                        "nativeLevel": self.getUserData().level,
                        "isOnline": true,
                        "createdAt" : FieldValue.serverTimestamp(),
                        //"fcmToken" : UserDefaults.standard.string(forKey: "FCM_TOKEN")!
                    ], merge: true)
                    self.offerListener = self.offersDb.whereField("offerID", isEqualTo: self.offerID!).addSnapshotListener() { snapshot, error in
                        if let _error = error {
                            print("error\(_error)")
                            return
                        }
                        guard let documents = snapshot?.documents else {
                            print("error")
                            return
                        }
                        let offerData = documents.map{ OfferModel(from: $0) }
                        print(offerData[0].peerID)
                        if offerData[0].peerID != "" {
                            self.chatroomsDb.whereField("viewableUserIDs", arrayContains: self.getUserUid()).order(by: "updatedAt", descending: true).getDocuments() { (querySnapshot, err) in
                                if let _err = err {
                                    print("\(_err)")
                                } else if querySnapshot!.documents.isEmpty {
                                    print("chatroom is not exist")
                                    self.selectedChatroom = ChatroomModel(chatroomID: self.chatroomsDb.document().documentID, viewableUserIDs: [self.getUserUid(), offerData[0].learnerID])
                                } else {
                                    print("chatroom is exist")
                                    self.selectedChatroom = ChatroomModel(from: querySnapshot!.documents[0])
                                }
                                self.avatarImage = UIImage(url: offerData[0].learnerImageURL)
                                let appearance = SCLAlertView.SCLAppearance(
                                    showCloseButton: false,
                                    buttonsLayout: .horizontal
                                )
                                self.incomingAlert = SCLAlertView(appearance: appearance)
                                let subview = UIView(frame: CGRect(x: 0,y: 0,width: 230,height: 180))
                                let bundle = Bundle(for: type(of: self))
                                let nib = UINib(nibName: "incomingCallViewNib", bundle: bundle)
                                let nibview = nib.instantiate(withOwner: self, options: nil).first as! incomingCallViewNib
                                nibview.setData(offer: offerData[0])
                                subview.addSubview(nibview)
                                self.incomingAlert!.customSubview = subview
                                self.incomingAlert!.addButton("応答") {
                                    self.offersDb.document(self.offerID!).setData([
                                        "isSelected" : false,
                                        "isOnline" : true
                                    ], merge: true)
                                    self.tabBarController!.selectedIndex = 1
                                    self.peerID = offerData[0].peerID
                                    self.performSegue(withIdentifier: "showCallingView", sender: nil)
                                }
                                self.incomingAlert!.addButton("拒否") {
                                    self.offersDb.document(self.offerID!).setData([
                                        "peerID" : "",
                                        "isSelected" : false,
                                        "isOnline" : true
                                    ], merge: true)
                                }
                                let icon = UIImage(named:"custom_icon.png")
                                let color = UIColor.orange
                                print(offerData[0].learnerName)
                                self.incomingAlert!.showCustom(String(format: self.LString("Call from %@"), offerData[0].learnerName), subTitle: "", color: color, icon: icon!)
                            }
                        } else {
                            self.incomingAlert?.hideView()
                        }
                    }
                    self.searchButton.isUserInteractionEnabled = true
                    self.timeStepper.isEnabled = false
                    self.searchButton.image = UIImage.gif(name: "searchButton")
                    self.searchButton.layer.cornerRadius = 50
                } else {
                    self.instructionLabel2.text = LString("Tap to start searching learners!")
                    self.searchButton.isUserInteractionEnabled = true
                    self.timeStepper.isEnabled = true
                    self.searchButton.image = UIImage(named: "gray")
                    self.searchButton.layer.cornerRadius = 50
                    self.peer?.destroy()
                    self.offersDb.document(self.offerID!).setData([
                        "isOnline": false,
                        "withdrawedAt" : FieldValue.serverTimestamp()
                    ], merge: true)
                }
            } else {
                self.searchButton.isUserInteractionEnabled = true
                self.timeStepper.isEnabled = true
                self.searchButton.image = UIImage(named: "gray")
                self.searchButton.layer.cornerRadius = 50
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showCallingView" {
            self.isOnline = false
            self.offerListener?.remove()
            self.offersDb.document(self.offerID!).setData([
                "isOnline": false,
                "acceptedAt" : FieldValue.serverTimestamp()
            ], merge: true)
            let callVC = segue.destination as! teachCallingViewController
            callVC.peerID = self.peerID
            callVC.mediaConnection = self.mediaConnection
            callVC.offerID = self.offerID!
            callVC.selectedChatroom = self.selectedChatroom
            callVC.avatarImage = self.avatarImage
        }
    }
}

class incomingCallViewNib: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var secondLanguage: UILabel!
    @IBOutlet weak var motherLanguage: UILabel!
    @IBOutlet weak var level: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setData(offer: OfferModel) {
        imageView.image = UIImage(url: offer.learnerImageURL)
        imageView.layer.cornerRadius = 40
        name.text = offer.learnerName
        rating.text = String(format: "%.1f", offer.learnerRating)
        secondLanguage.text = Language.strings[offer.targetLanguage]
        motherLanguage.text = Language.strings[offer.learnerMotherLanguage]
        level.image = UIImage(named: String(offer.learnerLevel))
    }
}


