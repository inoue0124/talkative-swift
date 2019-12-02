//
//  ContactsViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/08.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import XLPagerTabStrip

class HistoryViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, UIPopoverPresentationControllerDelegate, IndicatorInfoProvider {
    var history: OfferModel?
    var histories: [OfferModel]?
    let offersDb = Firestore.firestore().collection("offers")
    let usersDb = Firestore.firestore().collection("Users")
    var native: UserModel?

    @IBOutlet weak var HistoryTable: UITableView!

    override func viewDidLoad() {
        HistoryTable.dataSource = self
        HistoryTable.delegate = self
        HistoryTable.register(UINib(nibName: "HistoryRowTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
        tabBarController?.tabBar.isHidden = true
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "As Learner")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        HistoryTable.allowsSelection = true
        offersDb.whereField("learnerID", isEqualTo: getUserUid()).order(by: "finishedAt", descending: true).getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("error")
            return
            }
            self.histories = documents.map{ OfferModel(from: $0) }
            self.HistoryTable.reloadData()
        }
        self.navigationItem.hidesBackButton = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt numOfCells: IndexPath) -> UITableViewCell {
        let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! HistoryRowTableViewCell
        tableContent.setRowData(numOfCells: numOfCells, history: self.histories![numOfCells.row])
        return tableContent
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelection = false
        tableView.deselectRow(at: indexPath, animated: true)
        history = histories![indexPath.row]
        self.usersDb.whereField("uid", isEqualTo: self.history!.nativeID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if querySnapshot!.documents.isEmpty {
                print("user is not exist")
            } else {
                print("user is exist")
                self.native = UserModel(from: querySnapshot!.documents[0])
                self.performSegue(withIdentifier: "showDetailView", sender: nil)
            }
        }
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            let userDetailVC = segue.destination as! userDetailViewController
            userDetailVC.user = self.native
            userDetailVC.tabIndex = 0
        }
    }

    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
