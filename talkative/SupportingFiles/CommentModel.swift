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
    var commenterID: String
    var commenterName: String
    var commenterNationality: Int
    var commenterImageURL: URL
    var comment: String
    var offerID: String
    var rating: Int
    var timestamp: Timestamp = Timestamp()
    var createdAt: Date

    init(from: QueryDocumentSnapshot) {
        self.commenterID = from.get("commenterID") as? String ?? ""
        self.commenterName = from.get("commenterName") as? String ?? ""
        self.commenterNationality = from.get("commenterNationality") as? Int ?? 0
        self.commenterImageURL = URL(string: from.get("commenterImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar.jpg?alt=media&token=3c705f19-eaef-40cc-be56-23d5bd01a596")!
        self.comment = from.get("comment") as? String ?? "Failed to load comment"
        self.offerID = from.get("offerID") as? String ?? ""
        self.rating = from.get("rating") as? Int ?? 4
        self.timestamp = from.get("createdAt") as? Timestamp ?? Timestamp()
        self.createdAt = timestamp.dateValue()
    }
}
