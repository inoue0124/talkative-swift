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
                self.dissmisPreloader()
                self.performSegue(withIdentifier: "toRegisterProfView", sender: nil)
            }
            self.dissmisPreloader()
            self.showError(error)
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }


    @IBOutlet weak var facebookButton: FBLoginButton!

    override func viewWillAppear(_ animated: Bool) {
        facebookButton.delegate = self
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController!.navigationBar.shadowImage = nil
    }
}
