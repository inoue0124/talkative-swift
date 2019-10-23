//
//  SecondViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/08.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChatroomListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    var chatroom: ChatroomModel?
    var chatrooms: [ChatroomModel]?
    let chatroomsDb = Firestore.firestore().collection("chatrooms")
    let semaphore = DispatchSemaphore(value: 1)
    var chatroomListener: ListenerRegistration?
    deinit {
      chatroomListener?.remove()
    }

    @IBOutlet weak var ChatroomListTable: UITableView!

  override func viewDidLoad() {
    ChatroomListTable.dataSource = self
    ChatroomListTable.delegate = self
    ChatroomListTable.register(UINib(nibName: "chatroomListRowTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
    let uid = String(describing: Auth.auth().currentUser?.uid ?? "Error")
    self.chatroomListener = self.chatroomsDb.whereField("learnerID", isEqualTo: uid).order(by: "updatedAt", descending: true).addSnapshotListener() { snapshot, error in
        if let _error = error {
            print("error\(_error)")
            return
        }
        guard let documents = snapshot?.documents else {
            print("error")
        return
        }
        self.chatrooms = documents.map{ ChatroomModel(from: $0) }
        DispatchQueue.main.async {
            // UI更新はメインスレッドで実行
            self.tabBarItem.badgeValue = "new"
            self.ChatroomListTable.reloadData()
            self.semaphore.signal()
        }
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarItem.badgeValue = nil
        ChatroomListTable.allowsSelection = true
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else {
                self.performSegue(withIdentifier: "toLoginView", sender: nil)
                return
            }
        }
        self.navigationItem.hidesBackButton = false
        tabBarController?.tabBar.isHidden = false
        largeTitle(NSLocalizedString("largetitle_message", comment: ""))
    }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatrooms?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt numOfCells: IndexPath) -> UITableViewCell {
    let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! chatroomListRowTableViewCell
    tableContent.setRowData(numOfCells: numOfCells, chatroom: self.chatrooms![numOfCells.row])
    return tableContent
  }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatroom = chatrooms![indexPath.row]
        tableView.allowsSelection = false
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showChatroomView", sender: nil)
       }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatroomView" {
            let ChatroomVC = segue.destination as! ChatroomViewController
            ChatroomVC.chatroom = self.chatroom
            ChatroomVC.avatarImage = UIImage(url: self.chatroom!.nativeImageURL)
        }
    }

    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

}

