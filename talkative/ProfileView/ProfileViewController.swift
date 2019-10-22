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

    func loadUserInfo() {
        self.UserData = self.getUserData()
        self.uid = self.UserData!.uid
        self.UserIcon.layer.cornerRadius = 50
        self.UserName.text = self.UserData!.name
        self.secondLanguage.text = Language.strings[self.UserData!.secondLanguage]
        self.motherLanguage.text = Language.strings[self.UserData!.motherLanguage]
        self.profTable.dataSource = self
        self.UserIcon.image = UIImage.gif(name: "Preloader")
        let downloadurl = URL(string: self.UserData!.imageURL)!
        DispatchQueue.global().async {
            let image = UIImage(url: downloadurl)
            DispatchQueue.main.async {
                self.UserIcon.image = image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else {
                let loginStoryboard: UIStoryboard = UIStoryboard(name: "loginView", bundle: nil)
                let loginVC = loginStoryboard.instantiateInitialViewController()
                self.show(loginVC!, sender: self)
                return
            }
            if self.UserData != self.getUserData() {
                self.loadUserInfo()
            }
        }
        largeTitle("プロフィール")
        settingsTable.dataSource = self
        settingsTable.delegate = self
        settingsTable.reloadData()
        self.navigationItem.hidesBackButton = false
        tabBarController?.tabBar.isHidden = false
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileEditor" {
            let ProfEditorVC = segue.destination as! registerProfViewController
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
}

enum settingType: Int {
    case wallet
    case setting

    var prop: (title: String, icon: UIImage) {
        switch self {
            case .wallet:
                return (title: "ウォレット", icon: UIImage(named: "wallet")!)
            case .setting:
                return (title: "設定", icon: UIImage(named: "setting")!)
        }
    }
}

