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
import DZNEmptyDataSet

class teachHistoryViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, UIPopoverPresentationControllerDelegate, IndicatorInfoProvider {
    var history: OfferModel?
    var histories: [OfferModel]?
    let offersDb = Firestore.firestore().collection("offers")
    let usersDb = Firestore.firestore().collection("Users")
    var learner: UserModel?

    @IBOutlet weak var HistoryTable: UITableView!

    override func viewDidLoad() {
        HistoryTable.dataSource = self
        HistoryTable.delegate = self
        HistoryTable.emptyDataSetDelegate = self
        HistoryTable.emptyDataSetSource = self
        HistoryTable.register(UINib(nibName: "teachHistoryRowTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
        tabBarController?.tabBar.isHidden = true
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: LString("Learners"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        HistoryTable.allowsSelection = true
        offersDb.whereField("nativeID", isEqualTo: getUserUid()).order(by: "finishedAt", descending: true).getDocuments() { snapshot, error in
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
        let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! teachHistoryRowTableViewCell
        tableContent.setRowData(numOfCells: numOfCells, history: histories![numOfCells.row])
        return tableContent
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelection = false
        tableView.deselectRow(at: indexPath, animated: true)
        history = histories![indexPath.row]
        usersDb.whereField("uid", isEqualTo: self.history!.learnerID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if querySnapshot!.documents.isEmpty {
                print("user is not exist")
            } else {
                print("user is exist")
                self.learner = UserModel(from: querySnapshot!.documents[0])
                self.performSegue(withIdentifier: "showLearnerDetailView", sender: nil)
            }
        }
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLearnerDetailView" {
            let userDetailVC = segue.destination as! userDetailViewController
            userDetailVC.user = learner
            userDetailVC.tabIndex = 1
        }
    }

    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension teachHistoryViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "reviews")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = LString("No histories")
        return NSAttributedString(string: text)
    }
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        HistoryTable.separatorStyle = .none
    }
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView!) {
        HistoryTable.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
    }
}


