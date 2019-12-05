//
//  registarProfViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase
import Eureka
import FirebaseFirestore
import FirebaseAuth
import RealmSwift
import FirebaseStorage
import SCLAlertView

class editProfViewController: FormViewController {

    let Usersdb = Firestore.firestore().collection("Users")
    let profImagesDirRef = Storage.storage().reference().child("profImages")
    var UserData: RealmUserModel?
    let calendar = Calendar(identifier: .gregorian)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = LString("Edit")
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesBackButton = false
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LString("Save"), style: .done, target: self, action: #selector(tappedSaveButton(_:)))
        let backButton = UIBarButtonItem(title: LString("Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(tappedCancelButton(_:)))
        navigationItem.leftBarButtonItem = backButton

        form +++ Section(LString("Basic profile"))
        <<< ImageRow {
            $0.title = LString("PROFILE IMAGE")
            $0.sourceTypes = [.PhotoLibrary, .Camera]
            $0.value = UIImage(data: getUserData().profImage)
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
            $0.placeholder = getUserData().name
            $0.tag = "name"
        }

        <<< PushRow<String> {
            $0.title = LString("Gender")
            $0.options = Gender.strings
            $0.tag = "gender"
            $0.value = Gender.strings[getUserData().gender]
            if self.getUserData().gender != 0 {
                $0.disabled = true
            }
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< DateRow {
            $0.title = LString("Date of birth")
            $0.tag = "birthDate"
            $0.value = getUserData().birthDate
            if self.getUserData().birthDate != calendar.date(from: DateComponents(year: 1990, month: 1, day: 1))! {
                $0.disabled = true
            }
        }

        <<< PushRow<String> {
            $0.title = LString("Nationality")
            $0.options = Array(Nationality.strings.dropFirst(1))
            $0.tag = "nationality"
            $0.value = Nationality.strings[getUserData().nationality]
            if self.getUserData().nationality != 0 {
                $0.disabled = true
            }
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

            +++ Section(LString("Language setting"))
        <<< PushRow<String> {
            $0.title = LString("Teaching language")
            $0.options = Array(Language.strings.dropFirst(1))
            $0.value = Language.strings[getUserData().teachLanguage]
            $0.tag = "teachLanguage"
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< PushRow<String> {
            $0.title = LString("I am learning")
            $0.options = Array(Language.strings.dropFirst(1))
            $0.tag = "studyLanguage"
            $0.value = Language.strings[getUserData().studyLanguage]
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< PushRow<String> {
            $0.title = LString("Proficiency")
            $0.options = Array(Proficiency.strings.dropFirst(1))
            $0.tag = "proficiency"
            $0.value = Proficiency.strings[getUserData().proficiency]
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }
    }

    @objc func tappedSaveButton(_ animated: Bool) {
        startIndicator()
        let values = form.values()
        let uid = String(describing: Auth.auth().currentUser?.uid ?? "Error")
        saveImageToStorate(uid: uid, values: values, image: values["profImage"] as! UIImage)
    }

    @objc func tappedCancelButton(_ animated: Bool) {
        dismiss(animated: true, completion: nil)
    }

    func saveImageToStorate(uid: String, values: [String : Any?], image: UIImage) {
        let profImagesDirRef = Storage.storage().reference().child("profImages")
        let fileRef = profImagesDirRef.child(uid+".jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        fileRef.putData(((image).scaledToSafeUploadSize)!.jpegData(compressionQuality: 0.1)!, metadata: metadata) { (meta, error) in
            guard meta != nil else {
                self.showError(error)
                self.stopIndicator()
                return
            }
            fileRef.downloadURL { (url, error) in
                if let downloadURL = url {
                    self.saveToFirestore(uid: uid, values: values, imageURL: downloadURL)
                    self.saveToRealm(uid: uid, values: values, imageURL: downloadURL)
                }
            }
        }
    }

    func saveToRealm(uid: String, values: [String : Any?], imageURL: URL) {
        let realm = try! Realm()
        let userData = realm.objects(RealmUserModel.self)
        if let userData = userData.first {
            try! realm.write {
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
                userData.updatedAt = Date()
            }
        }
    }

    func saveToFirestore(uid: String, values: [String : Any?], imageURL: URL) {
        self.Usersdb.document(uid).setData([
            "uid": uid,
            "imageURL": imageURL.absoluteString,
            "name": values["name"] as? String ?? LString("Not set"),
            "gender": Gender.fromString(string: values["gender"] as! String).rawValue,
            "birthDate": Timestamp(date: values["birthDate"] as! Date),
            "nationality": Nationality.fromString(string: values["nationality"] as! String).rawValue,
            "proficiency": Proficiency.fromString(string: values["proficiency"] as! String).rawValue,
            "teachLanguage" : Language.fromString(string: values["teachLanguage"] as! String).rawValue,
            "studyLanguage" : Language.fromString(string: values["studyLanguage"] as! String).rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        dismiss(animated: true, completion: nil)
        stopIndicator()
    }
}
