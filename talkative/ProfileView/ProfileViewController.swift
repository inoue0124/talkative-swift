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

class ProfileViewController: UIViewController {
    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var secondLanguage: UILabel!
    @IBOutlet weak var motherLanguage: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = false
        tabBarController?.tabBar.isHidden = false
        largeTitle(NSLocalizedString("largetitle_profile", comment: ""))
        let userData = self.getUserData()
        Thumbnail.image = UIImage(data: userData.profImage)
        Thumbnail.layer.cornerRadius = 50
        name.text = userData.name
        secondLanguage.text = Language.strings[userData.secondLanguage]
        motherLanguage.text = Language.strings[userData.motherLanguage]
    }

}

class ProfileCollectionViewController: FormViewController, UINavigationControllerDelegate {
    var email: String?
    var password: String?
    let UserData: RealmUserModel = RealmUserModel()


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        form +++ Section() {
            $0.header?.height = { CGFloat.leastNormalMagnitude }
        }

        <<< ButtonRow {
            $0.title = NSLocalizedString("prof_setting_following", comment: "")
            $0.presentationMode = .segueName(segueName: "followeeSegue", onDismiss: nil)
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }

        <<< ButtonRow {
            $0.title = NSLocalizedString("prof_setting_wallet", comment: "")
            $0.presentationMode = .segueName(segueName: "walletSegue", onDismiss: nil)
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }

        <<< ButtonRow {
            $0.title = NSLocalizedString("prof_setting_setting", comment: "")
            $0.presentationMode = .segueName(segueName: "settingSegue", onDismiss: nil)
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }
    }
}
