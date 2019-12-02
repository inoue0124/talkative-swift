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
    var chatroomListener: ListenerRegistration?
    var isInitialCheck: Bool?
    var chatPartnerName: String?
    deinit {
      chatroomListener?.remove()
    }

    @IBOutlet weak var ChatroomListTable: UITableView!

  override func viewDidLoad() {
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    isInitialCheck = true
    ChatroomListTable.dataSource = self
    ChatroomListTable.delegate = self
    ChatroomListTable.register(UINib(nibName: "chatroomListRowTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
    chatroomListener = chatroomsDb.whereField("viewableUserIDs." + getUserUid(), isEqualTo: true).addSnapshotListener() { snapshot, error in
        if let _error = error {
            print("error\(_error)")
            return
        }
        guard let documents = snapshot?.documents else {
            print("error")
        return
        }
        self.chatrooms = documents.map{ ChatroomModel(from: $0) }
        self.chatrooms = self.chatrooms!.filter{ $0.latestMsg != "" }
        self.chatrooms!.sort{ $0.updatedAt > $1.updatedAt }
        DispatchQueue.main.async {
            // UI更新はメインスレッドで実行
            if !self.isInitialCheck! && self.chatrooms!.first != nil && self.chatrooms!.first?.senderID != self.getUserUid() {
                self.tabBarItem.badgeValue = "N"
            }
            self.isInitialCheck = false
            self.ChatroomListTable.reloadData()
        }
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarItem.badgeValue = nil
        ChatroomListTable.allowsSelection = true
        navigationItem.hidesBackButton = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
        largeTitle(LString("Messages"))
    }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatrooms?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt numOfCells: IndexPath) -> UITableViewCell {
    let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! chatroomListRowTableViewCell
    tableContent.setRowData(numOfCells: numOfCells, chatroom: chatrooms![numOfCells.row])
    return tableContent
  }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatroom = chatrooms![indexPath.row]
        tableView.allowsSelection = false
        tableView.deselectRow(at: indexPath, animated: true)
        chatPartnerName = chatroom!.viewableUserNames.filter{ $0.key != getUserUid() }[0].value
        performSegue(withIdentifier: "showChatroomView", sender: nil)
       }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatroomView" {
            let ChatroomVC = segue.destination as! ChatroomViewController
            ChatroomVC.chatroom = chatroom
            ChatroomVC.chatPartnerName = chatPartnerName!
        }
    }

    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

}

