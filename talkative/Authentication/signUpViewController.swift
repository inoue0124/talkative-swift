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
    var email: String?
    var password: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.placeholder = LString("EMAIL")
        passwordTextField.placeholder = LString("PASSWORD")
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction private func didTapSignUpButton() {
        email = emailTextField.text ?? ""
        password = passwordTextField.text ?? ""
        signUp(email: self.email!, password: self.password!)
    }

    private func signUp(email: String, password: String) {
        startIndicator()
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                self.performSegue(withIdentifier: "toRegisterProfView", sender: nil)
            }
            self.stopIndicator()
            self.showError(error)
        }
    }
}

