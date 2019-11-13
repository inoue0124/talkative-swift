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
import SCLAlertView

class teachLearnerDetailViewController: UIViewController {

    var learner: UserModel?
    var offer: OfferModel?
    var selectedChatroom: ChatroomModel?
    @IBOutlet weak var NativeThumbnail: UIImageView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    let usersDb = Firestore.firestore().collection("Users")
    let chatroomsDb = Firestore.firestore().collection("chatrooms")
    @IBOutlet weak var motherLanguage: UILabel!
    @IBOutlet weak var secondLanguage: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var level: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        callButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        callButton.imageView?.contentMode = .scaleAspectFit
        callButton.contentHorizontalAlignment = .fill
        callButton.contentVerticalAlignment = .fill
        callButton.layer.backgroundColor = UIColor.green.cgColor
        callButton.layer.cornerRadius = 20
        callButton.isEnabled = false
        if offer!.isOnline {
            callButton.isEnabled = true
        }
        messageButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        messageButton.imageView?.contentMode = .scaleAspectFit
        messageButton.contentHorizontalAlignment = .fill
        messageButton.contentVerticalAlignment = .fill
        messageButton.layer.backgroundColor = UIColor.blue.cgColor
        messageButton.layer.cornerRadius = 20
        messageButton.isEnabled = false
        self.NativeThumbnail.image = UIImage.gif(name: "Preloader")
        DispatchQueue.global().async {
            let image = UIImage(url: self.offer!.learnerImageURL)
            DispatchQueue.main.async {
                self.NativeThumbnail.image = image
                self.NativeThumbnail.layer.cornerRadius = 50
            }
        }
        self.navigationItem.title = self.offer!.learnerName
        self.navigationItem.largeTitleDisplayMode = .never
        self.name.text = self.offer!.learnerName
        self.rating.text = String(format: "%.1f", self.offer!.learnerRating)
        self.usersDb.whereField("uid", isEqualTo: self.offer!.learnerID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if querySnapshot!.documents.isEmpty {
                print("user is not exist")
            } else {
                print("user is exist")
                print(querySnapshot!.documents)
                self.learner = UserModel(from: querySnapshot!.documents[0])
                self.motherLanguage.text = Language.strings[self.learner!.motherLanguage]
                self.secondLanguage.text = Language.strings[self.learner!.secondLanguage]
                self.level.image = UIImage(named: String(self.learner!.level))
                self.chatroomsDb.whereField("viewableUserIDs", arrayContains: self.getUserUid()).getDocuments() { (querySnapshot, err) in
                    if let _err = err {
                        print("\(_err)")
                    } else if querySnapshot!.documents.isEmpty {
                        print("chatroom is not exist")
                        self.selectedChatroom = ChatroomModel(chatroomID: self.chatroomsDb.document().documentID, viewableUserIDs: [self.getUserUid(), self.learner!.uid])
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


//    @IBAction func tappedCallButton(_ sender: Any) {
//        self.usersDb.whereField("uid", isEqualTo: getUserUid()).getDocuments() { snapshot, error in
//            if let _error = error {
//                self.showError(_error)
//                return
//            }
//            guard let documents = snapshot?.documents else {
//            return
//            }
//            let downloadedUserData = documents.map{ UserModel(from: $0) }
//            if downloadedUserData[0].point-self.offer!.offerPrice < 0 {
//                SCLAlertView().showError("残念。。", subTitle:"ポイントが足りないようです。Talkative-nativeで"+Language.strings[self.getUserData().motherLanguage]+"を教えて、ポイントを貰おう！", closeButtonTitle:"OK")
//                return
//            }
//            let alert = SCLAlertView()
//            alert.addButton(NSLocalizedString("alert_ok", comment: "")) { self.performSegue(withIdentifier: "show_media", sender: nil) }
//            alert.showInfo(NSLocalizedString("alert_confirm_payment_title", comment: ""),
//                                    subTitle: String(format: NSLocalizedString("alert_confirm_payment_message", comment: ""), self.offer!.offerPrice,self.offer!.offerTime))
//        }
//    }

    @IBAction func tappedMessageButton(_ sender: Any) {
        self.performSegue(withIdentifier: "show_chatroom", sender: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "show_media" {
            if (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey == nil || (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain == nil{
                UIAlertController.oneButton("エラー", message: "APIKEYかDOMAINが設定されていません", handler: nil)
            } else {
                let callVC = segue.destination as! teachCallingViewController
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

