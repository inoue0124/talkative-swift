//
//  UserModel.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/12.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import Foundation

class UserModel: Identifiable {

    var id: String
    var uid: String  // uid of firebase
    var imageURL: URL
    var name: String // username
    var gender: Int // 1: male, 2: female, 3: None
    var birthDate: Date
    var isOnline: Bool
    var nationality: Int // Country_ID
    var motherLanguage: Int // Language_ID
    var secondLanguage: Int // Language_ID
    var timestamp: Timestamp = Timestamp()
    var peerID: String
    var rating: Int
    var createdAt: Date // data of registration
    var updatedAt: Date // date of updating of user info

    var diff: Int {
        return "\(id)\(name)\(nationality)\(updatedAt)".hashValue
    }

    init(from: QueryDocumentSnapshot) {
        self.uid = from.documentID
        self.imageURL = URL(string: from.get("imageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar.jpg?alt=media&token=3c705f19-eaef-40cc-be56-23d5bd01a596")!
        self.name = from.get("name") as? String ?? ""
        self.gender = from.get("gender") as? Int ?? 3
        self.timestamp = from.get("birthDate") as? Timestamp ?? Timestamp()
        self.birthDate = timestamp.dateValue()
        self.isOnline = from.get("isOnline") as? Bool ?? false
        self.nationality = from.get("nationality") as? Int ?? 1
        self.motherLanguage = from.get("motherLanguage") as? Int ?? 1
        self.secondLanguage = from.get("secondLanguage") as? Int ?? 1
        self.timestamp = from.get("createdAt") as? Timestamp ?? Timestamp()
        self.peerID = from.get("peerID") as? String ?? ""
        self.rating = from.get("rating") as? Int ?? 0
        self.createdAt = timestamp.dateValue()
        self.timestamp = from.get("updatedAt") as? Timestamp ?? Timestamp()
        self.updatedAt = timestamp.dateValue()
        self.id = self.uid
    }

    var toAnyObject: [String: Any] {
        return [
            "uid": uid,
            "imageURL": imageURL,
            "name": name,
            "gender": gender,
            "birthDate": birthDate,
            "isOnline": isOnline,
            "nationality": nationality,
            "motherLanguage": motherLanguage,
            "secondLanguage": secondLanguage,
            "peerID": peerID,
            "rating": rating,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
        ]
    }
}

class RealmUserModel: Object{
    @objc dynamic var uid = ""  // uid of firebase
    @objc dynamic var imageURL = "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar.jpg?alt=media&token=3c705f19-eaef-40cc-be56-23d5bd01a596"
    @objc dynamic var name = "名称未登録"// username
    @objc dynamic var gender = 0 // 1: male, 2: female, 3: None
    @objc dynamic var birthDate = Date()
    @objc dynamic var isWroteProf = false
    @objc dynamic var isOnline = false
    @objc dynamic var nationality = 0 // Country_ID
    @objc dynamic var motherLanguage = 0 // Language_ID
    @objc dynamic var secondLanguage = 0 // Language_ID
    @objc dynamic var rating = 0
    @objc dynamic var createdAt = Date() // data of registration
    @objc dynamic var updatedAt = Date() // date of updating of user info
}

