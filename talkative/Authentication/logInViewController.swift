//
//  signInViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import FirebaseFirestore

class logInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet weak var backButton: UIBarButtonItem!
    let Usersdb = Firestore.firestore().collection("Users")

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.hidesBackButton = true
        tabBarController?.tabBar.isHidden = true
        self.emailTextField.placeholder = "メールアドレス"
        self.passwordTextField.placeholder = "パスワード"
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction private func didTapSignInButton() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                self.showLogInCompletion()
            }
            self.showError(error)
        }
    }

    private func showLogInCompletion() {
        let uid = String(describing: Auth.auth().currentUser?.uid ?? "Error")
        self.Usersdb.whereField("uid", isEqualTo: uid).addSnapshotListener() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("error")
            return
            }
            let downloadedUserData = documents.map{ UserModel(from: $0) }
            let UserData: RealmUserModel = RealmUserModel()
            UserData.uid = downloadedUserData[0].uid
            UserData.name = downloadedUserData[0].name
            UserData.imageURL = downloadedUserData[0].imageURL.absoluteString
            UserData.gender = downloadedUserData[0].gender
            UserData.birthDate = downloadedUserData[0].birthDate
            UserData.isWroteProf = true
            UserData.createdAt = downloadedUserData[0].createdAt
            UserData.updatedAt = downloadedUserData[0].updatedAt
            UserData.nationality = downloadedUserData[0].nationality
            UserData.motherLanguage = downloadedUserData[0].motherLanguage
            UserData.secondLanguage = downloadedUserData[0].secondLanguage
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
                print("deleted")
            }
            try! realm.write {
              realm.add(UserData)
                print("added")
            }
        }
        self.navigationController?.popViewController(animated: true)
    }

    private func showError(_ errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        let message = errorMessage(of: error)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func errorMessage(of error: Error) -> String {
        var message = "エラーが発生しました"
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }

        switch errcd {
        case .networkError: message = "ネットワークに接続できません"
        case .userNotFound: message = "ユーザが見つかりません"
        case .invalidEmail: message = "不正なメールアドレスです"
        case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
        case .wrongPassword: message = "入力した認証情報でサインインできません"
        case .userDisabled: message = "このアカウントは無効です"
        case .weakPassword: message = "パスワードが脆弱すぎます"
        default: break
        }
        return message
    }

    @IBAction func tappedBackButton(_ sender: Any) {
        self.tabBarController!.selectedIndex = 0
    }

}
