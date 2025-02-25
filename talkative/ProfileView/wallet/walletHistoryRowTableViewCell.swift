//
//  walletHistoryRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/28.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import SDWebImage

class walletHistoryRowTableViewCell: UITableViewCell {

    @IBOutlet weak var historyDate: UILabel!
    @IBOutlet weak var method: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var Thumbnail: UIImageView!

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()

    func setRowData(numOfCells: IndexPath, pointHistory: pointHistoryModel){
        historyDate.text = formatter.string(from: pointHistory.createdAt)
        method.text = Method.strings[pointHistory.method]
        price.text = String(format: "%.1fP", pointHistory.point)
        Thumbnail.layer.cornerRadius = 25
        Thumbnail.sd_setImage(with: pointHistory.imageURL)
    }
}
