//
//  teachSettingView.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/12/02.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import FirebaseFirestore

class teachSettingViewController: FormViewController {
    let usersDB = Firestore.firestore().collection("Users")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.title = LString("Setting")
        navigationItem.largeTitleDisplayMode = .never
        form +++ Section() {
            $0.header?.height = { CGFloat.leastNormalMagnitude }
        }
        <<< SegmentedRow<String>() {
            $0.title = LString("Teaching style")
            $0.tag = "teachStyle"
            $0.options = TeachingStyle.strings
            $0.value = TeachingStyle.strings[getUserData().teachStyle]
        }

        <<< PushRow<String>() {
            $0.title = LString("Teaching language")
            $0.options = Array(Language.strings.dropFirst(1))
            $0.tag = "teachLanguage"
            $0.value = Language.strings[getUserData().teachLanguage]
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< StepperRow {
            $0.title = LString("Length of call time")
            $0.tag = "offerTime"
            $0.value = Double(getUserData().offerTime)
            $0.cell.stepper.stepValue = 5
            $0.cell.stepper.minimumValue = 5
            $0.cell.stepper.maximumValue = 95
        }.cellUpdate({ (cell, row) in
            if(row.value != nil)
            {
            cell.valueLabel.text = "\(Int(row.value!))"
            }
        }).onChange({ (row) in
            if(row.value != nil)
            {
                row.cell.valueLabel.text = "\(Int(row.value!))"
            }
        })

        <<< SwitchRow {
            $0.title = LString("Allow extension")
            $0.tag = "allowExtension"
            $0.value = getUserData().isAllowExtension
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
                UserData.teachStyle = TeachingStyle.fromString(string: settings["teachStyle"] as! String).rawValue
                UserData.teachLanguage = Language.fromString(string: settings["teachLanguage"] as! String).rawValue
                UserData.offerTime = Int(settings["offerTime"] as! Double)
                UserData.isAllowExtension = settings["allowExtension"] as! Bool
            }
        }
        usersDB.document(getUserUid()).setData(["teachStyle": getUserData().teachStyle,
                                                "teachLanguage" : getUserData().teachLanguage,
                                                "offerTime": getUserData().offerTime,
                                                "allowExtension": getUserData().isAllowExtension], merge: true)
    }
}
