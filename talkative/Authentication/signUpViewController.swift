//
//  loginViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class signUpViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.placeholder = "メールアドレス"
        self.passwordTextField.placeholder = "パスワード"
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.isHidden = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

        @IBAction private func didTapSignUpButton() {
            let realm = try! Realm()
           try! realm.write {
               realm.deleteAll()
           }
            let email = emailTextField.text ?? ""
            let password = passwordTextField.text ?? ""
            signUp(email: email, password: password)
        }

        private func signUp(email: String, password: String) {
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
                print("deleted")
            }
            try! realm.write {
              realm.add(RealmUserModel())
                print("added")
            }
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self else { return }
                if let user = result?.user {
//                    self.sendEmailVerification(to: user)
                    self.showSignUpCompletion()
                }
                self.showError(error)
            }
        }

        private func sendEmailVerification(to user: User) {
            user.sendEmailVerification() { [weak self] error in
                guard let self = self else { return }
                if error != nil {
                    self.showSignUpCompletion()
                }
                self.showError(error)
            }
        }

        private func showSignUpCompletion() {
            performSegue(withIdentifier: "showRegisterView", sender: nil)
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
}

