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
    @IBOutlet weak var offeringIcon: UIImageView!
    @IBOutlet weak var nationalFlag: UIImageView!
    let Usersdb = Firestore.firestore().collection("Users")
    var native: UserModel?
    var followees: [UserModel]?
    var isFavorite: Bool?

    func setRowData(numOfCells: IndexPath, native: UserModel){
        self.native = native
        NativeThumbnail.layer.cornerRadius = 25
        NativeName.text = String(native.name)
        rating.text = String(format: "%.1f", native.ratingAsNative)
        self.makeFlagImageView(imageView: self.nationalFlag, nationality: native.nationality, radius: 7.5)
        if native.isOffering {
            offeringIcon.image = UIColor.green.circleImage(size: offeringIcon.frame.size)
        }
        //self.timeLength.text = String(offer.offerTime)
        self.setImage(uid: native.uid, imageView: self.NativeThumbnail)
        self.targetLanguage.text = Language.shortStrings[native.motherLanguage]
        self.supportLanguage.text = Language.shortStrings[native.secondLanguage]
        self.Usersdb.document(self.getUserUid()).collection("followee").whereField("uid", isEqualTo: native.uid).addSnapshotListener() { snapshot, error in
              if let _error = error {
                  return
              }
              guard let documents = snapshot?.documents else {
                  print("error")
              return
              }
            if documents.isEmpty {
                self.isFavorite = false
                //self.makeFollowButton(button: self.followButton, isFollowing: self.isFavorite!)
            } else {
                self.isFavorite = true
                //self.makeFollowButton(button: self.followButton, isFollowing: self.isFavorite!)
          }
        }
    }

    @IBAction func tappedFollowButton(_ sender: Any) {
        if let isFavorite = self.isFavorite {
            if isFavorite {
                self.Usersdb.document(self.getUserUid()).collection("followee").document(self.native!.uid).delete()
            } else {
                self.Usersdb.document(self.getUserUid()).collection("followee").document(self.native!.uid).setData([
                    "uid" : self.native!.uid,
                    "name" : self.native!.name,
                        "createdAt" : FieldValue.serverTimestamp(),
                        "imageURL" : self.native!.imageURL.absoluteString,
                        "motherLanguage": Language.strings[self.native!.motherLanguage],
                        "secondLanguage": Language.strings[self.native!.secondLanguage],
                        "rating": self.native!.ratingAsNative,
                    ])
            }
        }
    }
}

