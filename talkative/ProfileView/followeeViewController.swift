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
    var followee: UserModel?
    var followees: [UserModel]?
    let Usersdb = Firestore.firestore().collection("Users")
    let offersDb = Firestore.firestore().collection("offers")

    override func viewWillAppear(_ animated: Bool) {
        followeeTable.allowsSelection = true
        followeeTable.dataSource = self
        followeeTable.delegate = self
        self.navigationItem.title =  "お気に入り"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        followee = followees![indexPath.row]
        tableView.allowsSelection = false
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "nativeDetail", sender: nil)
       }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nativeDetail" {
            let followeeDetailVC = segue.destination as! followeeDetailViewController
            followeeDetailVC.native = self.followee!
        }
    }

}
