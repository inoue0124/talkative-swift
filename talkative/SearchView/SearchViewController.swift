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
import DZNEmptyDataSet

class SearchViewController: UIViewController, CLLocationManagerDelegate {

    var onlineNatives: [UserModel]?
    var natives: [UserModel]?
    var native: UserModel?
    var searchConditions: [String:Any]?
    var locationManager: CLLocationManager!
    let offersDB = Firestore.firestore().collection("offers")
    let usersDB = Firestore.firestore().collection("Users")
    let loginBonus: Double = 5.0
    var myLocation: CLLocation?
    var window: UIWindow?
    var targetLanguage: Int?

    @IBOutlet weak var targetLanguageButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var onlineNativeCollectionView: UICollectionView!
    @IBOutlet weak var topNativeCollectionView: UICollectionView!
    @IBOutlet weak var onlineIcon: UIImageView!

    override func viewDidLoad() {
        setupLocationManager()
        MapView.region.span.latitudeDelta = 120
        MapView.region.span.longitudeDelta = 120
        onlineNativeCollectionView.register(UINib(nibName: "nativeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "onlineCell")
        onlineNativeCollectionView.delegate = self
        onlineNativeCollectionView.dataSource = self
        onlineNativeCollectionView.emptyDataSetSource = self
        onlineNativeCollectionView.emptyDataSetDelegate = self
        topNativeCollectionView.register(UINib(nibName: "nativeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "topCell")
        topNativeCollectionView.delegate = self
        topNativeCollectionView.dataSource = self
        topNativeCollectionView.emptyDataSetSource = self
        topNativeCollectionView.emptyDataSetDelegate = self
        let layout1 = UICollectionViewFlowLayout()
        layout1.sectionInset = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        layout1.itemSize = CGSize(width: 110, height: 190)
        layout1.scrollDirection = .horizontal
        let layout2 = UICollectionViewFlowLayout()
        layout2.sectionInset = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        layout2.itemSize = CGSize(width: 110, height: 190)
        layout2.scrollDirection = .horizontal
        onlineNativeCollectionView.collectionViewLayout = layout1
        topNativeCollectionView.collectionViewLayout = layout2
        MapView.delegate = self
        //self.MapView.isZoomEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        largeTitle(LString("Search tutors"))
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
        onlineIcon.image = UIColor.green.circleImage(size: onlineIcon.frame.size)
        if targetLanguage == nil {
            targetLanguage = getUserData().studyLanguage
        }
        targetLanguageButton.setTitle(Language.strings[getUserData().studyLanguage], for: .normal)
        getCollectionData()
    }

    func getCollectionData() {
        usersDB.whereField("teachLanguage", isEqualTo: getUserData().studyLanguage).getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return

            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.natives = documents.map{ UserModel(from: $0) }
            self.natives = self.natives?.filter{ $0.uid != self.getUserUid()}
            self.onlineNatives = self.natives?.filter{ $0.isOffering == true }
            self.natives?.sort{ $0.callCountAsNative > $1.callCountAsNative }
            self.natives = Array((self.natives?.prefix(10))!)
            self.onlineNatives?.sort{ $0.lastOnlineAt > $1.lastOnlineAt }
            self.onlineNatives = Array((self.onlineNatives?.prefix(10))!)
            self.MapView.removeAnnotations(self.MapView.annotations)
            for native in self.onlineNatives! {
                self.native = native
                let annotation = userAnnotation.init(coordinate: CLLocationCoordinate2DMake(native.location.latitude, native.location.longitude), user: native, title: String(format: "%.1f", native.ratingAsNative))
                self.MapView.addAnnotation(annotation)
            }
            self.onlineNativeCollectionView.reloadData()
            self.topNativeCollectionView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
        self.reloadUserData()
    }


    @IBAction func presentConditions(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            user.reload()
            if self.myLocation == nil {
                self.setupLocationManager()
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

    @IBAction func tappedMoreOnlineButton(_ sender: Any) {
        searchConditions = ["online": true, "teachLanguage": Language.strings[getUserData().studyLanguage]]
        performSegue(withIdentifier: "showResult", sender: nil)
    }

    @IBAction func tappedMoreButton(_ sender: Any) {
        searchConditions = ["teachLanguage": Language.strings[getUserData().studyLanguage]]
        performSegue(withIdentifier: "showResult", sender: nil)
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

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            let ResultVC = segue.destination as! SearchResultViewController
            ResultVC.searchConditions = searchConditions
        }
        if segue.identifier == "showNativeDetailView" {
            let DetailVC = segue.destination as! userDetailViewController
            DetailVC.user = native
            DetailVC.tabIndex = 0
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
        self.usersDB.document(getUserUid()).setData([
            "location": GeoPoint(latitude: myLocation!.coordinate.latitude, longitude: myLocation!.coordinate.longitude)
        ], merge: true)
    }
}


extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(onlineNativeCollectionView) {
            if onlineNatives?.count ?? 0 > 10 {
                return 10
            } else {
                return onlineNatives?.count ?? 0
            }
        } else {
            if natives?.count ?? 0 > 10 {
                return 10
            } else {
                return natives?.count ?? 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(onlineNativeCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onlineCell", for: indexPath) as! nativeCollectionViewCell
            cell.setData(numOfCells: indexPath, native: onlineNatives![indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath) as! nativeCollectionViewCell
            cell.setData(numOfCells: indexPath, native: natives![indexPath.row])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(onlineNativeCollectionView) {
            native = onlineNatives![indexPath.row]
        } else {
            native = natives![indexPath.row]
        }
        self.performSegue(withIdentifier: "showNativeDetailView", sender: nil)
    }
}

extension SearchViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "user")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = LString("Tutor not found")
        return NSAttributedString(string: text)
    }
}

class userAnnotation:NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    public var user: UserModel
    public var title: String?

    init(coordinate: CLLocationCoordinate2D, user: UserModel, title: String) {
        self.coordinate = coordinate
        self.user = user
        self.title = title
        super.init()
    }
}

extension SearchViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        var annotationView: MKAnnotationView!
        if annotationView == nil {
           annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        let userAnnotation = annotation as? userAnnotation
        let imageView = UIImageView(frame: CGRect(x:0, y:0, width:40, height:40))
        self.setImage(uid: userAnnotation!.user.uid, imageView: imageView)
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        annotationView.frame = imageView.frame
        annotationView.addSubview(imageView)
        annotationView.annotation = userAnnotation
        annotationView.canShowCallout = true
        let starImageView = UIImageView(frame: CGRect(x:0, y:0, width:16, height:16))
        starImageView.image = UIImage(named: "star_fill")
        annotationView.leftCalloutAccessoryView = starImageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gestureRecognizer:)))
        annotationView.addGestureRecognizer(tapGesture)
        return annotationView
    }

    @objc func tapGesture(gestureRecognizer: UITapGestureRecognizer){
        let view = gestureRecognizer.view as? MKAnnotationView
        let annotation = view?.annotation as? userAnnotation
        let tapPoint = gestureRecognizer.location(in: view)
        //ピン部分のタップだったらリターン
        if tapPoint.x >= 0 && tapPoint.y >= 0 {
            return
        }
        native = annotation?.user
        self.performSegue(withIdentifier: "showNativeDetailView", sender: nil)
    }
}
