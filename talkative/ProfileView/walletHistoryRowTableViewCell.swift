//
//  walletHistoryRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/28.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit

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
        self.historyDate.text = formatter.string(from: pointHistory.createdAt)
        self.method.text = Method.strings[pointHistory.method]
        self.price.text = String(pointHistory.point)
        self.Thumbnail.image = UIImage.gif(name: "Preloader2")
        self.Thumbnail.layer.cornerRadius = 25
        DispatchQueue.global().async {
            let image = UIImage(url: pointHistory.nativeImageURL)
            DispatchQueue.main.async {
                self.Thumbnail.image = image
            }
        }
    }
}
