//
//  nativeCollectionViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/11/26.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit

class nativeCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!
    @IBOutlet weak var supportLanguage: UILabel!
    @IBOutlet weak var proficiency: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var offerTime: UILabel!
    @IBOutlet weak var styleImage: UIImageView!
    @IBOutlet weak var styleLabel: UILabel!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.layer.cornerRadius = 10.0
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 10.0
        layer.masksToBounds = false
    }

    func setData(numOfCells: IndexPath, native: UserModel){
        name.text = native.name
        supportLanguage.text = Language.shortStrings[native.studyLanguage]
        proficiency.image = UIImage(named: String(native.proficiency))
        rating.text = String(format: "%.1f", native.ratingAsNative)
        makeFlagImageView(imageView: nationalFlag, nationality: native.nationality, radius: 10)
        thumbnail.layer.cornerRadius = 40
        setImage(uid: native.uid, imageView: self.thumbnail)
        offerTime.text = String(native.offerTime)
        styleLabel.text = String(TeachingStyle.strings[native.teachStyle])
        if native.teachStyle == 0 {
            styleImage.image = UIImage(named: "Teach")
        } else {
            styleImage.image = UIImage(named: "Free talk")
        }
    }
}
