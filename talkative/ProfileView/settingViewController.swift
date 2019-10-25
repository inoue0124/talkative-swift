//
//  settingViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/26.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAuth
import SwiftGifOrigin
import RealmSwift

class settingViewController: UIViewController {
    let realm = try! Realm()
    @IBOutlet weak var loguotButton: UIButton!
    @IBAction func tappedLogoutButton(_ sender: Any) {
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
}
