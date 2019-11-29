//
//  nativeCollectionViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/11/26.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit

class nativeCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!
    @IBOutlet weak var supportLanguage: UILabel!
    @IBOutlet weak var proficiency: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var offerTime: UILabel!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 2.0
        self.layer.masksToBounds = false
    }

    func setData(numOfCells: IndexPath, native: UserModel){
        supportLanguage.text = Language.shortStrings[native.secondLanguage]
        proficiency.image = UIImage(named: String(native.proficiency))
        rating.text = String(format: "%.1f", native.ratingAsNative)
        //offerTime.text = String(native.offerTime)
        self.makeFlagImageView(imageView: nationalFlag, nationality: native.nationality, radius: 10)
        thumbnail.layer.cornerRadius = 40
        self.setImage(uid: native.uid, imageView: self.thumbnail)
        offerTime.text = String(native.offeringTime)
    }
}
