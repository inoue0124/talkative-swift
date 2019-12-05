//
//  selectLanguageViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/12/02.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import FirebaseFirestore

class selectLanguageViewController: FormViewController {
    let usersDB = Firestore.firestore().collection("Users")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.title = LString("Language setting")
        navigationItem.largeTitleDisplayMode = .never
        form +++ Section() {
            $0.header?.height = { CGFloat.leastNormalMagnitude }
        }

        <<< PushRow<String>() {
            $0.title = LString("Language you want to learn")
            $0.options = Array(Language.strings.dropFirst(1))
            $0.tag = "studyLanguage"
            $0.value = Language.strings[getUserData().studyLanguage]
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        let settings = form.values()
        let realm = try! Realm()
        let UserData = realm.objects(RealmUserModel.self)
        if let UserData = UserData.first {
            try! realm.write {
                UserData.studyLanguage = Language.fromString(string: settings["studyLanguage"] as! String).rawValue
            }
        }
        usersDB.document(getUserUid()).setData(["studyLanguage": getUserData().studyLanguage], merge: true)
    }
}


