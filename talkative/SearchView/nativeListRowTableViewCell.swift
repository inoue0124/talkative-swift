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
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var targetLanguage: UILabel!
    @IBOutlet weak var supportLanguage: UILabel!
    @IBOutlet weak var timeLength: UILabel!
    @IBOutlet weak var followButton: UIButton!
    let Usersdb = Firestore.firestore().collection("Users")
    var offer: OfferModel?
    var followees: [UserModel]?
    var isFavorite: Bool?

    func setRowData(numOfCells: IndexPath, offer: OfferModel){
        self.offer = offer
        self.NativeThumbnail.layer.cornerRadius = 40
        self.NativeName.text = String(offer.nativeName)
        self.rating.text = String(format: "%.1f", offer.nativeRating)
        self.timeLength.text = String(offer.offerTime)
        self.NativeThumbnail.image = UIImage.gif(name: "Preloader2")
        DispatchQueue.global().async {
            let image = UIImage(url: offer.nativeImageURL)
            DispatchQueue.main.async {
                self.NativeThumbnail.image = image
            }
        }
        self.targetLanguage.text = Language.strings[offer.targetLanguage]
        self.supportLanguage.text = Language.strings[offer.supportLanguage]
        self.Usersdb.document(self.getUserUid()).collection("followee").whereField("uid", isEqualTo: self.offer!.nativeID).addSnapshotListener() { snapshot, error in
              if let _error = error {
                  return
              }
              guard let documents = snapshot?.documents else {
                  print("error")
              return
              }
            if documents.isEmpty {
                self.followButton.setImage(UIImage(named: "heart"), for: .normal)
                self.isFavorite = false
            } else {
                self.followButton.setImage(UIImage(named: "heart_fill"), for: .normal)
                self.isFavorite = true
          }
        }
    }

    @IBAction func tappedFollowButton(_ sender: Any) {
        if let isFavorite = self.isFavorite {
            if isFavorite {
                self.Usersdb.document(self.getUserUid()).collection("followee").document(self.offer!.nativeID).delete()
            } else {
                    self.Usersdb.document(self.getUserUid()).collection("followee").document(self.offer!.nativeID).setData([
                        "uid" : self.offer!.nativeID,
                        "name" : self.offer!.nativeName,
                        "createdAt" : FieldValue.serverTimestamp(),
                        "imageURL" : self.offer!.nativeImageURL.absoluteString,
                        "motherLanguage": Language.strings[self.offer!.targetLanguage],
                        "secondLanguage": Language.strings[self.offer!.supportLanguage],
                        "rating": self.offer!.nativeRating,
                    ])
            }
        }
    }
}

