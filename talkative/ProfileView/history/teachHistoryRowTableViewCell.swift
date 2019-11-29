//
//  HistoryRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/20.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class teachHistoryRowTableViewCell: UITableViewCell {

    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var finishedDate: UILabel!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()

    func setRowData(numOfCells: IndexPath, history: OfferModel){
        Thumbnail.layer.cornerRadius = 30
        Name.text = String(history.learnerName)
        finishedDate.text = formatter.string(from: history.finishedAt)
        self.resetStars()
        self.drawStars(rating: history.ratingForLearner)
        self.setImage(uid: history.learnerID, imageView: Thumbnail)
        self.makeFlagImageView(imageView: nationalFlag, nationality: history.learnerNationality, radius: 10)
    }

    func resetStars() {
        let stars = [star1, star2, star3, star4, star5]
        for index in 0 ... 4 {
            stars[index]!.image = UIImage(named: "star")
        }
    }

    func drawStars(rating: Int) {
        print(rating)
        let stars = [star1, star2, star3, star4, star5]
        if rating == 0 {
            stars[0]!.image = UIImage(named: "star_fill")
        } else {
            for index in 0 ... rating-1 {
                stars[index]!.image = UIImage(named: "star_fill")
            }
        }
    }
}
