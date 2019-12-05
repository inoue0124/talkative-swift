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
    @IBOutlet weak var commentField: UITextView!
    @IBOutlet weak var acceptedAt: UILabel!
    @IBOutlet weak var finishedAt: UILabel!
    @IBOutlet weak var timeDuration: UILabel!
    @IBOutlet weak var margin: UILabel!
    @IBOutlet weak var receivePoint: UILabel!
    var rating: Int!
    let offersDb = Firestore.firestore().collection("offers")
    let Usersdb = Firestore.firestore().collection("Users")

    lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        commentField.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        backHomeButton.isEnabled = false
        backHomeButton.backgroundColor = UIColor.lightGray
        LearnerName.text = offer!.learnerName
        setImage(uid: offer!.learnerID, imageView: LearnerThumbnail)
        LearnerThumbnail.layer.cornerRadius = 50
        makeFlagImageView(imageView: nationalFlag, nationality: offer!.learnerNationality, radius: 12.5)
        designTextView(textView: commentField)
        acceptedAt.text = timeFormatter.string(from: offer!.acceptedAt)
        finishedAt.text = timeFormatter.string(from: offer!.finishedAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "mm分ss秒"
        let duration = offer!.finishedAt.timeIntervalSince(offer!.acceptedAt)
        timeDuration.text = formatter.string(from: Date(timeIntervalSinceReferenceDate: duration))
        margin.text = String(format: "-%.1fP", duration / 60 * 0.3)
        receivePoint.text = String(format: "%.1fP", duration / 60 * 0.7)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
    }

    @objc func tapDone(sender: Any) {
        view.endEditing(true)
    }  

    @IBAction func tappedBackHomeButton(_ sender: Any) {
        offersDb.document(offer!.offerID).setData([
            "ratingForLearner" : rating!,
            "flagPayForNative" : true,
            "commentForLearner": commentField.text ?? ""
        ], merge: true)
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func tappedStar1(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star"), for: .normal)
        star3.setImage(UIImage(named: "star"), for: .normal)
        star4.setImage(UIImage(named: "star"), for: .normal)
        star5.setImage(UIImage(named: "star"), for: .normal)
        rating = 1
        backHomeButton.isEnabled = true
        backHomeButton.backgroundColor = UIColor.blue
    }
    @IBAction func tappedStar2(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star_fill"), for: .normal)
        star3.setImage(UIImage(named: "star"), for: .normal)
        star4.setImage(UIImage(named: "star"), for: .normal)
        star5.setImage(UIImage(named: "star"), for: .normal)
        rating = 2
        backHomeButton.isEnabled = true
        backHomeButton.backgroundColor = UIColor.blue
    }
    @IBAction func tappedStar3(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star_fill"), for: .normal)
        star3.setImage(UIImage(named: "star_fill"), for: .normal)
        star4.setImage(UIImage(named: "star"), for: .normal)
        star5.setImage(UIImage(named: "star"), for: .normal)
        rating = 3
        backHomeButton.isEnabled = true
        backHomeButton.backgroundColor = UIColor.blue
    }
    @IBAction func tappedStar4(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star_fill"), for: .normal)
        star3.setImage(UIImage(named: "star_fill"), for: .normal)
        star4.setImage(UIImage(named: "star_fill"), for: .normal)
        star5.setImage(UIImage(named: "star"), for: .normal)
        rating = 4
        backHomeButton.isEnabled = true
        backHomeButton.backgroundColor = UIColor.blue
    }
    @IBAction func tappedStar5(_ sender: Any) {
        star1.setImage(UIImage(named: "star_fill"), for: .normal)
        star2.setImage(UIImage(named: "star_fill"), for: .normal)
        star3.setImage(UIImage(named: "star_fill"), for: .normal)
        star4.setImage(UIImage(named: "star_fill"), for: .normal)
        star5.setImage(UIImage(named: "star_fill"), for: .normal)
        rating = 5
        backHomeButton.isEnabled = true
        backHomeButton.backgroundColor = UIColor.blue
    }
}
