//
//  File.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftGifOrigin
import SCLAlertView
import XLPagerTabStrip

class nativeDetailViewController: UIViewController, IndicatorInfoProvider {

    var user: UserModel?
    var offer: OfferModel?
    var comments: [CommentModel]?
    let disableColor: UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    let titleColor: UIColor = UIColor(red: 90/255, green: 84/255, blue: 75/255, alpha: 1)
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var callCount: UILabel!
    @IBOutlet weak var commentTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if user!.isOffering {
//            enableCallButton()
//        }
        commentTable.dataSource = self
        commentTable.delegate = self
        commentTable.allowsSelection = false
        commentTable.register(UINib(nibName: "commentTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
        rating.text = String(format: "%.1f", user!.ratingAsNative)
        callCount.text = String(user!.callCountAsNative)
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadTableData()
    }

    func reloadTableData() {
        let commentsDB = Firestore.firestore().collection("Users").document(user!.uid).collection("comment")
        commentsDB.order(by: "createdAt", descending: true).getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return

            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.comments = documents.map{ CommentModel(from: $0) }
            self.commentTable.reloadData()
        }
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "As Native")
    }
}

extension nativeDetailViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt numOfCells: IndexPath) -> UITableViewCell {
        let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! commentTableViewCell
        tableContent.setRowData(numOfCells: numOfCells, comment: self.comments![numOfCells.row])
        return tableContent
    }
}
