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
    var email: String?
    var password: String?
    

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
        self.email = emailTextField.text ?? ""
        self.password = passwordTextField.text ?? ""
        self.signUp(email: self.email!, password: self.password!)
    }

    private func signUp(email: String, password: String) {
        self.showPreloader()
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                //self.sendEmailVerification(to: _user)
                self.performSegue(withIdentifier: "toRegisterProfView", sender: nil)
            }
            self.dissmisPreloader()
            self.showError(error)
        }
    }

    private func sendEmailVerification(to user: User) {
        user.sendEmailVerification() { [weak self] error in
            guard let self = self else { return }
            if error != nil {
            }
            self.showError(error)
        }
    }
}

