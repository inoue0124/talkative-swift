//
//  ReviewViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ReviewViewController: UIViewController {

    var offer: OfferModel?
    @IBOutlet weak var backHomeButton: UIButton!
    @IBOutlet weak var NativeThumbnail: UIImageView!
    @IBOutlet weak var NativeName: UILabel!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    @IBOutlet weak var instructLabel: UILabel!
    var rating: Int!
    let offersDb = Firestore.firestore().collection("offers")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.instructLabel.text = NSLocalizedString("rate_instruction", comment: "")
        self.backHomeButton.setTitle(NSLocalizedString("alert_finish", comment: ""), for:.normal)
        self.backHomeButton.isEnabled = false
        self.NativeName.text = self.offer!.nativeName
        self.NativeThumbnail.image = UIImage.gif(name: "Preloader")
        DispatchQueue.global().async {
            let image = UIImage(url: self.offer!.nativeImageURL)
            DispatchQueue.main.async {
                self.NativeThumbnail.image = image
                self.NativeThumbnail.layer.cornerRadius = 50
            }
        }
    }
    @IBAction func tappedBackHomeButton(_ sender: Any) {
        self.offersDb.document(self.offer!.offerID).setData([
            "ratingForNative" : self.rating!
        ], merge: true)
        self.navigationController?.popToRootViewController(animated: true)
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
