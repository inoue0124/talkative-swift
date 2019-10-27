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
import FirebaseFirestore

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

    func showPreloader() {
        let image:UIImage? = UIImage.gif(name: "Preloader2")
        let imageView:UIImageView! = UIImageView(image:image)
        imageView.frame = CGRect(x: self.view.bounds.width/2-25,
                                 y: self.view.bounds.height/2-25,
                                 width: 50,
                                 height: 50)
        imageView.layer.cornerRadius = 10

        //インスタンスビューに表示して一番前に表示
        self.view.addSubview(imageView)
        self.view.bringSubviewToFront(imageView)
        self.view.isUserInteractionEnabled = false
    }

    func dissmisPreloader() {
        self.view.isUserInteractionEnabled = true
        self.view.subviews.last?.removeFromSuperview()
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

class DismissControllerSegue: UIStoryboardSegue {
    override func perform() {
        self.source.dismiss(animated: true, completion: nil)
    }
}

class AppEventHandler: NSObject {
    let Usersdb = Firestore.firestore().collection("Users")
    static let sharedInstance = AppEventHandler()
    let uid = String(describing: Auth.auth().currentUser?.uid ?? "Error")

    override private init() {
        super.init()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // 各イベントの通知を受け取れるよう、NotificationCenterに自身を登録
    func startObserving() {
        // アプリ起動時
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishLaunch),
                                               name: UIApplication.didFinishLaunchingNotification, object: nil)

        // フォアグラウンド復帰時
        NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)

        // バックグラウンド移行時
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)

        // アプリ終了時
        NotificationCenter.default.addObserver(self, selector: #selector(self.willTerminate),
                                               name: UIApplication.willTerminateNotification, object: nil)
    }

    // アプリ起動時の処理
    @objc func didFinishLaunch() {
        self.Usersdb.document(self.uid).setData(["isOnline" : true], merge: true)
    }

    // フォアグラウンドへの復帰時の処理
    @objc func willEnterForeground() {
        self.Usersdb.document(self.uid).setData(["isOnline" : true], merge: true)
    }

    // バックグラウンドへの移行時の処理
    @objc func didEnterBackground() {
    }

    // アプリ終了時の処理
    @objc func willTerminate() {
        self.Usersdb.document(self.uid).setData(["isOnline" : false], merge: true)
        sleep(1)
        NotificationCenter.default.removeObserver(self)
    }
}
