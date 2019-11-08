//
//  walletViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/26.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Eureka
import FirebaseFirestore
import FirebaseAuth
import SwiftGifOrigin
import RealmSwift

class walletViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var point: UILabel!
    @IBOutlet weak var pointHistoryTable: UITableView!
    var pointHistory: [pointHistoryModel]?
    let Usersdb = Firestore.firestore().collection("Users")

    override func viewWillAppear(_ animated: Bool) {
        pointHistoryTable.dataSource = self
        pointHistoryTable.delegate = self
        pointHistoryTable.allowsSelection = false
        pointHistoryTable.register(UINib(nibName: "walletHistoryRowTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
        self.navigationItem.title = LString("Points history")
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.Usersdb.whereField("uid", isEqualTo: self.getUserUid()).addSnapshotListener() { snapshot, error in
        if let _error = error {
            self.showError(_error)
            return

        }
        guard let documents = snapshot?.documents else {
            return
        }
        let downloadedUserData = documents.map{ UserModel(from: $0) }
        self.point.text = String(downloadedUserData[0].point)
        }
        Usersdb.document(getUserUid()).collection("pointHistory").order(by: "createdAt", descending: true).getDocuments() { snapshot, error in
         if let _error = error {
             print("error\(_error)")
             return
         }
         guard let documents = snapshot?.documents else {
         print("error")
            return
        }
            self.pointHistory = documents.map{ pointHistoryModel(from: $0) }
            self.pointHistoryTable.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt numOfCells: IndexPath) -> UITableViewCell {
        let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! walletHistoryRowTableViewCell
        tableContent.setRowData(numOfCells: numOfCells, pointHistory: self.pointHistory![numOfCells.row])
        return tableContent
    }

    //セルの数をいくつにするか。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointHistory?.count ?? 0
    }
}

