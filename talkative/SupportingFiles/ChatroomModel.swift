//
//  ChatroomModel.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/15.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase

struct ChatroomModel: Identifiable {

    var id: String
    var chatroomID: String  // uid of firebase
    var nativeID: String // username
    var nativeName: String
    var nativeImageURL: URL
    var learnerID: String
    var learnerName: String
    var learnerImageURL: URL
    var latestMsg: String
    var timestamp: Timestamp = Timestamp()
    var updatedAt: Date

    var diff: Int {
        return "\(id)\(chatroomID)\(updatedAt.timeIntervalSince1970)".hashValue
    }

    init(chatroomID: String, nativeID: String, nativeName: String, nativeImageURL: URL, learnerID: String, learnerName: String, learnerImageURL: URL, latestMsg: String = "", updatedAt: Date = Date()) {
        self.chatroomID = chatroomID
        self.nativeID = nativeID
        self.nativeName = nativeName
        self.nativeImageURL = nativeImageURL
        self.learnerID = learnerID
        self.learnerName = learnerName
        self.learnerImageURL = learnerImageURL
        self.latestMsg = latestMsg
        self.updatedAt = updatedAt
        self.id = chatroomID
    }

    init(from: QueryDocumentSnapshot) {
        self.chatroomID = from.documentID
        self.nativeID = from.get("nativeID") as? String ?? ""
        self.nativeName = from.get("nativeName") as? String ?? ""
        self.nativeImageURL = URL(string: from.get("nativeImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar1.jpg?alt=media&token=76d3a6c2-42bd-45f9-badb-d6398b129eaf")!
        self.learnerID = from.get("learnerID") as? String ?? ""
        self.learnerName = from.get("learnerName") as? String ?? ""
        self.learnerImageURL = URL(string: from.get("learnerImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar1.jpg?alt=media&token=76d3a6c2-42bd-45f9-badb-d6398b129eaf")!
        self.latestMsg = from.get("latestMsg") as? String ?? ""
        self.timestamp = from.get("updatedAt") as? Timestamp ?? Timestamp()
        self.updatedAt = timestamp.dateValue()
        self.id = self.chatroomID
    }

    var toAnyObject: [String: Any] {
        return [
            "chatroomID": chatroomID,
            "nativeID": nativeID,
            "nativeName": nativeName,
            "nativeImageURL": nativeImageURL.absoluteString,
            "learnerID": learnerID,
            "learnerName": learnerName,
            "learnerImageURL": learnerImageURL.absoluteString,
            "latestMsg": latestMsg,
            "updatedAt": updatedAt,
        ]
    }
}

