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

    func setRowData(numOfCells: IndexPath, chatroom: ChatroomModel){
        self.Thumbnail.layer.cornerRadius = 30
        self.Name.text = String(chatroom.nativeName)
        self.Thumbnail.image = UIImage.gif(name: "Preloader2")
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
