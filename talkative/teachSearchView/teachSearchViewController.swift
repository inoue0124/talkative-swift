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
import Charts

class teachSearchViewController: UIViewController, MKMapViewDelegate {
    var learners: [UserModel]?
    var isOnline = false
    var unpaidOffer: OfferModel?
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
    var offerTime: Int?
    var offerListener: ListenerRegistration?
    var incomingAlert: SCLAlertView?
    let chatroomsDb = Firestore.firestore().collection("chatrooms")
    var chatroom: ChatroomModel?
    var avatarImage: UIImage?
    var isUnpaid: Bool?
    var hours: [String]!

    @IBOutlet weak var searchButton: UIImageView!
    @IBOutlet weak var numOfLearners: UILabel!
    @IBOutlet weak var targetLanguage: UILabel!
    @IBOutlet weak var balloonView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var settingPanel: UIView!
    @IBOutlet weak var teachStyleImage: UIImageView!
    @IBOutlet weak var teachStyleLabel: UILabel!
    @IBOutlet weak var allowExtensionLabel: UILabel!
    @IBOutlet weak var matchProbChart: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        settingPanel.isUserInteractionEnabled = true
        settingPanel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(teachSearchViewController.panelTapped(_:))))
        hours = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]
        var matchProb = [49.0, 35.0, 28.0, 15.0, 20.0, 24.0, 27.0, 30.0, 32.0, 36.0, 37.0, 39.0, 43.0, 46.0, 59.0, 62.0, 65.0, 70.0, 75.0, 82.0, 84.0, 86.0, 85.0, 75.0, 65.0]
        matchProb = matchProb.map{ $0 + Double.random(in: 1 ..< 3)}
        setChart(dataPoints: hours, values: matchProb)
    }

    func setChart(dataPoints: [String], values: [Double]) {
        matchProbChart.noDataText = "You need to provide data for the chart."
        matchProbChart.xAxis.drawGridLinesEnabled = false
        matchProbChart.xAxis.labelTextColor = UIColor.green
        matchProbChart.legend.enabled = false
        matchProbChart.leftAxis.drawGridLinesEnabled = false
        matchProbChart.leftAxis.labelTextColor = UIColor.green
        matchProbChart.rightAxis.enabled = false
        matchProbChart.xAxis.labelPosition = .bottom
        matchProbChart.pinchZoomEnabled = false
        matchProbChart.dragEnabled = false
        matchProbChart.animate(xAxisDuration: 1, yAxisDuration: 1)
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        let gradientColors = [UIColor.green.cgColor, UIColor.clear.cgColor] as CFArray
        let colorLocations: [CGFloat] = [1.0, 0.0]
        guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) else { print("gradiend error"); return }
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.cubicIntensity = 0.5
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        chartDataSet.drawFilledEnabled = true
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(false)
        matchProbChart.data = chartData
    }

    @objc func applicationWillTerminate(_ notification: Notification?) {
        if let offerID = self.offerID {
            offersDb.document(offerID).setData(["isOnline" : false], merge: true)
        }
    }

    @objc func panelTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showTeachSetting", sender: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        largeTitle(LString("Teach language"))

        targetLanguage.text = Language.shortStrings[getUserData().teachLanguage]
        offerTime = getUserData().offerTime
        timeLabel.text = String(offerTime!) + "分"
        if getUserData().teachStyle == 0 {
            teachStyleImage.image = UIImage(named: "Teach")
        } else {
            teachStyleImage.image = UIImage(named: "Free talk")
        }
        teachStyleLabel.text = TeachingStyle.strings[getUserData().teachStyle]
        if getUserData().isAllowExtension {
            allowExtensionLabel.text = LString("OK")
        } else {
            allowExtensionLabel.text = LString("No")
        }
        searchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(teachSearchViewController.searchButtonTapped(_:))))
        usersDB.whereField("studyLanguage", isEqualTo: getUserData().teachLanguage).whereField("isOnline", isEqualTo: true).getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.learners = documents.map{ UserModel(from: $0) }
            self.numOfLearners.text = String(self.learners!.count)+"人が"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        changeButtonState()
        reloadUserData()
    }

    @objc func searchButtonTapped(_ sender: UITapGestureRecognizer) {
        checkUnpaidOfferNative() { result, offer in
            self.isUnpaid = result
            self.unpaidOffer = offer
            self.offerListener?.remove()
            guard let user = Auth.auth().currentUser else { return }
            user.reload()
            if self.myLocation == nil {
                self.setupLocationManager()
                self.isOnline.toggle()
                self.changeButtonState()
                return
            }
            //if user.isEmailVerified && !self.isUnpaid! {
            if !self.isUnpaid! {
                self.isOnline.toggle()
                if self.isOnline {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                      granted, error in
                    }
                    self.changeButtonState()
                    self.makeOffer()
                    self.usersDB.document(self.getUserUid()).setData(["isOffering" : true, "offerTime": self.offerTime!, "lastOnlineAt": FieldValue.serverTimestamp()], merge: true)
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
            searchButton.isUserInteractionEnabled = true
            searchButton.image = UIImage.gif(name: "searchButton")
            searchButton.layer.cornerRadius = 50
            makeBalloonView(text: LString("Searching..."))
        } else {
            searchButton.isUserInteractionEnabled = true
            searchButton.image = UIImage(named: "gray")
            searchButton.layer.cornerRadius = 50
            makeBalloonView(text: LString("Tap to start searching learners!"))
        }
    }

    func makeBalloonView(text: String) {
        let subviews = balloonView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        let label = UITextView(frame: CGRect(x: 0, y: 0, width: balloonView.frame.width, height: balloonView.frame.height))
        label.backgroundColor = UIColor.clear
        label.text = text
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        balloonView.addSubview(label)
    }

    func disableButton() {
        searchButton.isUserInteractionEnabled = false
        searchButton.image = UIImage.gif(name: "Preloader3")
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
            "nativeMotherLanguage" : getUserData().teachLanguage,
            "nativeRating" : getUserData().ratingAsNative,
            "nativeImageURL" : getUserData().imageURL,
            "nativeLocation" : GeoPoint(latitude: myLocation!.coordinate.latitude, longitude: myLocation!.coordinate.longitude),
            "offerPrice" : offerTime!,
            "offerTime" : offerTime!,
            "targetLanguage" : getUserData().teachLanguage,
            "supportLanguage" : getUserData().studyLanguage,
            "teachStyle": getUserData().teachStyle,
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
        let subview = UIView(frame: CGRect(x: 0,y: 0,width: 216,height: 140))
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "incomingCallViewNib", bundle: bundle)
        let nibview = nib.instantiate(withOwner: self, options: nil).first as! incomingCallViewNib
        nibview.setData(offer: offerData)
        nibview.center = subview.center
        subview.addSubview(nibview)
        incomingAlert!.customSubview = subview
        incomingAlert!.addButton("応答") {
            self.offersDb.document(self.offerID!).setData([
                "isSelected" : false,
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
        if segue.identifier == "showReviewView" {
            let ReviewVC = segue.destination as! teachReviewViewController
            ReviewVC.offer = unpaidOffer!
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
        rating.text = String(format: "%.1f", offer.learnerRating)
        secondLanguage.text = Language.shortStrings[offer.targetLanguage]
        motherLanguage.text = Language.shortStrings[offer.learnerMotherLanguage]
        proficiency.image = UIImage(named: String(offer.learnerProficiency))
    }
}


