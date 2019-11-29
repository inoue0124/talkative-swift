//
//  ReviewViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseFirestore

class teachReviewViewController: UIViewController {

    var offer: OfferModel?
    @IBOutlet weak var backHomeButton: UIButton!
    @IBOutlet weak var LearnerThumbnail: UIImageView!
    @IBOutlet weak var LearnerName: UILabel!
    @IBOutlet weak var nationalFlag: UIImageView!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    var rating: Int!
    let offersDb = Firestore.firestore().collection("offers")
    let Usersdb = Firestore.firestore().collection("Users")

    override func viewDidLoad() {
        super.viewDidLoad()
        backHomeButton.isEnabled = false
        LearnerName.text = offer!.learnerName
        setImage(uid: offer!.learnerID, imageView: LearnerThumbnail)
        LearnerThumbnail.layer.cornerRadius = 50
        makeFlagImageView(imageView: nationalFlag, nationality: offer!.learnerNationality, radius: 12.5)
    }

    @IBAction func tappedBackHomeButton(_ sender: Any) {
        offersDb.document(offer!.offerID).setData([
            "ratingForLearner" : rating!,
            "flagPayForNative" : true
        ], merge: true)
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func tappedStar1(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star"), for: .normal)
        star3.setImage(UIImage(named: "star"), for: .normal)
        star4.setImage(UIImage(named: "star"), for: .normal)
        star5.setImage(UIImage(named: "star"), for: .normal)
        self.rating = 1
        self.backHomeButton.isEnabled = true
    }
    @IBAction func tappedStar2(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star_fill"), for: .normal)
        star3.setImage(UIImage(named: "star"), for: .normal)
        star4.setImage(UIImage(named: "star"), for: .normal)
        star5.setImage(UIImage(named: "star"), for: .normal)
        self.rating = 2
        self.backHomeButton.isEnabled = true
    }
    @IBAction func tappedStar3(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star_fill"), for: .normal)
        star3.setImage(UIImage(named: "star_fill"), for: .normal)
        star4.setImage(UIImage(named: "star"), for: .normal)
        star5.setImage(UIImage(named: "star"), for: .normal)
        self.rating = 3
        self.backHomeButton.isEnabled = true
    }
    @IBAction func tappedStar4(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star_fill"), for: .normal)
        star3.setImage(UIImage(named: "star_fill"), for: .normal)
        star4.setImage(UIImage(named: "star_fill"), for: .normal)
        star5.setImage(UIImage(named: "star"), for: .normal)
        self.rating = 4
        self.backHomeButton.isEnabled = true
    }
    @IBAction func tappedStar5(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star_fill"), for: .normal)
        star3.setImage(UIImage(named: "star_fill"), for: .normal)
        star4.setImage(UIImage(named: "star_fill"), for: .normal)
        star5.setImage(UIImage(named: "star_fill"), for: .normal)
        self.rating = 5
        self.backHomeButton.isEnabled = true
    }
}
