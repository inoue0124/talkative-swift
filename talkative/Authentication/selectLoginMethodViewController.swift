//
//  selectMethodViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/24.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FBSDKLoginKit
import FirebaseAuth
import RealmSwift

class selectLoginMethodViewController: UIViewController, LoginButtonDelegate {

    let Usersdb = Firestore.firestore().collection("Users")
    @IBOutlet weak var facebookButton: FBLoginButton!

    override func viewWillAppear(_ animated: Bool) {
        facebookButton.delegate = self
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
    }

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            self.showError(error)
            return
        }
        if result!.isCancelled {
            return
        }
        self.showPreloader()
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { [weak self] result, error in
          guard let self = self else { return }
              if let user = result?.user {
                  self.showLogInCompletion()
              }
              self.dissmisPreloader()
              self.showError(error)
          }
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
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
                UserData.profImage = UIImage(url: downloadedUserData[0].imageURL).jpegData(compressionQuality: 1.0)!
                UserData.imageURL = downloadedUserData[0].imageURL.absoluteString
                UserData.name = downloadedUserData[0].name
                UserData.gender = downloadedUserData[0].gender
                UserData.birthDate = downloadedUserData[0].birthDate
                UserData.isRegisteredProf = true
                UserData.nationality = downloadedUserData[0].nationality
                UserData.motherLanguage = downloadedUserData[0].motherLanguage
                UserData.secondLanguage = downloadedUserData[0].secondLanguage
                UserData.proficiency = downloadedUserData[0].proficiency
                UserData.ratingAsLearner = downloadedUserData[0].ratingAsLearner
                UserData.ratingAsNative = downloadedUserData[0].ratingAsNative
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
