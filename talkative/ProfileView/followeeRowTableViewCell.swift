//
//  followingRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/23.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit

class followeeRowTableViewCell: UITableViewCell {

    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var Name: UILabel!

    func setRowData(numOfCells: IndexPath, followee: UserModel){
        self.Thumbnail.layer.cornerRadius = 15
        self.Name.text = String(followee.name)
        DispatchQueue.global().async {
            let image = UIImage(url: followee.imageURL)
            DispatchQueue.main.async {
                self.Thumbnail.image = image
            }
        }
    }
    
}
