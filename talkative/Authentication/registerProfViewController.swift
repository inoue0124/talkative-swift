//
//  waitingMailVerificationView.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/23.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Eureka
import RealmSwift
import FirebaseStorage
import SCLAlertView
import FirebaseFunctions
import Hydra

class registerProfViewController: FormViewController {

    let usersDB = Firestore.firestore().collection("Users")
    let registerBonus: Double = 30.0
    let calendar = Calendar(identifier: .gregorian)

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section() {
            let header = HeaderFooterView<LogoViewNib>(.nibFile(name: "registerProfViewHeader", bundle: nil))
            $0.header = header
        }

        <<< ImageRow {
            $0.title = LString("PROFILE IMAGE")
            $0.sourceTypes = [.PhotoLibrary, .Camera]
            $0.value = UIImage(named: "avatar")
            $0.clearAction = .no
            $0.tag = "profImage"
        }
        .cellUpdate { cell, row in
            cell.height = ({return 80})
            cell.accessoryView?.layer.cornerRadius = 35
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        }

        <<< NameRow {
            $0.title = LString("USER NAME")
            $0.placeholder = LString("John Smith")
            $0.tag = "name"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }

        <<< PushRow<String> {
            $0.title = LString("Gender")
            $0.options = Gender.strings
            $0.tag = "gender"
            $0.value = Gender.strings[0]
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< DateRow {
            $0.title = LString("Date of birth")
            $0.tag = "birthDate"
            $0.value = calendar.date(from: DateComponents(year: 1990, month: 1, day: 1))!
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }

        <<< PushRow<String> {
            $0.title = LString("Nationality")
            $0.options = Array(Nationality.strings.dropFirst(1))
            $0.tag = "nationality"
            $0.value = Nationality.strings[0]
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< PushRow<String> {
            $0.title = LString("I am native in")
            $0.options = Array(Language.strings.dropFirst(1))
            $0.tag = "teachLanguage"
            $0.value = Language.strings[0]
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< PushRow<String> {
            $0.title = LString("I am learning")
            $0.options = Array(Language.strings.dropFirst(1))
            $0.tag = "studyLanguage"
            $0.value = Language.strings[0]
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< PushRow<String> {
            $0.title = LString("Proficiency")
            $0.options = Array(Proficiency.strings.dropFirst(1))
            $0.tag = "proficiency"
            $0.value = Proficiency.strings[0]
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        +++ Section()
        <<< ButtonRow {
            $0.title = LString("save")
            $0.onCellSelection(self.tappedSaveButton)
        }.cellUpdate { cell, row in
            cell.height = ({return 60})
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func tappedSaveButton(cell: ButtonCellOf<String>, row: ButtonRow) {
        startIndicator()
        let values = form.values()
        let uid = String(describing: Auth.auth().currentUser?.uid ?? "Error")
        saveImageToStorage(uid: uid, values: values, image: values["profImage"] as! UIImage)
    }


    func saveImageToStorage(uid: String, values: [String : Any?], image: UIImage) {
        let profImagesDirRef = Storage.storage().reference().child("profImages")
        let fileRef = profImagesDirRef.child(uid+".jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        fileRef.putData(((image).scaledToSafeUploadSize)!.jpegData(compressionQuality: 0.1)!, metadata: metadata) { (meta, error) in
            guard meta != nil else {
                self.showError(error)
                return
            }
            fileRef.downloadURL { (url, error) in
                if let downloadURL = url {
                    self.saveToFirestore(uid: uid, values: values, imageURL: downloadURL)
                    self.saveToRealm(uid: uid, values: values, imageURL: downloadURL)
                    self.performSegue(withIdentifier: "toMain", sender: nil)  
                }
            }
        }
    }

    func saveToRealm(uid: String, values: [String : Any?], imageURL: URL) {
        let userData: RealmUserModel = RealmUserModel()
        userData.uid = uid
        userData.profImage = (values["profImage"] as! UIImage).scaledToSafeUploadSize!.jpegData(compressionQuality: 0.1)!
        userData.imageURL = imageURL.absoluteString
        userData.name = values["name"] as? String ?? LString("Not set")
        userData.gender = Gender.fromString(string: values["gender"] as! String).rawValue
        userData.birthDate = values["birthDate"] as! Date
        userData.nationality = Nationality.fromString(string: values["nationality"] as! String).rawValue
        userData.proficiency = Proficiency.fromString(string: values["proficiency"] as! String).rawValue
        userData.studyLanguage = Language.fromString(string: values["studyLanguage"] as! String).rawValue
        userData.teachLanguage = Language.fromString(string: values["teachLanguage"] as! String).rawValue
        userData.createdAt = Date()
        userData.updatedAt = Date()
        let realm = try! Realm()
        try! realm.write {
          realm.add(userData)
        }
    }

    func saveToFirestore(uid: String, values: [String : Any?], imageURL: URL) {
        usersDB.document(uid).setData([
            "uid": uid,
            "imageURL": imageURL.absoluteString,
            "name": values["name"] as? String ?? LString("Not set"),
            "gender": Gender.fromString(string: values["gender"] as! String).rawValue,
            "birthDate": Timestamp(date: values["birthDate"] as! Date),
            "isOnline" : true,
            "isOffering" : false,
            "nationality": Nationality.fromString(string: values["nationality"] as! String).rawValue,
            "proficiency": Proficiency.fromString(string: values["proficiency"] as! String).rawValue,
            "teachLanguage" : Language.fromString(string: values["teachLanguage"] as! String).rawValue,
            "studyLanguage" : Language.fromString(string: values["studyLanguage"] as! String).rawValue,
            "ratingAsLearner": 4.0,
            "ratingAsNative": 4.0,
            "callCountAsLearner": 0,
            "callCountAsNative": 0,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
        ], merge: true)
        let alert = SCLAlertView()
        alert.showSuccess(LString("Thank you for your registration!"), subTitle: String(format: LString("Got %.1f points!"), registerBonus))
    }
}

class LogoViewNib: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


