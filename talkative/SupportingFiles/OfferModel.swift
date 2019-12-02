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
    var nativeMotherLanguage: Int
    var nativeRating: Double
    var nativeImageURL: URL
    var nativeLocation: GeoPoint
    var learnerID: String
    var learnerName: String
    var learnerImageURL: URL
    var learnerNationality: Int
    var learnerMotherLanguage: Int
    var learnerRating: Double
    var learnerLocation: GeoPoint
    var offerPrice: Int
    var offerTime: Int
    var targetLanguage: Int
    var supportLanguage: Int
    var nativeProficiency: Int
    var learnerProficiency: Int
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
    var flagPayForNative: Bool
    var flagWithdrawFromLearner: Bool
    var canExtend: Bool

    init(from: QueryDocumentSnapshot) {
        self.offerID = from.documentID
        self.nativeID = from.get("nativeID") as? String ?? ""
        self.nativeName = from.get("nativeName") as? String ?? ""
        self.nativeNationality = from.get("nativeNationality") as? Int ?? 0
        self.nativeMotherLanguage = from.get("nativeMotherLanguage") as? Int ?? 0
        self.nativeRating = from.get("nativeRating") as? Double ?? 4.0
        self.nativeImageURL = URL(string: from.get("nativeImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar1.jpg?alt=media&token=76d3a6c2-42bd-45f9-badb-d6398b129eaf")!
        self.nativeLocation = from.get("nativeLocation") as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        self.learnerID = from.get("learnerID") as? String ?? ""
        self.learnerName = from.get("learnerName") as? String ?? ""
        self.learnerNationality = from.get("learnerNationality") as? Int ?? 0
        self.learnerMotherLanguage = from.get("learnerMotherLanguage") as? Int ?? 0
        self.learnerRating = from.get("learnerRating") as? Double ?? 4.0
        self.learnerImageURL = URL(string: from.get("learnerImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/talkative-21c6c.appspot.com/o/profImages%2Favatar1.jpg?alt=media&token=76d3a6c2-42bd-45f9-badb-d6398b129eaf")!
        self.learnerLocation = from.get("learnerLocation") as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        self.offerPrice = from.get("offerPrice") as? Int ?? 9999
        self.offerTime = from.get("offerTime") as? Int ?? 9999
        self.targetLanguage = from.get("targetLanguage") as? Int ?? 0
        self.supportLanguage = from.get("supportLanguage") as? Int ?? 0
        self.nativeProficiency = from.get("nativeProficiency") as? Int ?? 0
        self.learnerProficiency = from.get("learnerProficiency") as? Int ?? 0
        self.peerID = from.get("peerID") as? String ?? ""
        self.isOnline = from.get("isOnline") as? Bool ?? false
        self.isAccepted = from.get("isAccepted") as? Bool ?? false
        self.timestamp = from.get("createdAt") as? Timestamp ?? Timestamp()
        self.createdAt = timestamp.dateValue()
        self.timestamp = from.get("acceptedAt") as? Timestamp ?? Timestamp()
        self.acceptedAt = timestamp.dateValue()
        self.timestamp = from.get("withdrawedAt") as? Timestamp ?? Timestamp()
        self.withdrawedAt = timestamp.dateValue()
        self.timestamp = from.get("finishedAt") as? Timestamp ?? Timestamp()
        self.finishedAt = timestamp.dateValue()
        self.ratingForNative = from.get("ratingForNative") as? Int ?? 1
        self.ratingForLearner = from.get("ratingForLearner") as? Int ?? 1
        self.flagPayForNative = from.get("flagPayForNative") as? Bool ?? false
        self.flagWithdrawFromLearner = from.get("flagWithdrawFromLearner") as? Bool ?? false
        self.canExtend = from.get("canExtend") as? Bool ?? false
    }

    var toAnyObject: [String: Any] {
        return [
            "offerID" : offerID,
            "nativeID" : nativeID,
            "nativeName" : nativeName,
            "nativeNationality" : nativeNationality,
            "nativeMotherLanguage" : nativeMotherLanguage,
            "nativeRating" : nativeRating,
            "nativeImageURL" : nativeImageURL.absoluteString,
            "nativeLocation" : nativeLocation,
            "learnerID" : learnerID,
            "learnerName" : learnerName,
            "learnerNationality" : learnerNationality,
            "learnerMotherLanguage" : learnerMotherLanguage,
            "learnerRating" : learnerRating,
            "learnerImageURL" : learnerImageURL.absoluteString,
            "learnerLocation" : learnerLocation,
            "offerPrice" : offerPrice,
            "offerTime" : offerTime,
            "targetLanguage" : targetLanguage,
            "supportLanguage" : supportLanguage,
            "nativeProficiency" : nativeProficiency,
            "learnerProficiency" : learnerProficiency,
            "peerID" : peerID,
            "isOnline": isOnline,
            "isAccepted" : isAccepted,
            "createdAt" : createdAt,
            "acceptedAt" : acceptedAt,
            "withdrawedAt" : withdrawedAt,
            "finishedAt" : finishedAt,
            "ratingForNative" : ratingForNative,
            "ratingForLearner" : ratingForLearner,
            "flagPayForNative" : flagPayForNative,
            "flagWithdrawFromLearner" : flagWithdrawFromLearner,
            "canExtend": canExtend,
        ]
    }
}

