//
//  HistoryRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/20.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class HistoryRowTableViewCell: UITableViewCell {

    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var finishedDate: UILabel!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()

    func setRowData(numOfCells: IndexPath, history: OfferModel){
        self.Thumbnail.layer.cornerRadius = 40
        self.Name.text = String(history.nativeName)
        self.finishedDate.text = formatter.string(from: history.finishedAt)
        self.Thumbnail.image = UIImage.gif(name: "Preloader2")
        self.resetStars()
        DispatchQueue.global().async {
            let image = UIImage(url: history.nativeImageURL)
            DispatchQueue.main.async {
                self.Thumbnail.image = image
                self.drawStars(rating: history.ratingForNative)
            }
        }
        //self.Thumbnail.image = UIImage(url: chatroom.nativeImageURL)
        //self.latestMsg.text = String(history.latestMsg)
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
