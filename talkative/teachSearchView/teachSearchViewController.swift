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

class teachSearchViewController: UIViewController, MKMapViewDelegate {
    var learners: [UserModel]?
    var isOnline = false
    let offersDb = Firestore.firestore().collection("offers")
    let usersDB = Firestore.firestore().collection("Users")
    let loginBonus: Double = 5.0
    var offerID: String?
    var peerID: String?
    var peer: SKWPeer?
    var mediaConnection: SKWMediaConnection?
    var offer: OfferModel?
    var locationManager: CLLocationManager!
    var myLocation: CLLocation?
    var window: UIWindow?
    var offerTime: Int = 10
    var offerListener: ListenerRegistration?
    var incomingAlert: SCLAlertView?
    let chatroomsDb = Firestore.firestore().collection("chatrooms")
    var chatroom: ChatroomModel?
    var avatarImage: UIImage?
    var isUnpaid: Bool?

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
        offerTime = Int(sender.value)
    }

    @objc func applicationWillTerminate(_ notification: Notification?) {
        if let offerID = self.offerID {
            offersDb.document(offerID).setData(["isOnline" : false], merge: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        MapView.region.span.latitudeDelta = 120
        MapView.region.span.longitudeDelta = 120
        //self.MapView.isZoomEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        largeTitle(LString("先生を見つける"))
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
        targetLanguage.text = Language.strings[self.getUserData().motherLanguage]
        searchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(teachSearchViewController.searchButtonTapped(_:))))
        changeButtonState()
        usersDB.whereField("secondLanguage", isEqualTo: self.getUserData().motherLanguage).whereField("isOnline", isEqualTo: true).getDocuments() { snapshot, error in
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
        timeStepper.value = Double(offerTime)
        instructionLabel.center.y = -65
        UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
            self.instructionLabel.center.y = 65
        }, completion: nil)
        reloadUserRatingNative()
    }

    override func viewWillDisappear(_ animated: Bool) {
        instructionLabel.center.y = -65
    }

    @objc func searchButtonTapped(_ sender: UITapGestureRecognizer) {
        checkUnpaidOfferNative() { result in
            self.isUnpaid = result
            self.offerListener?.remove()
            guard let user = Auth.auth().currentUser else { return }
            user.reload()
            if self.myLocation == nil {
                self.setupLocationManager()
                self.isOnline.toggle()
                self.changeButtonState()
                return
            }
            if user.isEmailVerified && !self.isUnpaid! {
                self.isOnline.toggle()
                if self.isOnline {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                      granted, error in
                    }
                    self.changeButtonState()
                    self.makeOffer()
                    self.usersDB.document(self.getUserUid()).setData(["isOffering" : true, "offeringTime": self.offerTime, "lastOnlineAt": FieldValue.serverTimestamp()], merge: true)
                    self.listenOffer()
                } else {
                    self.changeButtonState()
                    self.peer?.destroy()
                    self.offersDb.document(self.offerID!).setData(["isOnline": false, "isAccepted": false, "withdrawedAt" : FieldValue.serverTimestamp()], merge: true)
                    self.usersDB.document(self.getUserUid()).setData(["isOffering" : false], merge: true)
                }
            } else if !user.isEmailVerified {
                self.changeButtonState()
                self.sendEmailVerification(to: user)
                SCLAlertView().showInfo(self.LString("Sent a verification Email"), subTitle: self.LString("Please verify your Email address"))
            }
        }
    }

    func changeButtonState() {
        if isOnline {
            self.searchButton.isUserInteractionEnabled = true
            self.searchButton.image = UIImage.gif(name: "searchButton")
            self.searchButton.layer.cornerRadius = 50
            self.timeStepper.isEnabled = false
            self.instructionLabel2.text = self.LString("Searching...")
        } else {
            self.searchButton.isUserInteractionEnabled = true
            self.searchButton.image = UIImage(named: "gray")
            self.searchButton.layer.cornerRadius = 50
            self.timeStepper.isEnabled = true
            self.instructionLabel2.text = self.LString("Tap to start searching learners!")
        }
    }

    func disableButton() {
        self.searchButton.isUserInteractionEnabled = false
        self.searchButton.image = UIImage.gif(name: "Preloader3")
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

    func makeOffer() {
        offerID = offersDb.document().documentID
        offersDb.document(offerID!).setData([
            "offerID" : offerID!,
            "nativeID" : getUserUid(),
            "nativeName" : getUserData().name,
            "nativeNationality" : getUserData().nationality,
            "nativeMotherLanguage" : getUserData().motherLanguage,
            "nativeRating" : getUserData().ratingAsNative,
            "nativeImageURL" : getUserData().imageURL,
            "nativeLocation" : GeoPoint(latitude: myLocation!.coordinate.latitude, longitude: myLocation!.coordinate.longitude),
            "offerPrice" : offerTime,
            "offerTime" : offerTime,
            "targetLanguage" : getUserData().motherLanguage,
            "supportLanguage" : getUserData().secondLanguage,
            "nativeProficiency": getUserData().proficiency,
            "isOnline": true,
            "createdAt" : FieldValue.serverTimestamp(),
            "canExtend": true,
            "fcmToken" : UserDefaults.standard.string(forKey: "FCM_TOKEN")!
        ], merge: true)
    }

    func listenOffer() {
        offerListener = offersDb.whereField("offerID", isEqualTo: offerID!).addSnapshotListener() { snapshot, error in
            if let _error = error {
                self.showError(_error)
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.offer = documents.map{ OfferModel(from: $0) }[0]
            if self.offer!.peerID != "" {
                self.chatroomsDb.whereField("viewableUserIDs." + self.getUserUid(), isEqualTo: true).whereField("viewableUserIDs." + self.offer!.learnerID, isEqualTo: true).getDocuments() { (querySnapshot, err) in
                    if let _err = err {
                        self.showError(_err)
                    } else if querySnapshot!.documents.isEmpty {
                        self.chatroom = ChatroomModel(chatroomID: self.chatroomsDb.document().documentID, viewableUserIDs: [self.getUserUid():true, self.offer!.learnerID:true], viewableUserNames: [self.getUserUid(): self.getUserData().name, self.offer!.learnerID: self.offer!.learnerName])
                    } else {
                        self.chatroom = ChatroomModel(from: querySnapshot!.documents[0])
                    }
                    self.showAlert(offerData: self.offer!)
                }
            } else {
                self.incomingAlert?.hideView()
            }
        }
    }

    func showAlert(offerData: OfferModel) {
        usersDB.document(self.getUserUid()).setData(["isOffering" : false], merge: true)
        avatarImage = UIImage(url: offerData.learnerImageURL)
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            buttonsLayout: .horizontal
        )
        incomingAlert = SCLAlertView(appearance: appearance)
        let subview = UIView(frame: CGRect(x: 0,y: 0,width: 230,height: 180))
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "incomingCallViewNib", bundle: bundle)
        let nibview = nib.instantiate(withOwner: self, options: nil).first as! incomingCallViewNib
        nibview.setData(offer: offerData)
        subview.addSubview(nibview)
        incomingAlert!.customSubview = subview
        incomingAlert!.addButton("応答") {
            self.offersDb.document(self.offerID!).setData([
                "isSelected" : false,
                "isOnline" : true
            ], merge: true)
            self.tabBarController!.selectedIndex = 1
            self.peerID = offerData.peerID
            self.performSegue(withIdentifier: "showCallingView", sender: nil)
        }
        incomingAlert!.addButton("拒否") {
            self.offersDb.document(self.offerID!).setData([
                "peerID" : "",
                "isSelected" : false,
                "isOnline" : true
            ], merge: true)
            self.usersDB.document(self.getUserUid()).setData(["isOffering" : true], merge: true)
        }
        let icon = UIImage(named:"custom_icon.png")
        let color = UIColor.orange
        incomingAlert!.showCustom(String(format: LString("Call from %@"), offerData.learnerName), subTitle: "", color: color, icon: icon!)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showCallingView" {
            isOnline = false
            offerListener?.remove()
            offersDb.document(offerID!).setData([
                "isOnline": false,
                "isAccepted": true,
                "acceptedAt" : FieldValue.serverTimestamp()
            ], merge: true)
            let callVC = segue.destination as! teachCallingViewController
            callVC.peerID = peerID
            callVC.mediaConnection = mediaConnection
            callVC.offerID = offerID!
            callVC.chatroom = chatroom
            callVC.chatPartnerName = offer!.learnerName
            callVC.avatarImage = avatarImage
        }
    }
}

extension teachSearchViewController: CLLocationManagerDelegate {
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
        myLocation = locations.first
        usersDB.document(getUserUid()).setData([
            "location": GeoPoint(latitude: myLocation!.coordinate.latitude, longitude: myLocation!.coordinate.longitude)
        ], merge: true)
    }
}

class incomingCallViewNib: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var secondLanguage: UILabel!
    @IBOutlet weak var motherLanguage: UILabel!
    @IBOutlet weak var proficiency: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setData(offer: OfferModel) {
        setImage(uid: offer.learnerID, imageView: imageView)
        imageView.layer.cornerRadius = 40
        makeFlagImageView(imageView: nationalFlag, nationality: offer.learnerNationality, radius: 12.5)
        name.text = offer.learnerName
        rating.text = String(format: "%.1f", offer.learnerRating)
        secondLanguage.text = Language.shortStrings[offer.targetLanguage]
        motherLanguage.text = Language.shortStrings[offer.learnerMotherLanguage]
        proficiency.image = UIImage(named: String(offer.learnerProficiency))
    }
}


