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
    @IBOutlet weak var facebookButton: FBLoginButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
        facebookButton.delegate = self
        LoginManager().logOut()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        startIndicator()
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            guard let self = self else { return }
            if let _result = result {
                if _result.additionalUserInfo!.isNewUser {
                    self.showErrorAlert(message: self.LString("You have not registered yet"))
                    Auth.auth().currentUser?.delete { error in
                        if let error = error {
                            self.showError(error)
                        } else {
                          // Account deleted.
                        }
                    }
                    LoginManager().logOut()
                    self.stopIndicator()
                    return
                } else {
                    self.showLogInCompletion()
                }
            }
            self.stopIndicator()
            self.showError(error)
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
}
