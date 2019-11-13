//
//  ChatroomModel.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/15.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase

struct ChatroomModel {

    var chatroomID: String  // uid of firebase
    var viewableUserIDs: [String]
    var latestMsg: String
    var timestamp: Timestamp = Timestamp()
    var updatedAt: Date

    init(chatroomID: String, viewableUserIDs: [String], latestMsg: String = "", updatedAt: Date = Date()) {
        self.chatroomID = chatroomID
        self.viewableUserIDs = viewableUserIDs
        self.latestMsg = latestMsg
        self.updatedAt = updatedAt
    }

    init(from: QueryDocumentSnapshot) {
        self.chatroomID = from.documentID
        self.viewableUserIDs = from.get("viewableUserIDs") as? [String] ?? []
        self.latestMsg = from.get("latestMsg") as? String ?? ""
        self.timestamp = from.get("updatedAt") as? Timestamp ?? Timestamp()
        self.updatedAt = timestamp.dateValue()
    }
}

