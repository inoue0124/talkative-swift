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
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.signUpButton.setTitle(NSLocalizedString("signUp", comment: ""), for: .normal)
        self.emailTextField.placeholder = NSLocalizedString("placeholder_email", comment: "")
        self.passwordTextField.placeholder = NSLocalizedString("placeholder_password", comment: "")
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
            }
            try! realm.write {
              realm.add(RealmUserModel())
            }
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self else { return }
                if let user = result?.user {
                    self.showSignUpCompletion()
                }
                self.showError(error)
            }
        }

        private func showSignUpCompletion() {
            performSegue(withIdentifier: "showRegisterView", sender: nil)
        }
}

