//
//  Settings.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/13.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//
import UIKit

enum TeachingStyle: Int {
    case Teach              = 0
    case FreeTalk           = 1

    static let all      = [Teach, FreeTalk]
    static let strings  = [NSLocalizedString("Teach", comment: ""), NSLocalizedString("Free talk", comment: "")]

    func string() -> String {
        let index = TeachingStyle.all.firstIndex(of: self) ?? 0
        return TeachingStyle.strings[index]
    }

    static func fromString(string: String) -> TeachingStyle {
        if let index = TeachingStyle.strings.firstIndex(of: string) {
            return TeachingStyle.all[index]
        }
        return TeachingStyle.Teach
    }
}

enum Gender: Int {
    case NoAnswer        = 0
    case Male           = 1
    case Female         = 2

    static let all      = [NoAnswer, Male, Female]
    static let strings  = [NSLocalizedString("No Answer", comment: ""), NSLocalizedString("Male", comment: ""), NSLocalizedString("Female", comment: "")]

    func string() -> String {
        let index = Gender.all.firstIndex(of: self) ?? 0
        return Gender.strings[index]
    }

    static func fromString(string: String) -> Gender {
        if let index = Gender.strings.firstIndex(of: string) {
            return Gender.all[index]
        }
        return Gender.NoAnswer
    }
}

enum Nationality: Int {
   case NotSet = 0
   case Australia = 1
   case Brazil = 2
   case Canada = 3
   case China = 4
   case Egypt = 5
   case France = 6
   case Germany = 7
   case HongKong = 8
   case India = 9
   case Indonesia = 10
   case Italia = 11
   case Japan = 12
   case Malaysia = 13
   case NewZealand = 14
   case Russia = 15
   case Singapore = 16
   case SouthKorea = 17
   case Spain = 18
   case Taiwan = 19
   case ThePhilippines = 20
   case Thailand = 21
   case Turkey = 22
   case UK = 23
   case US = 24
   case Vietnam = 25

    static let all      = [ NotSet,
                            Australia,
                            Brazil,
                            Canada,
                            China,
                            Egypt,
                            France,
                            Germany,
                            HongKong,
                            India,
                            Indonesia,
                            Italia,
                            Japan,
                            Malaysia,
                            NewZealand,
                            Russia,
                            Singapore,
                            SouthKorea,
                            Spain,
                            Taiwan,
                            ThePhilippines,
                            Thailand,
                            Turkey,
                            UK,
                            US,
                            Vietnam
    ]
    static let strings  = [
                            NSLocalizedString("Not set", comment: ""),
                            NSLocalizedString("Australia", comment: ""),
                            NSLocalizedString("Brazil", comment: ""),
                            NSLocalizedString("Canada", comment: ""),
                            NSLocalizedString("China", comment: ""),
                            NSLocalizedString("Egypt", comment: ""),
                            NSLocalizedString("France", comment: ""),
                            NSLocalizedString("Germany", comment: ""),
                            NSLocalizedString("Hong Kong", comment: ""),
                            NSLocalizedString("India", comment: ""),
                            NSLocalizedString("Indonesia", comment: ""),
                            NSLocalizedString("Italia", comment: ""),
                            NSLocalizedString("Japan", comment: ""),
                            NSLocalizedString("Malaysia", comment: ""),
                            NSLocalizedString("New Zealand", comment: ""),
                            NSLocalizedString("Russia", comment: ""),
                            NSLocalizedString("Singapore", comment: ""),
                            NSLocalizedString("South Korea", comment: ""),
                            NSLocalizedString("Spain", comment: ""),
                            NSLocalizedString("Taiwan", comment: ""),
                            NSLocalizedString("The Philippines", comment: ""),
                            NSLocalizedString("Thailand", comment: ""),
                            NSLocalizedString("Turkey", comment: ""),
                            NSLocalizedString("UK", comment: ""),
                            NSLocalizedString("U.S.", comment: ""),
                            NSLocalizedString("Vietnam", comment: "")
    ]

    static let flags = [
        UIImage(named: "NotSet"),
        UIImage(named: "Australia"),
        UIImage(named: "Brazil"),
        UIImage(named: "Canada"),
        UIImage(named: "China"),
        UIImage(named: "Egypt"),
        UIImage(named: "France"),
        UIImage(named: "Germany"),
        UIImage(named: "Hong Kong"),
        UIImage(named: "India"),
        UIImage(named: "Indonesia"),
        UIImage(named: "Italia"),
        UIImage(named: "Japan"),
        UIImage(named: "Malaysia"),
        UIImage(named: "New Zealand"),
        UIImage(named: "Russia"),
        UIImage(named: "Singapore"),
        UIImage(named: "South Korea"),
        UIImage(named: "Spain"),
        UIImage(named: "Taiwan"),
        UIImage(named: "The Philippines"),
        UIImage(named: "Thailand"),
        UIImage(named: "Turkey"),
        UIImage(named: "UK"),
        UIImage(named: "U.S."),
        UIImage(named: "Vietnam")
    ]

    func string() -> String {
        let index = Nationality.all.firstIndex(of: self) ?? 0
        return Nationality.strings[index]
    }

    static func fromString(string: String) -> Nationality {
        if let index = Nationality.strings.firstIndex(of: string) {
            return Nationality.all[index]
        }
        return Nationality.NotSet
    }
}

enum Language: Int {
    case NotSet = 0
    case Arabic = 1
    case Bengali = 2
    case Chinese = 3
    case Cantonese = 4
    case English = 5
    case French = 6
    case German = 7
    case Hindi = 8
    case Indonesian = 9
    case Italian = 10
    case Japanese = 11
    case Korean = 12
    case Portuguese = 13
    case Russian = 14
    case Spanish = 15
    case Tagalog = 16
    case Thai = 17
    case Turkish = 18
    case Vietnamese = 19

    static let all      = [NotSet, Arabic, Bengali, Chinese, Cantonese, English, French, German, Hindi, Indonesian, Italian, Japanese, Korean, Portuguese, Russian, Spanish, Tagalog, Thai, Turkish, Vietnamese]
    static let strings  = [NSLocalizedString("Not set", comment: ""),
                           NSLocalizedString("Arabic", comment: ""),
                           NSLocalizedString("Bengali", comment: ""),
                           NSLocalizedString("Chinese", comment: ""),
                           NSLocalizedString("Cantonese", comment: ""),
                           NSLocalizedString("English", comment: ""),
                           NSLocalizedString("French", comment: ""),
                           NSLocalizedString("German", comment: ""),
                           NSLocalizedString("Hindi", comment: ""),
                           NSLocalizedString("Indonesian", comment: ""),
                           NSLocalizedString("Italian", comment: ""),
                           NSLocalizedString("Japanese", comment: ""),
                           NSLocalizedString("Korean", comment: ""),
                           NSLocalizedString("Portuguese", comment: ""),
                           NSLocalizedString("Russian", comment: ""),
                           NSLocalizedString("Spanish", comment: ""),
                           NSLocalizedString("Tagalog", comment: ""),
                           NSLocalizedString("Thai", comment: ""),
                           NSLocalizedString("Turkish", comment: ""),
                           NSLocalizedString("Vietnamese", comment: "")
    ]

    static let shortStrings  = ["NO",
                               "AR",
                               "BN",
                               "CN",
                               "Canto",
                               "EN",
                               "FR",
                               "DE",
                               "HI",
                               "ID",
                               "IT",
                               "JP",
                               "KR",
                               "PT",
                               "RU",
                               "ES",
                               "TL",
                               "TH",
                               "TR",
                               "VI"
    ]

    func string() -> String {
        let index = Language.all.firstIndex(of: self) ?? 0
        return Language.strings[index]
    }

    static func fromString(string: String) -> Language {
        if let index = Language.strings.firstIndex(of: string) {
            return Language.all[index]
        }
        return Language.NotSet
    }
}

enum Method: Int {
    case Unknown            = 0
    case Call               = 1
    case Bonus              = 2
    case Purchase           = 3

    static let all      = [Unknown, Call, Bonus, Purchase]
    static let strings  = [NSLocalizedString("Unknown", comment: ""), NSLocalizedString("Call", comment: ""), NSLocalizedString("Login bonus", comment: ""),NSLocalizedString("Purchase", comment: "")]

    func string() -> String {
        let index = Method.all.firstIndex(of: self) ?? 0
        return Method.strings[index]
    }

    static func fromString(string: String) -> Method {
        if let index = Method.strings.firstIndex(of: string) {
            return Method.all[index]
        }
        return Method.Unknown
    }
}

enum Proficiency: Int {
    case NotSet               = 0
    case Beginner           = 1
    case PreIntermediate    = 2
    case Intermediate       = 3
    case PreAdvanced        = 4
    case Advanced           = 5

    static let all      = [NotSet, Beginner, PreIntermediate, Intermediate, PreAdvanced, Advanced]
    static let strings  = [NSLocalizedString("Not set", comment: ""), NSLocalizedString("Beginner", comment: ""), NSLocalizedString("PreIntermediate", comment: ""), NSLocalizedString("Intermediate", comment: ""), NSLocalizedString("PreAdvanced", comment: ""), NSLocalizedString("Advanced", comment: "")]

    func string() -> String {
        let index = Proficiency.all.firstIndex(of: self) ?? 0
        return Proficiency.strings[index]
    }

    static func fromString(string: String) -> Proficiency {
        if let index = Proficiency.strings.firstIndex(of: string) {
            return Proficiency.all[index]
        }
        return Proficiency.NotSet
    }
}
