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

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(false, animated: false)
        emailTextField.placeholder = LString("EMAIL")
        passwordTextField.placeholder = LString("PASSWORD")
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction private func didTapSignInButton() {
        startIndicator()
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                self.showLogInCompletion()
            }
            self.stopIndicator()
            self.showError(error)
        }
    }
}

extension UIViewController {
    func showLogInCompletion() {
        let usersDB = Firestore.firestore().collection("Users")
        let uid = String(describing: Auth.auth().currentUser?.uid ?? "Error")
        usersDB.whereField("uid", isEqualTo: uid).getDocuments() { snapshot, error in
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
                UserData.profImage = UIImage(url: downloadedUserData[0].imageURL).jpegData(compressionQuality: 1.0)!
                UserData.imageURL = downloadedUserData[0].imageURL.absoluteString
                UserData.name = downloadedUserData[0].name
                UserData.gender = downloadedUserData[0].gender
                UserData.birthDate = downloadedUserData[0].birthDate
                UserData.nationality = downloadedUserData[0].nationality
                UserData.proficiency = downloadedUserData[0].proficiency
                UserData.ratingAsLearner = downloadedUserData[0].ratingAsLearner
                UserData.ratingAsNative = downloadedUserData[0].ratingAsNative
                UserData.callCountAsLearner = downloadedUserData[0].callCountAsLearner
                UserData.callCountAsNative = downloadedUserData[0].callCountAsNative
                UserData.studyLanguage = downloadedUserData[0].studyLanguage
                UserData.teachLanguage = downloadedUserData[0].teachLanguage
                UserData.createdAt = downloadedUserData[0].createdAt
                UserData.updatedAt = downloadedUserData[0].updatedAt
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
