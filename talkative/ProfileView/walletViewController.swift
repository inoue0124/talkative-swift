//
//  walletViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/26.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Eureka
import FirebaseFirestore
import FirebaseAuth
import SwiftGifOrigin
import RealmSwift

class walletViewController: UIViewController {

    @IBOutlet weak var point: UILabel!
    let Usersdb = Firestore.firestore().collection("Users")

    override func viewDidLoad() {
    self.Usersdb.whereField("uid", isEqualTo: self.getUserUid()).addSnapshotListener() { snapshot, error in
        if let _error = error {
            self.showError(_error)
            return

        }
        guard let documents = snapshot?.documents else {
            return
        }
        let downloadedUserData = documents.map{ UserModel(from: $0) }
        self.point.text = String(downloadedUserData[0].point)
        }
    }
}

