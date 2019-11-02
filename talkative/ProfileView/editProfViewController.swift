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

    public final class DetailedButtonRowOf<T: Equatable> : _ButtonRowOf<T>, RowType {
        public required init(tag: String?) {
            super.init(tag: tag)
            cellStyle = .value1
        }
    }
    public typealias DetailedButtonRow = DetailedButtonRowOf<String>

    let Usersdb = Firestore.firestore().collection("Users")
    let profImagesDirRef = Storage.storage().reference().child("profImages")
    var UserData: RealmUserModel?
    var secondLanguage: Int?
    var level: Int?
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        secondLanguage = getUserData().secondLanguage
        level = getUserData().level
        self.navigationItem.title =  "編集"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.hidesBackButton = false
        form +++ Section(NSLocalizedString("prof_section_base", comment: ""))
        <<< ImageRow {
            $0.title = NSLocalizedString("prof_image", comment: "")
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
            $0.title = NSLocalizedString("prof_name", comment: "")
            $0.value = getUserData().name
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
            $0.value = Language.strings[getUserData().motherLanguage]
            $0.tag = "motherLanguage"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }


        <<< DetailedButtonRow {
            $0.title = NSLocalizedString("prof_secondLanguage", comment: "")
            $0.presentationMode = .segueName(segueName: "selectSecondLanguage", onDismiss: nil)
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
            cell.detailTextLabel?.text = Language.strings[self.secondLanguage!]+":"+Level.strings[self.level!]
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "selectSecondLanguage" {
            let selectSecondLanguageVC = segue.destination as! selectSecondLanguageViewController
            selectSecondLanguageVC.secondLanguage = secondLanguage!
            selectSecondLanguageVC.level = level!
        }
    }

    func validateForm(dict: [String : Any?]) -> Bool {
        for (key, value) in dict {
            if value == nil {
                self.dissmisPreloader()
                SCLAlertView().showError("エラー", subTitle:"未入力項目があります。", closeButtonTitle:"OK")
                return false
            }
        }
        return true
    }

    @IBAction func tappedSaveButton(_ sender: Any) {
        self.showPreloader()
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
                UserData.secondLanguage = self.secondLanguage!
                UserData.level = self.level!
                UserData.updatedAt = Date()
            }
        }
    }

    func saveToFirestore(uid: String, values: [String : Any?]) {
        self.Usersdb.document(uid).setData([
            "name": values["name"] as! String,
            "motherLanguage": Language.fromString(string: values["motherLanguage"] as! String).rawValue,
            "secondLanguage": self.secondLanguage!,
            "level": self.level!,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}


class selectSecondLanguageViewController: FormViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    var presentingVC: UIViewController?
    var secondLanguage: Int?
    var level: Int?

    @IBAction func tappedSaveButton(_ sender: Any) {
        let values = form.values()
        let nc = self.navigationController
        let vcNum = nc!.viewControllers.count
        let editProfVC = nc!.viewControllers[vcNum - 2] as! editProfViewController
        editProfVC.secondLanguage = Language.fromString(string: values["secondLanguage"] as! String).rawValue
        if Language.fromString(string: values["secondLanguage"] as! String).rawValue == 0 {
            editProfVC.level = 0
        } else {
            editProfVC.level = Level.fromString(string: values["level"] as! String).rawValue
        }
        if Language.fromString(string: values["secondLanguage"] as! String).rawValue != 0 &&
            Level.fromString(string: values["level"] as! String).rawValue == 0 {
            SCLAlertView().showError("エラー", subTitle:"レベルを選択してください。", closeButtonTitle:"OK")
            return
        }
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title =  "編集"
        self.navigationItem.hidesBackButton = true

        form
        +++ Section(NSLocalizedString("prof_secondLanguage", comment: ""))

        <<< PushRow<String> {
            $0.title = NSLocalizedString("prof_secondLanguage", comment: "")
            $0.options = [Language.Unknown.string(), Language.Japanese.string(), Language.English.string(), Language.Chinese.string()]
            $0.value = Language.strings[self.secondLanguage!]
            $0.tag = "secondLanguage"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< PushRow<String> {
            $0.title = "Level"
            $0.options = [Level.Unknown.string(), Level.Beginner.string(), Level.PreIntermediate.string(), Level.Intermediate.string(), Level.PreAdvanced.string(), Level.Advanced.string()]
            $0.value = Level.strings[self.level!]
            $0.tag = "level"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }
    }
}
