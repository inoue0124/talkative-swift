//
//  File.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftGifOrigin

class nativeDetailViewController: UIViewController {

    var native: UserModel?
    var offer: OfferModel?
    var selectedChatroom: ChatroomModel?
    @IBOutlet weak var NativeThumbnail: UIImageView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    let usersDb = Firestore.firestore().collection("Users")
    let chatroomsDb = Firestore.firestore().collection("chatrooms")


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Buttonが画面の中央で横幅いっぱいのサイズになるように設定
        callButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        callButton.imageView?.contentMode = .scaleAspectFit
        callButton.contentHorizontalAlignment = .fill
        callButton.contentVerticalAlignment = .fill
        callButton.layer.backgroundColor = UIColor.green.cgColor
        callButton.layer.cornerRadius = 20
        messageButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        messageButton.imageView?.contentMode = .scaleAspectFit
        messageButton.contentHorizontalAlignment = .fill
        messageButton.contentVerticalAlignment = .fill
        messageButton.layer.backgroundColor = UIColor.blue.cgColor
        messageButton.layer.cornerRadius = 20
        messageButton.isEnabled = false
        self.NativeThumbnail.image = UIImage.gif(name: "Preloader")
        DispatchQueue.global().async {
            let image = UIImage(url: self.offer!.nativeImageURL)
            DispatchQueue.main.async {
                self.NativeThumbnail.image = image
                self.NativeThumbnail.layer.cornerRadius = 50
            }
        }
        self.usersDb.whereField("uid", isEqualTo: self.offer!.nativeID).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else if querySnapshot!.documents.isEmpty {
                    print("user is not exist")
                } else {
                    print("user is exist")
                    print(querySnapshot!.documents)
                    self.native = UserModel(from: querySnapshot!.documents[0])
                    self.navigationItem.title = self.native!.name
                    self.chatroomsDb.whereField("nativeID", isEqualTo: self.native!.uid).whereField("learnerID", isEqualTo: self.getUserUid()).getDocuments() { (querySnapshot, err) in
                            if let _err = err {
                                print("\(_err)")
                            } else if querySnapshot!.documents.isEmpty {
                                print("chatroom is not exist")
                                self.selectedChatroom = ChatroomModel(chatroomID: self.chatroomsDb.document().documentID, nativeID: self.native!.uid, nativeName: self.native!.name, nativeImageURL: self.native!.imageURL, learnerID: self.getUserUid(), learnerName: self.getUserData().name, learnerImageURL: URL(string: self.getUserData().imageURL)!)
                                self.messageButton.isEnabled = true
                            } else {
                                print("chatroom is exist")
                                self.selectedChatroom = ChatroomModel(from: querySnapshot!.documents[0])
                                self.messageButton.isEnabled = true
                            }
                    }
                }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func tappedCallButton(_ sender: Any) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.tabBarController!.selectedIndex = 3
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("alert_confirm_payment_title", comment: ""),
                                                        message: String(format: NSLocalizedString("alert_confirm_payment_message", comment: ""), self.offer!.offerPrice,self.offer!.offerTime), preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.performSegue(withIdentifier: "show_media", sender: nil)
                    }
                })
                let cancelAction = UIAlertAction(title: NSLocalizedString("alert_cancel", comment: ""), style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                    return
                })
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    @IBAction func tappedMessageButton(_ sender: Any) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.tabBarController!.selectedIndex = 3
            } else {
                self.performSegue(withIdentifier: "show_chatroom", sender: nil)
            }
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "show_media" {
            if (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey == nil || (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain == nil{
                UIAlertController.oneButton("エラー", message: "APIKEYかDOMAINが設定されていません", handler: nil)
            } else {
                let callVC = segue.destination as! callingViewController
                callVC.offer = self.offer!
            }
        }
        if segue.identifier == "show_chatroom" {
            let chatroomVC = segue.destination as! ChatroomViewController
            chatroomVC.chatroom = self.selectedChatroom
            chatroomVC.avatarImage = self.NativeThumbnail.image
        }
    }
}

