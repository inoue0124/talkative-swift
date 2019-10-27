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
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(NSLocalizedString("prof_section_base", comment: ""))
        <<< ImageRow {
            $0.title = NSLocalizedString("prof_image", comment: "")
            $0.sourceTypes = [.PhotoLibrary, .Camera]
            $0.value = UIImage(data: self.getUserData().profImage)
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
            $0.value = self.getUserData().name
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
            $0.value = Language.strings[self.getUserData().motherLanguage]
            $0.tag = "motherLanguage"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }

        <<< PushRow<String> {
            $0.title = NSLocalizedString("prof_secondLanguage", comment: "")
            $0.options = [Language.Unknown.string(), Language.Japanese.string(), Language.English.string(), Language.Chinese.string()]
            $0.value = Language.strings[self.getUserData().secondLanguage]
            $0.tag = "secondLanguage"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }
    }

    func validateForm(dict: [String : Any?]) -> Bool {
        for (key, value) in dict {
            if value == nil {
                UIAlertController.oneButton("エラー", message: "未入力項目があります。", handler: nil)
                return false
            }
        }
        return true
    }

    @IBAction func tappedSaveButton(_ sender: Any) {
        let values = form.values()
        if self.validateForm(dict: values) {
            let uid = String(describing: Auth.auth().currentUser?.uid ?? "Error")
            self.saveImageToStorate(uid: uid, values: values, image: values["profImage"] as! UIImage)
            self.saveToFirestore(uid: uid, values: values)
        }
    }

    func saveImageToStorate(uid: String, values: [String : Any?], image: UIImage) {
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
                    self.Usersdb.document(uid).setData([
                        "imageURL": downloadURL.absoluteString
                    ], merge: true)
                    self.saveToRealm(uid: uid, values: values, imageURL: downloadURL)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    func saveToRealm(uid: String, values: [String : Any?], imageURL: URL) {
        let realm = try! Realm()
        let UserData = realm.objects(RealmUserModel.self)
        if let UserData = UserData.first {
            try! realm.write {
                UserData.name = values["name"] as! String
                UserData.imageURL = imageURL.absoluteString
                UserData.profImage = (values["profImage"] as! UIImage).scaledToSafeUploadSize!.jpegData(compressionQuality: 0.1)!
                UserData.motherLanguage = Language.fromString(string: values["motherLanguage"] as! String).rawValue
                UserData.secondLanguage = Language.fromString(string: values["secondLanguage"] as! String).rawValue
                UserData.updatedAt = Date()
            }
        }
    }

    func saveToFirestore(uid: String, values: [String : Any?]) {
        self.Usersdb.document(uid).setData([
            "name": values["name"] as! String,
            "motherLanguage": Language.fromString(string: values["motherLanguage"] as! String).rawValue,
            "secondLanguage": Language.fromString(string: values["secondLanguage"] as! String).rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}
