//
//  followingRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/23.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit

class followRowTableViewCell: UITableViewCell {

    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var Name: UILabel!

    func setRowData(numOfCells: IndexPath, user: UserModel){
        Thumbnail.layer.cornerRadius = 15
        Name.text = String(user.name)
        self.setImage(uid: user.uid, imageView: Thumbnail)
    }
}
