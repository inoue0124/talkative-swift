//
//  HistoryRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/20.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import FirebaseFirestore

class HistoryRowTableViewCell: UITableViewCell {

    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var finishedDate: UILabel!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!
    @IBOutlet weak var requestButton: UIButton!
    var history: OfferModel?
    var chatroom: ChatroomModel?
    let chatroomsDB = Firestore.firestore().collection("chatrooms")

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()

    func setRowData(numOfCells: IndexPath, history: OfferModel){
        self.history = history
        Thumbnail.layer.cornerRadius = 30
        Name.text = String(history.nativeName)
        finishedDate.text = formatter.string(from: history.finishedAt)
        resetStars()
        drawStars(rating: history.ratingForNative)
        setImage(uid: history.nativeID, imageView: Thumbnail)
        makeFlagImageView(imageView: nationalFlag, nationality: history.nativeNationality, radius: 10)
        requestButton.backgroundColor = UIColor(red: 56/255, green: 180/255, blue: 139/255, alpha: 1)
        requestButton.setTitleColor(UIColor.white, for: .normal)
        requestButton.layer.borderColor = UIColor.gray.cgColor
        requestButton.layer.borderWidth = 0.5
        requestButton.layer.cornerRadius = 5
    }

    @IBAction func tappedRequestButton(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: LString("Call request"), message: LString("Send an call request?"), preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: LString("OK"), style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.chatroomsDB.whereField("viewableUserIDs." + self.getUserUid(), isEqualTo: true).whereField("viewableUserIDs." + self.history!.nativeID, isEqualTo: true).getDocuments() { (querySnapshot, err) in
                if let _err = err {
                    print(_err)
                } else if querySnapshot!.documents.isEmpty {
                    self.chatroom = ChatroomModel(chatroomID: self.chatroomsDB.document().documentID, viewableUserIDs: [self.getUserUid(): true, self.history!.nativeID: true], viewableUserNames: [self.getUserUid(): self.getUserData().name, self.history!.nativeID: self.history!.nativeName])
                    self.chatroomsDB.document(self.chatroom!.chatroomID).setData(["chatroomID": self.chatroom!.chatroomID,
                                                                                  "senderID": self.getUserUid(),
                                                                                  "viewableUserIDs": [self.getUserUid(): true, self.history!.nativeID: true],
                                                                                  "viewableUserNames": [self.getUserUid(): self.getUserData().name, self.history!.nativeID: self.history!.nativeName]
                    ])
                } else {
                    self.chatroom = ChatroomModel(from: querySnapshot!.documents[0])
                }
                let messageDB = Firestore.firestore().collection(["chatrooms", self.chatroom!.chatroomID, "messages"].joined(separator: "/"))
                self.chatroomsDB.document(self.chatroom!.chatroomID).setData(["latestMsg": "Request for teaching (System message)",
                                                                    "senderID": self.getUserUid(),
                                                                    "updatedAt": FieldValue.serverTimestamp(),
                                                                    "chatroomID": self.chatroom!.chatroomID,
                                                                    "viewableUserIDs": self.chatroom!.viewableUserIDs,
                                                                    "viewableUserNames": self.chatroom!.viewableUserNames], merge: true)
                messageDB.addDocument(data: ["createdAt": FieldValue.serverTimestamp(),
                                             "senderID": self.getUserUid(),
                                             "senderName": self.getUserData().name,
                                             "text": "Request for teaching (System message)"])
            }
        })

        let cancelAction: UIAlertAction = UIAlertAction(title: LString("Cancel"), style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func resetStars() {
        let stars = [star1, star2, star3, star4, star5]
        for index in 0 ... 4 {
            stars[index]!.image = UIImage(named: "star")
        }
    }

    func drawStars(rating: Int) {
        let stars = [star1, star2, star3, star4, star5]
        if rating == 1 {
            stars[0]!.image = UIImage(named: "star_fill")
        } else {
            for index in 0 ... rating-1 {
                stars[index]!.image = UIImage(named: "star_fill")
            }
        }
    }
}
