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

class SearchViewController: UIViewController, CLLocationManagerDelegate {

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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var onlineIcon: UIImageView!

    override func viewDidLoad() {
        setupLocationManager()
        MapView.region.span.latitudeDelta = 120
        MapView.region.span.longitudeDelta = 120
        collectionView.register(UINib(nibName: "nativeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        layout.itemSize = CGSize(width: 100, height: 160)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        MapView.delegate = self
        //self.MapView.isZoomEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        largeTitle(LString("先生を探す"))
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
        onlineIcon.image = UIColor.green.circleImage(size: onlineIcon.frame.size)
        if targetLanguage == nil {
            targetLanguage = self.getUserData().secondLanguage
        }
        self.targetLanguageButton.setTitle(Language.strings[targetLanguage!], for: .normal)
        self.usersDB.whereField("motherLanguage", isEqualTo: targetLanguage!).whereField("isOffering", isEqualTo: true).getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return

            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.natives = documents.map{ UserModel(from: $0) }
            self.MapView.removeAnnotations(self.MapView.annotations)
            for native in self.natives! {
                self.native = native
                let annotation = userAnnotation.init(coordinate: CLLocationCoordinate2DMake(native.location.latitude, native.location.longitude), user: native, title: String(format: "%.1f", native.ratingAsNative))
                self.MapView.addAnnotation(annotation)
            }
            self.collectionView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let realm = try! Realm()
        if realm.objects(RealmUserModel.self).isEmpty {
            return
        }
        self.reloadUserRating()
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

    @IBAction func tappedMoreButton(_ sender: Any) {
        searchConditions = ["online": true]
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
            //DetailVC.offer = self.selectedOffer
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
        self.usersDB.document(self.getUserUid()).setData([
            "location": GeoPoint(latitude: self.myLocation!.coordinate.latitude, longitude: self.myLocation!.coordinate.longitude)
        ], merge: true)
    }
}


extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return natives?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! nativeCollectionViewCell
        cell.setData(numOfCells: indexPath, native: natives![indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        native = natives![indexPath.row]
        self.performSegue(withIdentifier: "showNativeDetailView", sender: nil)
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
