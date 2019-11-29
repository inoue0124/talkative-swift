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

class ProfileViewController: UIViewController {
    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var secondLanguage: UILabel!
    @IBOutlet weak var motherLanguage: UILabel!
    @IBOutlet weak var proficiency: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!
    @IBOutlet weak var followeeButton: UIButton!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var profPanelView: UIView!
    let titleColor: UIColor = UIColor(red: 90/255, green: 84/255, blue: 75/255, alpha: 1)
    var followeeORfollower: String?

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = false
        tabBarController?.tabBar.isHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        largeTitle(LString("Profile"))
        setupUserdata()
        setupButtonDesign()
        profPanelView.isUserInteractionEnabled = true
        profPanelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.panelTapped(_:))))
    }

    func setupUserdata() {
        let userData = self.getUserData()
        Thumbnail.image = UIImage(data: userData.profImage)
        Thumbnail.layer.cornerRadius = 40
        name.text = userData.name
        secondLanguage.text = Language.strings[userData.secondLanguage]
        motherLanguage.text = Language.strings[userData.motherLanguage]
        proficiency.image = UIImage(named: String(userData.proficiency))    
        self.makeFlagImageView(imageView: self.nationalFlag, nationality: userData.nationality, radius: 12.5)
    }

    func setupButtonDesign() {
        followeeButton.setTitle(LString("followee"), for: .normal)
        followeeButton.setTitleColor(titleColor, for: .normal)
        followeeButton.layer.borderColor = UIColor.gray.cgColor
        followeeButton.layer.borderWidth = 0.5
        followerButton.setTitle(LString("follower"), for: .normal)
        followerButton.setTitleColor(titleColor, for: .normal)
        followerButton.layer.borderColor = UIColor.gray.cgColor
        followerButton.layer.borderWidth = 0.5
    }

    @objc func panelTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showProfEdit", sender: nil)
    }

    @IBAction func followeeButtonTapped(_ sender: Any) {
        followeeORfollower = "followee"
        performSegue(withIdentifier: "showFollowView", sender: nil)
    }

    @IBAction func followerButtonTapped(_ sender: Any) {
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
                try Auth.auth().signOut()
            } catch let error {
                print(error)
            }
        }
        alert.showWarning(LString("SIGN OUT"), subTitle: LString("Are you going to sign out?"))
    }
}
