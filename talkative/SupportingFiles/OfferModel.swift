//
//  OfferModel.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/15.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase

class OfferModel {

    var offerID: String  // uid of firebase
    var nativeID: String // username
    var nativeName: String
    var nativeNationality: Int
    var nativeRating: Int
    var nativeImageURL: URL
    var learnerID: String
    var learnerName: String
    var learnerImageURL: URL
    var learnerNationality: Int
    var learnerRating: Int
    var offerPrice: Int
    var offerTime: Int
    var targetLanguage: Int
    var supportLanguage: Int
    var peerID: String
    var isOnline: Bool
    var isAccepted: Bool
    var timestamp: Timestamp = Timestamp()
    var createdAt: Date
    var acceptedAt: Date
    var withdrawedAt: Date
    var finishedAt: Date
    var ratingForNative: Int
    var ratingForLearner: Int

    var diff: Int {
        return "\(offerID)\(createdAt.timeIntervalSince1970)".hashValue
    }

    init(offerID: String, nativeID: String, nativeName: String, nativeNationality: Int, nativeRating: Int, nativeImageURL: URL, learnerID: String, learnerName: String, learnerNationality: Int, learnerRating: Int, learnerImageURL: URL, offerPrice: Int, offerTime: Int, targetLanguage: Int, supportLanguage: Int, peerID: String) {
        self.offerID = offerID
        self.nativeID = nativeID
        self.nativeName = nativeName
        self.nativeNationality = nativeNationality
        self.nativeRating = nativeRating
        self.nativeImageURL = nativeImageURL
        self.learnerID = learnerID
        self.learnerName = learnerName
        self.learnerNationality = learnerNationality
        self.learnerRating = learnerRating
        self.learnerImageURL = learnerImageURL
        self.offerPrice = offerPrice
        self.offerTime = offerTime
        self.targetLanguage = targetLanguage
        self.supportLanguage = supportLanguage
        self.peerID = peerID
        self.isOnline = true
        self.isAccepted = false
        self.createdAt = Date()
        self.acceptedAt = Date()
        self.withdrawedAt = Date()
        self.finishedAt = Date()
        self.ratingForNative = 0
        self.ratingForLearner = 0
    }

    init(from: QueryDocumentSnapshot) {
        self.offerID = from.documentID
        self.nativeID = from.get("nativeID") as? String ?? ""
        self.nativeName = from.get("nativeName") as? String ?? ""
        self.nativeNationality = from.get("nativeNationality") as? Int ?? 0
        self.nativeRating = from.get("nativeRating") as? Int ?? 0
        self.nativeImageURL = URL(string: from.get("nativeImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar1.jpg?alt=media&token=76d3a6c2-42bd-45f9-badb-d6398b129eaf")!
        self.learnerID = from.get("learnerID") as? String ?? ""
        self.learnerName = from.get("learnerName") as? String ?? ""
        self.learnerNationality = from.get("learnerNationality") as? Int ?? 0
        self.learnerRating = from.get("learnerRating") as? Int ?? 0
        self.learnerImageURL = URL(string: from.get("learnerImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar1.jpg?alt=media&token=76d3a6c2-42bd-45f9-badb-d6398b129eaf")!
        self.offerPrice = from.get("offerPrice") as? Int ?? 9999
        self.offerTime = from.get("offerTime") as? Int ?? 9999
        self.targetLanguage = from.get("targetLanguage") as? Int ?? 0
        self.supportLanguage = from.get("supportLanguage") as? Int ?? 0
        self.peerID = from.get("peerID") as? String ?? ""
        self.isOnline = from.get("isOnline") as? Bool ?? false
        self.isAccepted = from.get("isAccepted") as? Bool ?? true
        self.timestamp = from.get("createdAt") as? Timestamp ?? Timestamp()
        self.createdAt = timestamp.dateValue()
        self.timestamp = from.get("acceptedAt") as? Timestamp ?? Timestamp()
        self.acceptedAt = timestamp.dateValue()
        self.timestamp = from.get("withdrawedAt") as? Timestamp ?? Timestamp()
        self.withdrawedAt = timestamp.dateValue()
        self.timestamp = from.get("finishedAt") as? Timestamp ?? Timestamp()
        self.finishedAt = timestamp.dateValue()
        self.ratingForNative = from.get("ratingForNative") as? Int ?? 0
        self.ratingForLearner = from.get("ratingForLearner") as? Int ?? 0
    }

    var toAnyObject: [String: Any] {
        return [
            "offerID" : offerID,
            "nativeID" : nativeID,
            "nativeName" : nativeName,
            "nativeNationality" : nativeNationality,
            "nativeRating" : nativeRating,
            "nativeImageURL" : nativeImageURL.absoluteString,
            "learnerID" : learnerID,
            "learnerName" : learnerName,
            "learnerNationality" : learnerNationality,
            "learnerRating" : learnerRating,
            "learnerImageURL" : learnerImageURL.absoluteString,
            "offerPrice" : offerPrice,
            "offerTime" : offerTime,
            "targetLanguage" : targetLanguage,
            "supportLanguage" : supportLanguage,
            "peerID" : peerID,
            "isOnline": isOnline,
            "isAccepted" : isAccepted,
            "createdAt" : createdAt,
            "acceptedAt" : acceptedAt,
            "withdrawedAt" : withdrawedAt,
            "finishedAt" : finishedAt,
            "ratingForNative" : ratingForNative,
            "ratingForLearner" : ratingForLearner,
        ]
    }
}

