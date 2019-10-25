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

class ProfileViewController: FormViewController, UINavigationControllerDelegate {
    var email: String?
        var password: String?
//        @IBOutlet weak var saveButton: UIBarButtonItem!
        let UserData: RealmUserModel = RealmUserModel()

        override func viewDidLoad() {
            super.viewDidLoad()

            form +++ Section() {
                var header = HeaderFooterView<ProfHeaderViewNib>(.nibFile(name: "ProfViewHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.setUpCell(userData: self.getUserData())
                }
                $0.header = header
            }

            <<< ButtonRow(NSLocalizedString("prof_setting_wallet", comment: "")) {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "walletSegue", onDismiss: nil)
            }.cellUpdate { cell, row in
                cell.height = ({return 80})
            }

            <<< ButtonRow(NSLocalizedString("prof_setting_setting", comment: "")) {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "settingSegue", onDismiss: nil)
            }.cellUpdate { cell, row in
                cell.height = ({return 80})
            }
        }

        func validateForm(dict: [String : Any?]) -> Bool {
            for (_, value) in dict {
                if value == nil {
                    UIAlertController.oneButton("エラー", message: "未入力項目があります。", handler: nil)

                    return false
                }
            }
            return true
        }
}

class ProfHeaderViewNib: UIView {

    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var secondLanguage: UILabel!
    @IBOutlet weak var motherLanguage: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setUpCell(userData: RealmUserModel) {
        Thumbnail.image = UIImage(data: userData.profImage)
        Thumbnail.layer.cornerRadius = 50
        name.text = userData.name
        secondLanguage.text = Language.strings[userData.secondLanguage]
        motherLanguage.text = Language.strings[userData.motherLanguage]
    }
}
