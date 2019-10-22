//
//  extentions.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth

extension UITableViewCell {
    func getUserData() -> RealmUserModel {
        let realm = try! Realm()
        return realm.objects(RealmUserModel.self)[0]
    }

    func getUserUid() -> String {
        let realm = try! Realm()
        return realm.objects(RealmUserModel.self)[0].uid
    }
}

extension UIViewController {
    /// NavigationBarの左にローカライズされたタイトルを表示する
    func largeTitle(_ title: String) {
        navigationItem.title = title
        navigationController!.navigationBar.barTintColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        //laegeTitle(小)時の文字色
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black
        ]
        //laegeTitle(大)時の文字色
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font : UIFont.boldSystemFont(ofSize: 26.0)
        ]

        //largeTitle時のnavigationBarのボーダを消す。戻す場合はnil代入
        navigationController?.navigationBar.shadowImage = UIImage()

        //largetitleの適用時の画面遷移でチラ見する黒背景はコイツ
        navigationController!.view.backgroundColor = UIColor.white
    }

    func getUserData() -> RealmUserModel {
        let realm = try! Realm()
        return realm.objects(RealmUserModel.self)[0]
    }

    func getUserUid() -> String {
        let realm = try! Realm()
        return realm.objects(RealmUserModel.self)[0].uid
    }

    func errorMessage(of error: Error) -> String {
        var message = "エラーが発生しました"
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }

        switch errcd {
        case .networkError: message = "ネットワークに接続できません"
        case .userNotFound: message = "ユーザが見つかりません"
        case .invalidEmail: message = "不正なメールアドレスです"
        case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
        case .wrongPassword: message = "入力した認証情報でサインインできません"
        case .userDisabled: message = "このアカウントは無効です"
        case .weakPassword: message = "パスワードが脆弱すぎます"
        default: break
        }
        return message
    }

    func showError(_ errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        let message = errorMessage(of: error)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension UIImage {
    
    var scaledToSafeUploadSize: UIImage? {
      let maxImageSideLength: CGFloat = 100

      let largerSide: CGFloat = max(size.width, size.height)
      let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
      let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)

      return image(scaledTo: newImageSize)
    }

    func image(scaledTo size: CGSize) -> UIImage? {
      defer {
        UIGraphicsEndImageContext()
      }

      UIGraphicsBeginImageContextWithOptions(size, true, 0)
      draw(in: CGRect(origin: .zero, size: size))

      return UIGraphicsGetImageFromCurrentImageContext()
    }

    public convenience init(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
