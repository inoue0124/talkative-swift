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

class followViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var userTable: UITableView!
    var user: UserModel?
    var users: [UserModel]?
    var followeeORfollower: String?
    let Usersdb = Firestore.firestore().collection("Users")
    let offersDb = Firestore.firestore().collection("offers")

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = LString(followeeORfollower!)
        navigationItem.largeTitleDisplayMode = .never
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tabBarController?.tabBar.isHidden = true
        userTable.allowsSelection = true
        userTable.dataSource = self
        userTable.delegate = self
        userTable.register(UINib(nibName: "followRowTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
        Usersdb.document(getUserUid()).collection(followeeORfollower!).getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.users = documents.map{ UserModel(from: $0) }
            self.userTable.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt numOfCells: IndexPath) -> UITableViewCell {
        let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! followRowTableViewCell
        tableContent.setRowData(numOfCells: numOfCells, user: users![numOfCells.row])
        return tableContent
    }

    //セルの数をいくつにするか。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Usersdb.whereField("uid", isEqualTo: users![indexPath.row].uid).getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.user = documents.map{ UserModel(from: $0) }[0]
            self.userTable.reloadData()
            self.performSegue(withIdentifier: "nativeDetail", sender: nil)
        }
        tableView.allowsSelection = false
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nativeDetail" {
            let userDetailVC = segue.destination as! userDetailViewController
            userDetailVC.user = user!
            userDetailVC.tabIndex = 0
        }
    }
}
