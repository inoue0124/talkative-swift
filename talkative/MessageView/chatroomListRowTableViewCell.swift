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
        let otherUserID = chatroom.viewableUserIDs.filter{ $0 != getUserUid()}
        self.Usersdb.document(otherUserID[0]).getDocument { document, error in
            if let document = document, document.exists {
                let name = document.data()!["name"] as! String
                let imageURL = document.data()!["imageURL"] as! String
                self.Thumbnail.layer.cornerRadius = 30
                self.Name.text = String(name)
                self.Thumbnail.image = UIImage.gif(name: "Preloader2")
                if -chatroom.updatedAt.timeIntervalSinceNow > 60*60*24 {
                    self.updatedDate.text = self.dateFormatter.string(from: chatroom.updatedAt)
                } else {
                    self.updatedDate.text = self.timeFormatter.string(from: chatroom.updatedAt)
                }
                DispatchQueue.global().async {
                    let image = UIImage(url: URL(string: imageURL)!)
                    DispatchQueue.main.async {
                        self.Thumbnail.image = image
                    }
                }
                self.latestMsg.text = chatroom.latestMsg
            } else {
                print("Document does not exist")
            }
        }
    }
}
