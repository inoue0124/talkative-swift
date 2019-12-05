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

class selectRegisterMethodViewController: UIViewController, LoginButtonDelegate {
    @IBOutlet weak var facebookButton: FBLoginButton!

    override func viewWillAppear(_ animated: Bool) {
        facebookButton.delegate = self
        LoginManager().logOut()
        super.viewWillAppear(animated)
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController!.navigationBar.shadowImage = nil
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
                    self.performSegue(withIdentifier: "toRegisterProfView", sender: nil)
                } else {
                    self.showErrorAlert(message: self.LString("Already have an account"))
                    LoginManager().logOut()
                }
            }
            self.stopIndicator()
            self.showError(error)
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
}
