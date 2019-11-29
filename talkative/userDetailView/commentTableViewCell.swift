//
//  commentTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/11/28.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit

class commentTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!
    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var commentView: UITextView!
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

    func setRowData(numOfCells: IndexPath, comment: CommentModel){
        self.setImage(uid: comment.commenterID, imageView: thumbnail)
        self.makeFlagImageView(imageView: nationalFlag, nationality: comment.commenterNationality, radius: 5)
        thumbnail.layer.cornerRadius = 15
        commentDate.text = formatter.string(from: comment.createdAt)
        commentView.text = comment.comment
        drawStars(rating: comment.rating)
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
