//
//  Settings.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/13.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

enum Gender: Int {
    case Unknown        = 0
    case Male           = 1
    case Female         = 2

    static let all      = [Unknown, Male, Female]
    static let strings  = ["回答なし", "男", "女"]

    func string() -> String {
        let index = Gender.all.firstIndex(of: self) ?? 0
        return Gender.strings[index]
    }

    static func fromString(string: String) -> Gender {
        if let index = Gender.strings.firstIndex(of: string) {
            return Gender.all[index]
        }
        return Gender.Unknown
    }
}

enum Nationality: Int {
    case Unknown            = 0
    case Japanese           = 1
    case American           = 2
    case Chinese            = 3

    static let all      = [Unknown, Japanese, American, Chinese]
    static let strings  = ["回答なし", "日本","アメリカ","中国"]

    func string() -> String {
        let index = Nationality.all.firstIndex(of: self) ?? 0
        return Nationality.strings[index]
    }

    static func fromString(string: String) -> Nationality {
        if let index = Nationality.strings.firstIndex(of: string) {
            return Nationality.all[index]
        }
        return Nationality.Unknown
    }
}

enum Language: Int {
    case Unknown            = 0
    case Japanese           = 1
    case English            = 2
    case Chinese            = 3

    static let all      = [Unknown, Japanese, English, Chinese]
    static let strings  = ["なし", "日本語","英語","中国語"]

    func string() -> String {
        let index = Language.all.firstIndex(of: self) ?? 0
        return Language.strings[index]
    }

    static func fromString(string: String) -> Language {
        if let index = Language.strings.firstIndex(of: string) {
            return Language.all[index]
        }
        return Language.Unknown
    }
}
