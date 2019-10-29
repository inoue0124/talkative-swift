//
//  ChatroomModel.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/15.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase

struct pointHistoryModel {

    var learnerID: String
    var nativeID: String
    var nativeImageURL: URL
    var point: Int
    var method: Int
    var createdAt: Date
    var timestamp: Timestamp

    init(from: QueryDocumentSnapshot) {
        self.learnerID = from.get("learnerID") as? String ?? ""
        self.nativeID = from.get("nativeID") as? String ?? ""
        self.nativeImageURL = URL(string: from.get("nativeImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar1.jpg?alt=media&token=76d3a6c2-42bd-45f9-badb-d6398b129eaf")!
        self.point = from.get("point") as? Int ?? 0
        self.method = from.get("method") as? Int ?? 0
        self.timestamp = from.get("createdAt") as? Timestamp ?? Timestamp()
        self.createdAt = timestamp.dateValue()
    }

    var toAnyObject: [String: Any] {
        return [
            "learnerID": learnerID,
            "nativeID": nativeID,
            "nativeImageURL": nativeImageURL,
            "point": point,
            "method": method,
            "createdAt": createdAt,
        ]
    }
}

