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

    let Usersdb = Firestore.firestore().collection("Users")

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.emailTextField.placeholder = LString("EMAIL")
        self.passwordTextField.placeholder = LString("PASSWORD")
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction private func didTapSignInButton() {
        self.showPreloader()
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                self.showLogInCompletion()
            }
            self.dissmisPreloader()
            self.showError(error)
        }
    }

    private func showLogInCompletion() {
        let uid = String(describing: Auth.auth().currentUser?.uid ?? "Error")
        self.Usersdb.whereField("uid", isEqualTo: uid).getDocuments() { snapshot, error in
            if let _error = error {
                self.showError(_error)
                return
            }
            guard let documents = snapshot?.documents else {
            return
            }
            let downloadedUserData = documents.map{ UserModel(from: $0) }
            if !downloadedUserData.isEmpty {
                let UserData: RealmUserModel = RealmUserModel()
                UserData.uid = downloadedUserData[0].uid
                UserData.name = downloadedUserData[0].name
                UserData.imageURL = downloadedUserData[0].imageURL.absoluteString
                UserData.profImage = UIImage(url: downloadedUserData[0].imageURL).jpegData(compressionQuality: 1.0)!
                UserData.gender = downloadedUserData[0].gender
                UserData.birthDate = downloadedUserData[0].birthDate
                UserData.isRegisteredProf = true
                UserData.createdAt = downloadedUserData[0].createdAt
                UserData.updatedAt = downloadedUserData[0].updatedAt
                UserData.nationality = downloadedUserData[0].nationality
                UserData.motherLanguage = downloadedUserData[0].motherLanguage
                UserData.secondLanguage = downloadedUserData[0].secondLanguage
                UserData.proficiency = downloadedUserData[0].proficiency
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                }
                try! realm.write {
                  realm.add(UserData)
                }
                self.performSegue(withIdentifier: "toMain", sender: nil)
            } else {
                self.performSegue(withIdentifier: "toRegisterProfView", sender: nil)
            }
        }
    }
}
