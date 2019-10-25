//
//  ProfileViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/08.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftGifOrigin
import RealmSwift

class ProfileViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    var UserData:RealmUserModel?
    var uid: String?
    @IBOutlet weak var UserIcon: UIImageView!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var secondLanguage: UILabel!
    @IBOutlet weak var motherLanguage: UILabel!
    @IBOutlet weak var profTable: UITableView!
    @IBOutlet weak var settingsTable: UITableView!
    @IBOutlet weak var label_motherLanguage: UILabel!
    @IBOutlet weak var label_secondLanguage: UILabel!

    func loadUserInfo() {
        self.UserData = self.getUserData()
        self.uid = self.UserData!.uid
        self.UserIcon.layer.cornerRadius = 50
        self.UserName.text = self.UserData!.name
        self.secondLanguage.text = Language.strings[self.UserData!.secondLanguage]
        self.motherLanguage.text = Language.strings[self.UserData!.motherLanguage]
        self.profTable.dataSource = self
        self.UserIcon.image = UIImage(data: self.UserData!.profImage)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.label_motherLanguage.text = NSLocalizedString("prof_motherLanguage", comment: "")
        self.label_secondLanguage.text = NSLocalizedString("prof_secondLanguage", comment: "")
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else {
                self.performSegue(withIdentifier: "toLoginView", sender: nil)
                return
            }
            if self.UserData != self.getUserData() {
                self.loadUserInfo()
            }
        }
        largeTitle(NSLocalizedString("largetitle_profile", comment: ""))
        settingsTable.dataSource = self
        settingsTable.delegate = self
        settingsTable.reloadData()
        self.navigationItem.hidesBackButton = false
        tabBarController?.tabBar.isHidden = false
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileEditor" {
            let ProfEditorVC = segue.destination as! editProfViewController
            ProfEditorVC.UserData = self.UserData
        }
    }
    // cellを返す。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let settings = settingType(rawValue: indexPath.row)
        cell.imageView?.image = settings?.prop.icon
        cell.textLabel?.text = settings?.prop.title
        return cell
    }

    //セルの数をいくつにするか。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            performSegue(withIdentifier: "showFolloweeView", sender: nil)
        }
    }
}

enum settingType: Int {
    case favorite
    case wallet
    case setting

    var prop: (title: String, icon: UIImage) {
        switch self {
        case .favorite:
            return (title: NSLocalizedString("prof_setting_following", comment: ""), icon: UIImage(named: "heart_fill")!)
        case .wallet:
            return (title: NSLocalizedString("prof_setting_wallet", comment: ""), icon: UIImage(named: "wallet")!)
        case .setting:
            return (title: NSLocalizedString("prof_setting_setting", comment: ""), icon: UIImage(named: "setting")!)
        }
    }
}

