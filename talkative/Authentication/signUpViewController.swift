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
        self.emailTextField.placeholder = LString("EMAIL")
        self.passwordTextField.placeholder = LString("PASSWORD")
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
                self.performSegue(withIdentifier: "toRegisterProfView", sender: nil)
            }
            self.dissmisPreloader()
            self.showError(error)
        }
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRegisterProfView" {
            let RegisterProfVC = segue.destination as! registerProfViewController
            RegisterProfVC.email = self.email!
        }
    }
}

