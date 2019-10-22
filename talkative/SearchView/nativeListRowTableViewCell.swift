//
//  nativeListRowTableViewCell.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/08.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import FirebaseFirestore

class nativeListRowTableViewCell: UITableViewCell {

    @IBOutlet weak var NativeThumbnail: UIImageView!
    @IBOutlet weak var NativeName: UILabel!
    @IBOutlet weak var targetLanguage: UILabel!
    @IBOutlet weak var supportLanguage: UILabel!
    @IBOutlet weak var timeLength: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var label_motherLanguage: UILabel!
    @IBOutlet weak var label_secondLanguage: UILabel!
    @IBOutlet weak var followButton: UIButton!
    let Usersdb = Firestore.firestore().collection("Users")
    var offer: OfferModel?

    func setRowData(numOfCells: IndexPath, offer: OfferModel){
        self.offer = offer
        self.label_motherLanguage.text = NSLocalizedString("label_motherLanguage", comment: "")
        self.label_secondLanguage.text = NSLocalizedString("label_secondLanguage", comment: "")
        self.NativeThumbnail.layer.cornerRadius = 40
        self.NativeName.text = String(offer.nativeName)
        self.timeLength.text = String(offer.offerTime) + String(NSLocalizedString("unit_min", comment: ""))
        self.price.text = NSLocalizedString("unit_money", comment: "") + String(offer.offerPrice)
        self.NativeThumbnail.image = UIImage.gif(name: "Preloader2")
        DispatchQueue.global().async {
            let image = UIImage(url: offer.nativeImageURL)
            DispatchQueue.main.async {
                self.NativeThumbnail.image = image
            }
        }
        self.targetLanguage.text = Language.strings[offer.targetLanguage]
        self.supportLanguage.text = Language.strings[offer.supportLanguage]
    }

    @IBAction func tappedFollowButton(_ sender: Any) {
        self.followButton.setImage(UIImage(named: "heart_fill"), for: .normal)
        print(self.offer!.nativeID)
        self.Usersdb.document(self.getUserUid()).collection("followee").document(self.offer!.nativeID).setData([
            "uid" : self.offer!.nativeID,
            "name" : self.offer!.nativeName,
            "createdAt" : FieldValue.serverTimestamp(),
            "imageURL" : self.offer!.nativeImageURL.absoluteString
        ])
    }
}

