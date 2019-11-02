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

class registerProfViewController: FormViewController {

    public final class DetailedButtonRowOf<T: Equatable> : _ButtonRowOf<T>, RowType {
        public required init(tag: String?) {
            super.init(tag: tag)
            cellStyle = .value1
        }
    }
    public typealias DetailedButtonRow = DetailedButtonRowOf<String>

    var email: String?
    var password: String?
    @IBOutlet weak var saveButton: UIBarButtonItem!
    let Usersdb = Firestore.firestore().collection("Users")
    let UserData: RealmUserModel = RealmUserModel()
    let registerBonus: Int = 30
    var secondLanguage: Int = 0
    var level: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true

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

        <<< PushRow<String> {
            $0.title = NSLocalizedString("prof_gender", comment: "")
            $0.options = [Gender.Unknown.string(), Gender.Male.string(), Gender.Female.string()]
            $0.tag = "gender"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
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
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< PushRow<String> {
            $0.title = NSLocalizedString("prof_motherLanguage", comment: "")
            $0.options = [Language.Japanese.string(), Language.English.string(), Language.Chinese.string()]
            $0.tag = "motherLanguage"
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
        }.onPresent { form, selectorController in
            selectorController.enableDeselection = false
        }

        <<< DetailedButtonRow {
            $0.title = NSLocalizedString("prof_secondLanguage", comment: "")
            $0.presentationMode = .segueName(segueName: "registerSecondLanguage", onDismiss: nil)
        }.cellUpdate { cell, row in
            cell.height = ({return 80})
            cell.detailTextLabel?.text = Language.strings[self.secondLanguage]+":"+Level.strings[self.level]
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "registerSecondLanguage" {
            let registerSecondLanguageVC = segue.destination as! registerSecondLanguageViewController
            registerSecondLanguageVC.secondLanguage = secondLanguage
            registerSecondLanguageVC.level = level
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
            self.saveImageToStorage(uid: uid, values: values, image: values["profImage"] as! UIImage)
            self.saveToFirestore(uid: uid, values: values)
        }
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
        self.UserData.secondLanguage = self.secondLanguage
        self.UserData.level = self.level
        let realm = try! Realm()
        try! realm.write {
          realm.add(UserData)
            print("added")
        }
    }

    func saveToFirestore(uid: String, values: [String : Any?]) {
        let pointHistoryDB = Usersdb.document(uid).collection("pointHistory")
        self.Usersdb.document(uid).setData([
            "uid": uid,
            "name": values["name"] as! String,
            "gender": Gender.fromString(string: values["gender"] as! String).rawValue,
            "birthDate": Timestamp(date: values["birthDate"] as! Date),
            "isOnline" : true,
            "nationality": Nationality.fromString(string: values["nationality"] as! String).rawValue,
            "motherLanguage": Language.fromString(string: values["motherLanguage"] as! String).rawValue,
            "secondLanguage": self.secondLanguage,
            "level": self.level,
            "ratingAsLearner": 5,
            "ratingAsNative": 5,
            "callCountAsLearner": 1,
            "callCountAsNative": 1,
            "point": self.registerBonus,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "lastLoginBonus": FieldValue.serverTimestamp(),
        ], merge: true)
        pointHistoryDB.document().setData([
            "point": self.registerBonus,
            "method": Method.fromString(string: "ログインボーナス").rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true)
        let alert = SCLAlertView()
        _ = alert.showSuccess("登録ありがとうございます！", subTitle: "P"+String(self.registerBonus)+"を獲得しました！")
    }
}

class LogoViewNib: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class registerSecondLanguageViewController: FormViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    var presentingVC: UIViewController?
    var secondLanguage: Int?
    var level: Int?

    @IBAction func tappedSaveButton(_ sender: Any) {
        let values = form.values()
        let nc = self.navigationController
        let vcNum = nc!.viewControllers.count
        let registerProfVC = nc!.viewControllers[vcNum - 2] as! registerProfViewController
        registerProfVC.secondLanguage = Language.fromString(string: values["secondLanguage"] as! String).rawValue
        if Language.fromString(string: values["secondLanguage"] as! String).rawValue == 0 {
            registerProfVC.level = 0
        } else {
            registerProfVC.level = Level.fromString(string: values["level"] as! String).rawValue
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


