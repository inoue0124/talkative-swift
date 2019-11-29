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
    var isOffering: Bool
    var offeringTime: Int
    var nationality: Int // Country_ID
    var motherLanguage: Int // Language_ID
    var secondLanguage: Int // Language_ID
    var proficiency: Int
    var timestamp: Timestamp = Timestamp()
    var peerID: String
    var ratingAsLearner: Double
    var ratingAsNative: Double
    var callCountAsLearner: Int
    var callCountAsNative: Int
    var location: GeoPoint
    var point: Double
    var createdAt: Date // data of registration
    var updatedAt: Date // date of updating of user info
    var lastLoginBonus: Date

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
        self.isOffering = from.get("isOffering") as? Bool ?? false
        self.offeringTime = from.get("offeringTime") as? Int ?? 10
        self.nationality = from.get("nationality") as? Int ?? 1
        self.motherLanguage = from.get("motherLanguage") as? Int ?? 1
        self.secondLanguage = from.get("secondLanguage") as? Int ?? 1
        self.proficiency = from.get("proficiency") as? Int ?? 0
        self.peerID = from.get("peerID") as? String ?? ""
        self.ratingAsLearner = from.get("ratingAsLearner") as? Double ?? 4.0
        self.ratingAsNative = from.get("ratingAsNative") as? Double ?? 4.0
        self.callCountAsLearner = from.get("callCountAsLearner") as? Int ?? 0
        self.callCountAsNative = from.get("callCountAsNative") as? Int ?? 0
        self.location = from.get("location") as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        self.point = from.get("point") as? Double ?? 0.0
        self.timestamp = from.get("createdAt") as? Timestamp ?? Timestamp()
        self.createdAt = timestamp.dateValue()
        self.timestamp = from.get("updatedAt") as? Timestamp ?? Timestamp()
        self.updatedAt = timestamp.dateValue()
        self.timestamp = from.get("lastLoginBonus") as? Timestamp ?? Timestamp()
        self.lastLoginBonus = timestamp.dateValue()
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
            "isOffering": isOffering,
            "offeringTime": offeringTime,
            "nationality": nationality,
            "motherLanguage": motherLanguage,
            "secondLanguage": secondLanguage,
            "proficiency": proficiency,
            "peerID": peerID,
            "ratingAsLearner": ratingAsLearner,
            "ratingAsNative": ratingAsNative,
            "callCountAsLearner": callCountAsLearner,
            "callCountAsNative": callCountAsNative,
            "location" : location,
            "point": point,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "lastLoginBonus" : lastLoginBonus,
        ]
    }
}

class RealmUserModel: Object{
    @objc dynamic var uid = ""  // uid of firebase
    @objc dynamic var profImage = Data()
    @objc dynamic var imageURL = "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar.jpg?alt=media&token=3c705f19-eaef-40cc-be56-23d5bd01a596"
    @objc dynamic var name = "名称未登録"// username
    @objc dynamic var gender = 0 // 1: male, 2: female, 3: None
    @objc dynamic var birthDate = Date()
    @objc dynamic var isRegisteredProf = false
    @objc dynamic var isOnline = false
    @objc dynamic var nationality = 0 // Country_ID
    @objc dynamic var motherLanguage = 0 // Language_ID
    @objc dynamic var secondLanguage = 0 // Language_ID
    @objc dynamic var proficiency = 0
    @objc dynamic var ratingAsLearner = 5.0
    @objc dynamic var ratingAsNative = 5.0
    @objc dynamic var callCountAsLearner = 1
    @objc dynamic var callCountAsNative = 1
    @objc dynamic var point = 100.0
    @objc dynamic var createdAt = Date() // data of registration
    @objc dynamic var updatedAt = Date() // date of updating of user info
    @objc dynamic var lastLoginBonus = Date()
}

