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
import XLPagerTabStrip

class learnerDetailViewController: UIViewController, IndicatorInfoProvider {

    var offer: OfferModel?
    var user: UserModel?
    let disableColor: UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    let titleColor: UIColor = UIColor(red: 90/255, green: 84/255, blue: 75/255, alpha: 1)
    @IBOutlet weak var rating: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
//        if user!.isOffering {
//            enableCallButton()
//        }
        self.rating.text = String(format: "%.1f", user!.ratingAsLearner)
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "As Learner")
    }
}

//class learnerDetailViewController: UIViewController, IndicatorInfoProvider {
//
//    var learner: UserModel?
//    var offer: OfferModel?
//    var selectedChatroom: ChatroomModel?
//    @IBOutlet weak var NativeThumbnail: UIImageView!
//    @IBOutlet weak var callButton: UIButton!
//    @IBOutlet weak var messageButton: UIButton!
//    let usersDb = Firestore.firestore().collection("Users")
//    let chatroomsDb = Firestore.firestore().collection("chatrooms")
//    @IBOutlet weak var motherLanguage: UILabel!
//    @IBOutlet weak var secondLanguage: UILabel!
//    @IBOutlet weak var rating: UILabel!
//    @IBOutlet weak var name: UILabel!
//    @IBOutlet weak var proficiency: UIImageView!
//    @IBOutlet weak var nationalFlag: UIImageView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        callButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//        callButton.imageView?.contentMode = .scaleAspectFit
//        callButton.contentHorizontalAlignment = .fill
//        callButton.contentVerticalAlignment = .fill
//        callButton.layer.backgroundColor = UIColor.green.cgColor
//        callButton.layer.cornerRadius = 20
//        callButton.isEnabled = false
//        if offer!.isOnline {
//            callButton.isEnabled = true
//        }
//        messageButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//        messageButton.imageView?.contentMode = .scaleAspectFit
//        messageButton.contentHorizontalAlignment = .fill
//        messageButton.contentVerticalAlignment = .fill
//        messageButton.layer.backgroundColor = UIColor.blue.cgColor
//        messageButton.layer.cornerRadius = 20
//        messageButton.isEnabled = false
//        DispatchQueue.global().async {
//            let image = UIImage(url: self.learner!.imageURL)
//            DispatchQueue.main.async {
//                self.NativeThumbnail.image = image
//                self.NativeThumbnail.layer.cornerRadius = 50
//            }
//        }
//        self.makeFlagImageView(imageView: self.nationalFlag, nationality: learner!.nationality, radius: 12.5)
//        self.navigationItem.title = self.learner!.name
//        self.navigationItem.largeTitleDisplayMode = .never
//        self.name.text = self.learner!.name
//        self.rating.text = String(format: "%.1f", self.learner!.ratingAsLearner)
//        self.motherLanguage.text = Language.strings[self.learner!.motherLanguage]
//        self.secondLanguage.text = Language.strings[self.learner!.secondLanguage]
//        self.proficiency.image = UIImage(named: String(self.learner!.proficiency))
//        self.chatroomsDb.whereField("viewableUserIDs." + self.getUserUid(), isEqualTo: true).whereField("viewableUserIDs." + self.learner!.uid, isEqualTo: true).getDocuments() { (querySnapshot, err) in
//            if let _err = err {
//                print("\(_err)")
//            } else if querySnapshot!.documents.isEmpty {
//                print("chatroom is not exist")
//                self.selectedChatroom = ChatroomModel(chatroomID: self.chatroomsDb.document().documentID, viewableUserIDs: [self.getUserUid():true, self.learner!.uid:true])
//                self.messageButton.isEnabled = true
//            } else {
//                print("chatroom is exist")
//                self.selectedChatroom = ChatroomModel(from: querySnapshot!.documents[0])
//                self.messageButton.isEnabled = true
//            }
//        }
//    }
//
//    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
//        return IndicatorInfo(title: "As Learner")
//    }
//
//    @IBAction func tappedMessageButton(_ sender: Any) {
//        self.performSegue(withIdentifier: "show_chatroom", sender: nil)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
//        if segue.identifier == "show_media" {
//            if (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey == nil || (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain == nil{
//                UIAlertController.oneButton("エラー", message: "APIKEYかDOMAINが設定されていません", handler: nil)
//            } else {
//                let callVC = segue.destination as! teachCallingViewController
//                callVC.offer = self.offer!
//            }
//        }
//        if segue.identifier == "show_chatroom" {
//            let chatroomVC = segue.destination as! ChatroomViewController
//            chatroomVC.chatroom = self.selectedChatroom
//            chatroomVC.avatarImage = self.NativeThumbnail.image
//        }
//    }
//}
//
