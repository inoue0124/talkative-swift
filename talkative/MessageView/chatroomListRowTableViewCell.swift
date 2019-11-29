//
//  chatroomListRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/10.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import FirebaseFirestore

class chatroomListRowTableViewCell: UITableViewCell {

    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var latestMsg: UILabel!
    @IBOutlet weak var updatedDate: UILabel!
    @IBOutlet weak var nationalFlag: UIImageView!
    let Usersdb = Firestore.firestore().collection("Users")

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()

    lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()


    func setRowData(numOfCells: IndexPath, chatroom: ChatroomModel){
        let viewableUserIDs = [String](chatroom.viewableUserIDs.keys)
        let otherUserID = viewableUserIDs.filter{ $0 != getUserUid()}
        self.Usersdb.document(otherUserID[0]).getDocument { document, error in
            if let document = document, document.exists {
                let name = document.data()!["name"] as! String
                let uid = document.data()!["uid"] as! String
                self.Thumbnail.layer.cornerRadius = 30
                self.Name.text = String(name)
                if -chatroom.updatedAt.timeIntervalSinceNow > 60*60*24 {
                    self.updatedDate.text = self.dateFormatter.string(from: chatroom.updatedAt)
                } else {
                    self.updatedDate.text = self.timeFormatter.string(from: chatroom.updatedAt)
                }
                self.setImage(uid: uid, imageView: self.Thumbnail)
                self.makeFlagImageView(imageView: self.nationalFlag, nationality: document.data()!["nationality"] as! Int, radius: 10)
                self.latestMsg.text = chatroom.latestMsg
            } else {
                print("Document does not exist")
            }
        }
    }
}
