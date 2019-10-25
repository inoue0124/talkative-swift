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

class editProfViewController: FormViewController {

    let Usersdb = Firestore.firestore().collection("Users")
    let profImagesDirRef = Storage.storage().reference().child("profImages")
    var UserData: RealmUserModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserData == nil {
            UserData = RealmUserModel()
        }
        form +++ Section(NSLocalizedString("prof_section_base", comment: ""))
        <<< ImageRow {
            $0.title = NSLocalizedString("prof_image", comment: "")
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
            $0.title = NSLocalizedString("prof_name", comment: "")
            $0.placeholder = "Taro Yamada"
            $0.tag = "name"
            $0.validationOptions = .validatesOnChangeAfterBlurred
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
            if !row.isValid {
                cell.titleLabel?.textColor = .red
                var errors = "必須項目です"
                for error in row.validationErrors {
                    let errorString = error.msg + "\n"
                    errors = errors + errorString
                }
                print(errors)
                cell.detailTextLabel?.text = errors
                cell.detailTextLabel?.isHidden = false
                cell.detailTextLabel?.textAlignment = .left

            }
        }

            +++ Section(NSLocalizedString("prof_section_base", comment: ""))
        <<< PushRow<String> {
            $0.title = NSLocalizedString("prof_motherLanguage", comment: "")
            $0.options = [Language.Japanese.string(), Language.English.string(), Language.Chinese.string()]
            $0.tag = "motherLanguage"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }

        <<< PushRow<String> {
            $0.title = NSLocalizedString("prof_secondLanguage", comment: "")
            $0.options = [Language.Unknown.string(), Language.Japanese.string(), Language.English.string(), Language.Chinese.string()]
            $0.tag = "secondLanguage"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }
    }

    @IBAction func tappedSaveButton(_ sender: Any) {
        let values = form.values()
        let uid = String(describing: Auth.auth().currentUser?.uid ?? "Error")
        let originalImageRef = profImagesDirRef.child(uid+".jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        originalImageRef.putData(((values["profImage"] as! UIImage).scaledToSafeUploadSize)!.jpegData(compressionQuality: 0.1)!, metadata: metadata) { (meta, error) in
            guard meta != nil else {
            print("error")
            return
          }
            originalImageRef.downloadURL { (url, error) in
            if let downloadURL = url {
                self.Usersdb.document(uid).setData([
                        "uid": uid,
                        "name": values["name"] as! String,
                        "imageURL": downloadURL.absoluteString,
                        "gender": Gender.fromString(string: values["gender"] as! String).rawValue,
                        "birthDate": Timestamp(date: values["birthDate"] as! Date),
                        "isWroteProf": true,
                        "isOnline" : true,
                        "createdAt": FieldValue.serverTimestamp(),
                        "updatedAt": FieldValue.serverTimestamp(),
                        "nationality": Nationality.fromString(string: values["nationality"] as! String).rawValue,
                        "motherLanguage": Language.fromString(string: values["motherLanguage"] as! String).rawValue,
                        "secondLanguage": Language.fromString(string: values["secondLanguage"] as! String).rawValue
                    ], merge: true)
                let UserData: RealmUserModel = RealmUserModel()
                UserData.uid = uid
                UserData.name = values["name"] as! String
                UserData.imageURL = downloadURL.absoluteString
                UserData.gender = Gender.fromString(string: values["gender"] as! String).rawValue
                UserData.birthDate = values["birthDate"] as! Date
                UserData.isRegisteredProf = true
                UserData.createdAt = Date()
                UserData.updatedAt = Date()
                UserData.nationality = Nationality.fromString(string: values["nationality"] as! String).rawValue
                UserData.motherLanguage = Language.fromString(string: values["motherLanguage"] as! String).rawValue
                UserData.secondLanguage = Language.fromString(string: values["secondLanguage"] as! String).rawValue
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                }
                try! realm.write {
                  realm.add(UserData)
                }
            }
                self.navigationController?.popToRootViewController(animated: true)
          }
        }
    }
}

