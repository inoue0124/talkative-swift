//
//  ProfileViewController_.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/25.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAuth
import SwiftGifOrigin
import RealmSwift
import SCLAlertView
import FirebaseFirestore
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var genderIcon: UIImageView!
    @IBOutlet weak var secondLanguage: UILabel!
    @IBOutlet weak var motherLanguage: UILabel!
    @IBOutlet weak var proficiency: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!
    @IBOutlet weak var profPanelView: UIView!
    @IBOutlet weak var numOfFollowees: UILabel!
    @IBOutlet weak var numOfFollowers: UILabel!
    @IBOutlet weak var followeeLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followeeButtonStackView: UIStackView!
    @IBOutlet weak var followerButtonStackView: UIStackView!
    var followeeORfollower: String?
    let usersDB = Firestore.firestore().collection("Users")

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = false
        tabBarController?.tabBar.isHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        largeTitle(LString("Profile"))
        setupUserdata()
        setupButtonDesign()
        setSocialNumbers()
        profPanelView.isUserInteractionEnabled = true
        profPanelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.panelTapped(_:))))
        followeeButtonStackView.isUserInteractionEnabled = true
        followeeButtonStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tappedFolloweeButton(_:))))
        followerButtonStackView.isUserInteractionEnabled = true
        followerButtonStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tappedFollowerButton(_:))))
    }

    func setSocialNumbers() {
        usersDB.document(getUserUid()).collection("followee").getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.numOfFollowees.text = String(documents.count)
        }
        usersDB.document(getUserUid()).collection("follower").getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.numOfFollowers.text = String(documents.count)
        }
    }

    func setupUserdata() {
        let userData = getUserData()
        Thumbnail.image = UIImage(data: userData.profImage)
        Thumbnail.layer.cornerRadius = 40
        name.text = userData.name
        age.text = String(self.birthDateToAge(byBirthDate: getUserData().birthDate))
        setGenderIcon(gender: getUserData().gender, imageView: genderIcon)
        secondLanguage.text = Language.strings[userData.studyLanguage]
        motherLanguage.text = Language.strings[userData.teachLanguage]
        proficiency.image = UIImage(named: String(userData.proficiency))    
        makeFlagImageView(imageView: nationalFlag, nationality: userData.nationality, radius: 12.5)
    }

    func setupButtonDesign() {
        followeeLabel.text = LString("followee")
        followerLabel.text = LString("follower")
    }

    @objc func panelTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showProfEdit", sender: nil)
    }

    @objc func tappedFolloweeButton(_ sender: UITapGestureRecognizer) {
        followeeORfollower = "followee"
        performSegue(withIdentifier: "showFollowView", sender: nil)
    }

    @objc func tappedFollowerButton(_ sender: UITapGestureRecognizer) {
        followeeORfollower = "follower"
        performSegue(withIdentifier: "showFollowView", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFollowView" {
            let followVC = segue.destination as! followViewController
            followVC.followeeORfollower = followeeORfollower
        }
    }

}

class ProfileCollectionViewController: FormViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        form +++ Section() {
            $0.header?.height = { CGFloat.leastNormalMagnitude }
            }
            <<< ButtonRow {
                $0.title = LString("History")
                $0.presentationMode = .segueName(segueName: "hisotrySegue", onDismiss: nil)
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "reviews")
                cell.height = ({return 60})
            }

            <<< ButtonRow {
                $0.title = LString("Points")
                $0.presentationMode = .segueName(segueName: "walletSegue", onDismiss: nil)
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "points")
                cell.height = ({return 60})
            }

            <<< ButtonRow {
                $0.title = LString("Purchase points")
                $0.presentationMode = .segueName(segueName: "walletSegue", onDismiss: nil)
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "purchase")
                cell.height = ({return 60})
            }

            <<< ButtonRow {
                $0.title = LString("Withdraw")
                $0.presentationMode = .segueName(segueName: "walletSegue", onDismiss: nil)
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "withdraw")
                cell.height = ({return 60})
            }

            <<< ButtonRow() {
                $0.title = LString("SIGN OUT")
                $0.onCellSelection(self.buttonTapped)
            }.cellUpdate { cell, row in
                cell.height = ({return 60})
            }
    }

    func buttonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        
        let alert = SCLAlertView()
        alert.addButton(LString("OK")) {
            let realm = try! Realm()
            do {
                var config = Realm.Configuration()
                config.deleteRealmIfMigrationNeeded = true
                try! realm.write {
                    realm.deleteAll()
                }
                LoginManager().logOut()
                try Auth.auth().signOut()
            } catch let error {
                print(error)
            }
        }
        alert.showWarning(LString("SIGN OUT"), subTitle: LString("Are you going to sign out?"))
    }
}
