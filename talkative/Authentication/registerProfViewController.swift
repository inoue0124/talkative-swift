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

class registerProfViewController: FormViewController {

    var email: String?
    var password: String?
    @IBOutlet weak var saveButton: UIBarButtonItem!
    let Usersdb = Firestore.firestore().collection("Users")
    let UserData: RealmUserModel = RealmUserModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section() {
            let header = HeaderFooterView<LogoViewNib>(.nibFile(name: "registerProfViewHeader", bundle: nil))
            $0.header = header
        }

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

        <<< AlertRow<String> {
            $0.title = NSLocalizedString("prof_gender", comment: "")
            $0.options = [Gender.Unknown.string(), Gender.Male.string(), Gender.Female.string()]
            $0.tag = "gender"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }

        <<< DateRow {
            $0.title = NSLocalizedString("prof_birthDate", comment: "")
            $0.tag = "birthDate"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }

        <<< PushRow<String> {
            $0.title = NSLocalizedString("prof_nationality", comment: "")
            $0.options = [Nationality.Japanese.string(), Nationality.American.string(), Nationality.Chinese.string()]
            $0.tag = "nationality"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }

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
                    self.performSegue(withIdentifier: "toMain", sender: nil)
                }
            }
        }
    }

    func saveToRealm(uid: String, values: [String : Any?], imageURL: URL) {
        self.UserData.uid = uid
        self.UserData.name = values["name"] as! String
        self.UserData.imageURL = imageURL.absoluteString
        self.UserData.profImage = (values["profImage"] as! UIImage).scaledToSafeUploadSize!.jpegData(compressionQuality: 0.1)!
        self.UserData.gender = Gender.fromString(string: values["gender"] as! String).rawValue
        self.UserData.birthDate = values["birthDate"] as! Date
        self.UserData.isRegisteredProf = true
        self.UserData.createdAt = Date()
        self.UserData.updatedAt = Date()
        self.UserData.nationality = Nationality.fromString(string: values["nationality"] as! String).rawValue
        self.UserData.motherLanguage = Language.fromString(string: values["motherLanguage"] as! String).rawValue
        self.UserData.secondLanguage = Language.fromString(string: values["secondLanguage"] as! String).rawValue
        let realm = try! Realm()
        try! realm.write {
          realm.add(UserData)
            print("added")
        }
    }

    func saveToFirestore(uid: String, values: [String : Any?]) {
        self.Usersdb.document(uid).setData([
            "uid": uid,
            "name": values["name"] as! String,
            "gender": Gender.fromString(string: values["gender"] as! String).rawValue,
            "birthDate": Timestamp(date: values["birthDate"] as! Date),
            "isOnline" : true,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "nationality": Nationality.fromString(string: values["nationality"] as! String).rawValue,
            "motherLanguage": Language.fromString(string: values["motherLanguage"] as! String).rawValue,
            "secondLanguage": Language.fromString(string: values["secondLanguage"] as! String).rawValue
        ], merge: true)
    }
}

class LogoViewNib: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

