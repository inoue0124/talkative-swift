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

class userDetailViewController: ButtonBarPagerTabStripViewController {

    var user: UserModel?
    var offer: OfferModel?
    var unpaidOffer: OfferModel?
    var chatroom: ChatroomModel?
    let usersDB = Firestore.firestore().collection("Users")
    let pointsDB = Firestore.firestore().collection("points")
    let offersDB = Firestore.firestore().collection("offers")
    let chatroomsDB = Firestore.firestore().collection("chatrooms")
    var isFollowing: Bool?
    var isUnpaid: Bool?
    var isMuteVideo = false
    var tabIndex: Int?
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var genderIcon: UIImageView!
    @IBOutlet weak var motherLanguage: UILabel!
    @IBOutlet weak var secondLanguage: UILabel!
    @IBOutlet weak var proficiency: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!
    @IBOutlet weak var callMethodView: UIView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var offerTime: UILabel!
    @IBOutlet weak var teachStyle: UILabel!
    @IBOutlet weak var teachStyleImage: UIImageView!

    override func viewDidLoad() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tabBarController?.tabBar.isHidden = true
        name.text = user?.name
        age.text = String(self.birthDateToAge(byBirthDate: user!.birthDate))
        setGenderIcon(gender: user?.gender, imageView: genderIcon)
        motherLanguage.text = Language.strings[user!.teachLanguage]
        secondLanguage.text = Language.strings[user!.studyLanguage]
        proficiency.image = UIImage(named: String(user!.proficiency))
        setImage(uid: user!.uid, imageView: self.thumbnail)
        thumbnail.layer.cornerRadius = 50
        makeFlagImageView(imageView: nationalFlag, nationality: user!.nationality, radius: 12.5)
        getOfferData()
        setupTabDesign()
        setupButtonDesign()
        setupChatroom()
        setupFollowButton()
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.moveToViewController(at: self.tabIndex!, animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    func setupTabDesign() {
        if #available(iOS 13.0, *) {
            settings.style.buttonBarBackgroundColor = UIColor.systemBackground
            settings.style.buttonBarItemBackgroundColor = UIColor.systemBackground
            settings.style.buttonBarItemTitleColor = UIColor.label
        } else {
            settings.style.buttonBarBackgroundColor = .white
            settings.style.buttonBarItemBackgroundColor = .white
            settings.style.buttonBarItemTitleColor = .black
        }
        settings.style.selectedBarBackgroundColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            if #available(iOS 13.0, *) {
                oldCell?.label.textColor = UIColor.label
            } else {
                oldCell?.label.textColor = .black
            }
            newCell?.label.textColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
        }
    }

    func setupButtonDesign() {
        let disableColor: UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        let titleColor: UIColor = UIColor(red: 90/255, green: 84/255, blue: 75/255, alpha: 1)
        messageButton.isEnabled = false
        messageButton.setTitleColor(titleColor, for: .normal)
        messageButton.layer.borderColor = UIColor.gray.cgColor
        messageButton.layer.borderWidth = 0.5
        messageButton.backgroundColor = disableColor
        callButton.isEnabled = false
        videoButton.isEnabled = false
        callMethodView.backgroundColor = .white
        callMethodView.layer.cornerRadius = 10
        callMethodView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        callMethodView.layer.shadowColor = UIColor.lightGray.cgColor
        callMethodView.layer.shadowOpacity = 0.3
        callMethodView.layer.shadowRadius = 8
    }

    func setupChatroom() {
        chatroomsDB.whereField("viewableUserIDs." + self.getUserUid(), isEqualTo: true).whereField("viewableUserIDs." + user!.uid, isEqualTo: true).getDocuments() { (querySnapshot, err) in
            if let _err = err {
                print(_err)
            } else if querySnapshot!.documents.isEmpty {
                self.chatroom = ChatroomModel(chatroomID: self.chatroomsDB.document().documentID, viewableUserIDs: [self.getUserUid(): true, self.user!.uid: true], viewableUserNames: [self.getUserUid(): self.getUserData().name, self.user!.uid: self.user!.name])
                self.chatroomsDB.document(self.chatroom!.chatroomID).setData(["chatroomID": self.chatroom!.chatroomID,
                                                                              "senderID": self.getUserUid(),
                                                                              "viewableUserIDs": [self.getUserUid(): true, self.user!.uid: true],
                                                                              "viewableUserNames": [self.getUserUid(): self.getUserData().name, self.user!.uid: self.user!.name]
                ])
            } else {
                self.chatroom = ChatroomModel(from: querySnapshot!.documents[0])
            }
            self.messageButton.isEnabled = true
            self.messageButton.backgroundColor = UIColor(red: 56/255, green: 180/255, blue: 139/255, alpha: 1)
            self.messageButton.setTitleColor(UIColor.white, for: .normal)
        }
    }

    func setupFollowButton() {
        usersDB.document(self.getUserUid()).collection("followee").whereField("uid", isEqualTo: user!.uid).addSnapshotListener() { (querySnapshot, err) in
            if let _err = err {
                print(_err)
                return
              }
            if querySnapshot!.documents.isEmpty {
                self.isFollowing = false
            } else {
                self.isFollowing = true
            }
            self.makeFollowButton(button: self.followButton, isFollowing: self.isFollowing!)
        }
    }

    @IBAction func tappedCallButton(_ sender: Any) {
        isMuteVideo = true
        tappedVideoButton(callButton!)
    }

    @IBAction func tappedVideoButton(_ sender: Any) {
        startIndicator()
        checkUnpaidOfferLearner() { result, offer in
            self.isUnpaid = result
            self.unpaidOffer = offer
            if !self.isUnpaid! {
                self.pointsDB.document(self.getUserUid()).getDocument() { snapshot, error in
                    guard let document = snapshot else {
                        self.showError(error)
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    let point = data["point"] as? Double ?? 0
                    if point - Double(self.offer!.offerPrice) < 0.0 {
                        SCLAlertView().showError(self.LString("Oops"), subTitle: String(format: self.LString("Your have not enough points teach...") , Language.strings[self.getUserData().teachLanguage]), closeButtonTitle: self.LString("OK"))
                        return
                    }
                    let alert = SCLAlertView()
                    alert.addButton(self.LString("OK")) { self.performSegue(withIdentifier: "show_media", sender: nil) }
                    alert.showInfo(self.LString("Confirm payment"),
                                   subTitle: String(format: self.LString("Pay %d points and talk %d minutes"),
                                    self.offer!.offerPrice,self.offer!.offerTime))
                    self.stopIndicator()
                }
            }
        }
    }

    func getOfferData() {
        offersDB.whereField("nativeID", isEqualTo: user!.uid).whereField("isOnline", isEqualTo: true).order(by: "createdAt", descending: true).getDocuments() { snapshot, error in
            if let _error = error {
                self.showError(_error)
                return
            }
            guard let documents = snapshot?.documents else {
                return
            }
            if documents != [] {
                self.offer = documents.map{ OfferModel(from: $0) }[0]
                if self.currentIndex == 0 {
                    self.enableCallButton()
                }
            }
        }
    }

    func enableCallButton() {
        callButton.tintColor = UIColor(red: 137/255, green: 195/255, blue: 235/255, alpha: 1)
        videoButton.tintColor = UIColor(red: 211/255, green: 162/255, blue: 67/255, alpha: 1)
        callButton.isEnabled = true
        videoButton.isEnabled = true
        offerTime.text = String(offer!.offerTime)
        teachStyle.text = TeachingStyle.strings[offer!.teachStyle]
        if offer!.teachStyle == 0 {
            teachStyleImage.image = UIImage(named: "Teach")
        } else {
            teachStyleImage.image = UIImage(named: "Free talk")
        }
    }

    @IBAction func tappedMessageButton(_ sender: Any) {
        let count = (navigationController?.viewControllers.count)! - 2
        if (navigationController?.viewControllers[count] as? ChatroomViewController) != nil {
            navigationController?.popViewController(animated: true)
        } else {
            self.performSegue(withIdentifier: "showChatroom", sender: nil)
        }
    }

    @IBAction func tappedFollowButton(_ sender: Any) {
        if let isFollowing = self.isFollowing {
            if isFollowing {
                usersDB.document(self.getUserUid()).collection("followee").document(user!.uid).delete()
            } else {
                usersDB.document(self.getUserUid()).collection("followee").document(user!.uid).setData([
                    "uid" : user!.uid,
                    "name" : user!.name,
                    "createdAt" : FieldValue.serverTimestamp(),
                    "imageURL" : user!.imageURL.absoluteString,
                    "nationality" : user!.nationality,
                    "teachLanguage": Language.strings[user!.teachLanguage],
                    "studyLanguage": Language.strings[user!.studyLanguage],
                ])
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatroom" {
            let chatroomVC = segue.destination as! ChatroomViewController
            chatroomVC.chatroom = chatroom
            chatroomVC.avatarImage = thumbnail.image
            chatroomVC.chatPartnerName = user!.name
        }
        if segue.identifier == "show_media" {
            let callVC = segue.destination as! callingViewController
            callVC.offer = offer!
            callVC.selectedChatroom = chatroom
            callVC.chatPartnerName = offer!.nativeName
            callVC.avatarImage = thumbnail.image
            callVC.isMuteVideo = isMuteVideo
        }
        if segue.identifier == "showReviewView" {
            let ReviewVC = segue.destination as! ReviewViewController
            ReviewVC.offer = unpaidOffer!
        }
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let nativeVC = UIStoryboard(name: "nativeDetailView", bundle: nil).instantiateViewController(withIdentifier: "First") as! nativeDetailViewController
        nativeVC.user = user
        let learnerVC = UIStoryboard(name: "learnerDetailView", bundle: nil).instantiateViewController(withIdentifier: "Second") as! learnerDetailViewController
        learnerVC.user = user
        let childViewControllers:[UIViewController] = [nativeVC, learnerVC]
        return childViewControllers
    }

    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        if indexWasChanged {
            if toIndex == 1 {
                callMethodView.alpha = 0
            } else if toIndex == 0 {
                callMethodView.alpha = 1
                getOfferData()
            }
        }
    }
}
