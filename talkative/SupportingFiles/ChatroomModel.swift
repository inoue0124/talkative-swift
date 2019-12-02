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
    var senderID: String
    var viewableUserIDs: [String:Bool]
    var viewableUserNames: [String:String]
    var latestMsg: String
    var timestamp: Timestamp = Timestamp()
    var updatedAt: Date

    init(chatroomID: String, senderID: String = "", viewableUserIDs: [String: Bool], viewableUserNames: [String: String], latestMsg: String = "", updatedAt: Date = Date()) {
        self.chatroomID = chatroomID
        self.senderID = senderID
        self.viewableUserIDs = viewableUserIDs
        self.viewableUserNames = viewableUserNames
        self.latestMsg = latestMsg
        self.updatedAt = updatedAt
    }

    init(from: QueryDocumentSnapshot) {
        self.chatroomID = from.documentID
        self.senderID = from.get("senderID") as? String ?? ""
        self.viewableUserIDs = from.get("viewableUserIDs") as? [String: Bool] ?? [:]
        self.viewableUserNames = from.get("viewableUserNames") as? [String: String] ?? [:]
        self.latestMsg = from.get("latestMsg") as? String ?? ""
        self.timestamp = from.get("updatedAt") as? Timestamp ?? Timestamp()
        self.updatedAt = timestamp.dateValue()
    }
}

