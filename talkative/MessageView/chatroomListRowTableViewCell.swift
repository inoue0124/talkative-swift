//
//  chatroomListRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/10.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class chatroomListRowTableViewCell: UITableViewCell {

    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var latestMsg: UILabel!
    @IBOutlet weak var updatedDate: UILabel!

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
        self.Thumbnail.layer.cornerRadius = 30
        self.Name.text = String(chatroom.nativeName)
        self.Thumbnail.image = UIImage.gif(name: "Preloader2")
        if -chatroom.updatedAt.timeIntervalSinceNow > 60*60*24 {
            self.updatedDate.text = dateFormatter.string(from: chatroom.updatedAt)
        } else {
            self.updatedDate.text = timeFormatter.string(from: chatroom.updatedAt)
        }
        DispatchQueue.global().async {
            let image = UIImage(url: chatroom.nativeImageURL)
            DispatchQueue.main.async {
                self.Thumbnail.image = image
            }
        }
        //self.Thumbnail.image = UIImage(url: chatroom.nativeImageURL)
        self.latestMsg.text = String(chatroom.latestMsg )
    }
}
