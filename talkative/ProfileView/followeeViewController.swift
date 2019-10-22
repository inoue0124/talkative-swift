//
//  followingViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/23.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftGifOrigin
import RealmSwift

class followeeViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var followeeTable: UITableView!
    var followees: [UserModel]?
    let Usersdb = Firestore.firestore().collection("Users")

    override func viewWillAppear(_ animated: Bool) {
        followeeTable.dataSource = self
        followeeTable.delegate = self
        followeeTable.register(UINib(nibName: "followeeRowTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
        Usersdb.document(getUserUid()).collection("followee").getDocuments() { snapshot, error in
         if let _error = error {
             print("error\(_error)")
             return
         }
         guard let documents = snapshot?.documents else {
         print("error")
            return
        }
            self.followees = documents.map{ UserModel(from: $0) }
            self.followeeTable.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt numOfCells: IndexPath) -> UITableViewCell {
        let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! followeeRowTableViewCell
        tableContent.setRowData(numOfCells: numOfCells, followee: self.followees![numOfCells.row])
        return tableContent
    }

    //セルの数をいくつにするか。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followees?.count ?? 0
    }
}
