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

class nativeDetailViewController: UIViewController {

    var native: UserModel?
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
            let image = UIImage(url: self.offer!.nativeImageURL)
            DispatchQueue.main.async {
                self.NativeThumbnail.image = image
                self.NativeThumbnail.layer.cornerRadius = 50
            }
        }
        self.navigationItem.title = self.offer!.nativeName
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.name.text = self.offer!.nativeName
        self.rating.text = String(format: "%.1f", self.offer!.nativeRating)
        self.usersDb.whereField("uid", isEqualTo: self.offer!.nativeID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if querySnapshot!.documents.isEmpty {
                print("user is not exist")
            } else {
                print("user is exist")
                print(querySnapshot!.documents)
                self.native = UserModel(from: querySnapshot!.documents[0])
                self.motherLanguage.text = Language.strings[self.native!.motherLanguage]
                self.secondLanguage.text = Language.strings[self.native!.secondLanguage]
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
        self.usersDb.whereField("uid", isEqualTo: getUserUid()).getDocuments() { snapshot, error in
            if let _error = error {
                self.showError(_error)
                return
            }
            guard let documents = snapshot?.documents else {
            return
            }
            let downloadedUserData = documents.map{ UserModel(from: $0) }
            if downloadedUserData[0].point - Double(self.offer!.offerPrice) < 0.0 {
                SCLAlertView().showError(self.LString("Oops"), subTitle: String(format: self.LString("Your have not enough points teach...") , Language.strings[self.getUserData().motherLanguage]), closeButtonTitle: self.LString("OK"))
                return
            }
            let alert = SCLAlertView()
            alert.addButton(self.LString("OK")) { self.performSegue(withIdentifier: "show_media", sender: nil) }
            alert.showInfo(self.LString("Confirm payment"),
                           subTitle: String(format: self.LString("Pay %d points and talk %d minutes"), self.offer!.offerPrice,self.offer!.offerTime))
        }
    }

    @IBAction func tappedMessageButton(_ sender: Any) {
        self.performSegue(withIdentifier: "show_chatroom", sender: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "show_media" {
            if (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey == nil || (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain == nil{
                UIAlertController.oneButton(LString("Error"), message: "APIKEY or DOMAIN are not set", handler: nil)
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

