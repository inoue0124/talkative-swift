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

class UserModel {

    var uid: String  // uid of firebase
    var imageURL: URL
    var name: String // username
    var gender: Int // 0: None, 1: male, 2: female
    var birthDate: Date
    var isOnline: Bool
    var isOffering: Bool
    var offerTime: Int
    var nationality: Int
    var proficiency: Int
    var teachLanguage: Int
    var teachStyle: Int
    var studyLanguage: Int
    var timestamp: Timestamp = Timestamp()
    var peerID: String
    var ratingAsLearner: Double
    var ratingAsNative: Double
    var callCountAsLearner: Int
    var callCountAsNative: Int
    var location: GeoPoint
    var createdAt: Date // data of registration
    var updatedAt: Date // date of updating of user info
    var lastOnlineAt: Date


    init(from: QueryDocumentSnapshot) {
        self.uid = from.documentID
        self.imageURL = URL(string: from.get("imageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar.jpg?alt=media&token=3c705f19-eaef-40cc-be56-23d5bd01a596")!
        self.name = from.get("name") as? String ?? ""
        self.gender = from.get("gender") as? Int ?? 0
        self.timestamp = from.get("birthDate") as? Timestamp ?? Timestamp()
        self.birthDate = timestamp.dateValue()
        self.isOnline = from.get("isOnline") as? Bool ?? false
        self.isOffering = from.get("isOffering") as? Bool ?? false
        self.offerTime = from.get("offerTime") as? Int ?? 20
        self.nationality = from.get("nationality") as? Int ?? 1
        self.proficiency = from.get("proficiency") as? Int ?? 0
        self.teachLanguage = from.get("teachLanguage") as? Int ?? 1
        self.teachStyle = from.get("teachStyle") as? Int ?? 0
        self.studyLanguage = from.get("studyLanguage") as? Int ?? 1
        self.peerID = from.get("peerID") as? String ?? ""
        self.ratingAsLearner = from.get("ratingAsLearner") as? Double ?? 4.0
        self.ratingAsNative = from.get("ratingAsNative") as? Double ?? 4.0
        self.callCountAsLearner = from.get("callCountAsLearner") as? Int ?? 0
        self.callCountAsNative = from.get("callCountAsNative") as? Int ?? 0
        self.location = from.get("location") as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        self.timestamp = from.get("createdAt") as? Timestamp ?? Timestamp()
        self.createdAt = timestamp.dateValue()
        self.timestamp = from.get("updatedAt") as? Timestamp ?? Timestamp()
        self.updatedAt = timestamp.dateValue()
        self.timestamp = from.get("lastOnlineAt") as? Timestamp ?? Timestamp()
        self.lastOnlineAt = timestamp.dateValue()
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
            "offerTime": offerTime,
            "nationality": nationality,
            "teachLanguage": teachLanguage,
            "teachStyle": teachStyle,
            "studyLanguage": studyLanguage,
            "proficiency": proficiency,
            "peerID": peerID,
            "ratingAsLearner": ratingAsLearner,
            "ratingAsNative": ratingAsNative,
            "callCountAsLearner": callCountAsLearner,
            "callCountAsNative": callCountAsNative,
            "location" : location,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "lastOnlineAt": lastOnlineAt,
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
    @objc dynamic var nationality = 0 // Country_ID
    @objc dynamic var proficiency = 0
    @objc dynamic var ratingAsLearner = 4.0
    @objc dynamic var ratingAsNative = 4.0
    @objc dynamic var callCountAsLearner = 0
    @objc dynamic var callCountAsNative = 0
    @objc dynamic var studyLanguage = 0
    @objc dynamic var teachLanguage = 0
    @objc dynamic var teachStyle = 0
    @objc dynamic var offerTime = 20
    @objc dynamic var isAllowExtension = true
    @objc dynamic var createdAt = Date() // data of registration
    @objc dynamic var updatedAt = Date() // date of updating of user info
}

