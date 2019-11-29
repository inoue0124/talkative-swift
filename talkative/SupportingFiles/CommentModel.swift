//
//  CommentModel.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/11/28.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase

struct CommentModel {
    var commentID: String
    var commenterID: String
    var commenterName: String
    var commenterNationality: Int
    var commenterImageURL: URL
    var receiverID: String
    var receiverName: String
    var receiverNationality: Int
    var receiverImageURL: URL
    var comment: String
    var rating: Int
    var timestamp: Timestamp = Timestamp()
    var createdAt: Date

    init(from: QueryDocumentSnapshot) {
        self.commentID = from.documentID
        self.commenterID = from.get("commenterID") as? String ?? ""
        self.commenterName = from.get("commenterName") as? String ?? ""
        self.commenterNationality = from.get("commenterNationality") as? Int ?? 0
        self.commenterImageURL = URL(string: from.get("commenterImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar.jpg?alt=media&token=3c705f19-eaef-40cc-be56-23d5bd01a596")!
        self.receiverID = from.get("receiverID") as? String ?? ""
        self.receiverName = from.get("receiverName") as? String ?? ""
        self.receiverNationality = from.get("receiverNationality") as? Int ?? 0
        self.receiverImageURL = URL(string: from.get("receiverImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar.jpg?alt=media&token=3c705f19-eaef-40cc-be56-23d5bd01a596")!
        self.comment = from.get("comment") as? String ?? "Failed to load comment"
        self.rating = from.get("rating") as? Int ?? 4
        self.timestamp = from.get("updatedAt") as? Timestamp ?? Timestamp()
        self.createdAt = timestamp.dateValue()
    }
}
