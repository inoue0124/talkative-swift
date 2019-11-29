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
import FirebaseStorage
import SCLAlertView

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
//        navigationController?.navigationBar.titleTextAttributes = [
//            .foregroundColor: UIColor.black
//        ]
        //laegeTitle(大)時の文字色
        navigationController?.navigationBar.largeTitleTextAttributes = [
//            .foregroundColor: UIColor.black,
            .font : UIFont.boldSystemFont(ofSize: 26.0)
        ]

        //largeTitle時のnavigationBarのボーダを消す。戻す場合はnil代入
        navigationController?.navigationBar.shadowImage = UIImage()

        //largetitleの適用時の画面遷移でチラ見する黒背景はコイツ
        navigationController!.view.backgroundColor = UIColor.white
    }
}

extension UIViewController {
    func birthDateToAge(byBirthDate birthDate: Date) -> Int {
        let timezone: NSTimeZone = NSTimeZone.system as NSTimeZone
        let localDate = NSDate(timeIntervalSinceNow: Double (timezone.secondsFromGMT)) as Date

        let localDateIntVal = Int(string(localDate, format: "yyyyMMdd"))
        let birthDateIntVal = Int(string(birthDate, format: "yyyyMMdd"))
        let age = (localDateIntVal! - birthDateIntVal!) / 10000
        print(age)
        return age
    }
    func string(_ date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date as Date)
    }
}

extension UIViewController {
    func makeFlagImageView(imageView: UIImageView, nationality: Int, radius: CGFloat) {
        imageView.image = Nationality.flags[nationality]
        imageView.layer.cornerRadius = radius
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 0.5
    }
}

extension UIView {
    func makeFlagImageView(imageView: UIImageView, nationality: Int, radius: CGFloat) {
        imageView.image = Nationality.flags[nationality]
        imageView.layer.cornerRadius = radius
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 0.5
    }
}

extension UIViewController {
    func designTextView(textView: UITextView) {
        textView.layer.borderColor = UIColor.blue.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 10.0
        textView.layer.masksToBounds = true
    }
}

extension UIViewController {

    func getUserData() -> RealmUserModel {
        let realm = try! Realm()
        return realm.objects(RealmUserModel.self)[0]
    }

    func getUserUid() -> String {
        let realm = try! Realm()
        return realm.objects(RealmUserModel.self)[0].uid
    }

    func errorMessage(of error: Error) -> String {
        var message = NSLocalizedString("Error", comment: "")
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }

        switch errcd {
        case .networkError: message = LString("Cannot connect to the Internert")
        case .userNotFound: message = LString("User not found")
        case .invalidEmail: message = LString("Invalid Email")
        case .emailAlreadyInUse: message = LString("The Email is already used")
        case .wrongPassword: message = LString("Wrong password")
        case .userDisabled: message = LString("This user is banned")
        case .weakPassword: message = LString("The password is too weak")
        default: break
        }
        return message
    }

    func showError(_ errorOrNil: Error?) {
        guard let error = errorOrNil else { return }
        let message = errorMessage(of: error)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LString("OK"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {

    func showPreloader() {
        let image:UIImage? = UIImage.gif(name: "Preloader2")
        let imageView:UIImageView! = UIImageView(image:image)
        imageView.frame = CGRect(x: self.view.bounds.width/2-25,
                                 y: self.view.bounds.height/2-25,
                                 width: 50,
                                 height: 50)
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 1

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

extension UIViewController {

    func LString(_ string: String) -> String {
        return NSLocalizedString(string, comment: "")
    }
}

extension UIViewController {
    func setGenderIcon(gender: Int?, imageView: UIImageView) {
        if gender == 1 {
            imageView.image = UIImage(named: "male")!.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor.blue
            imageView.tintColorDidChange()
        } else if gender == 2 {
            imageView.image = UIImage(named: "female")!.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor.red
            imageView.tintColorDidChange()
        }
    }
}

extension UIViewController {
    func checkUnpaidOfferNative(completion: @escaping (Bool) -> ()) {
        let offersDB = Firestore.firestore().collection("offers")
        offersDB.whereField("nativeID", isEqualTo: getUserUid()).getDocuments() { snapshot, error in
            if let _error = error {
                self.showError(_error)
                return
            }
            guard let documents = snapshot?.documents else {
                return
            }
            var offers = documents.map{ OfferModel(from: $0) }
            print(offers)
            offers = offers.filter{ $0.flagPayForNative == false && $0.isAccepted == true}
            print(offers)
            if !offers.isEmpty {
                let alert = SCLAlertView()
                alert.addButton(self.LString("OK")) { return }
                alert.showError(self.LString("Confirm payment"), subTitle: self.LString("未評価の授業があります。"))
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

extension UIViewController {
    func reloadUserRating() {
        let usersDB = Firestore.firestore().collection("Users")
        usersDB.whereField("uid", isEqualTo: getUserUid()).getDocuments() { snapshot, error in
            if let _error = error {
                self.showError(_error)
                return
            }
            guard let documents = snapshot?.documents else {
                return
            }
            let downloadedUserData = documents.map{ UserModel(from: $0) }
            let realm = try! Realm()
            let UserData = realm.objects(RealmUserModel.self)
            if let UserData = UserData.first {
                try! realm.write {
                    UserData.ratingAsNative = downloadedUserData[0].ratingAsNative
                }
            }
        }
    }
}

extension UIView {
    func LString(_ string: String) -> String {
        return NSLocalizedString(string, comment: "")
    }
}

extension UIView {
    func makeFollowButton(button: UIButton, isFollowing: Bool) {
        button.backgroundColor = UIColor(red: 56/255, green: 180/255, blue: 139/255, alpha: 1)
        button.setTitle(LString("+Follow"), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 2.0
        if isFollowing {
            button.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            button.setTitle(LString("Followed"), for: .normal)
            button.setTitleColor(UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1), for: .normal)
        }
    }
}

extension UIView {
    func setImage(uid: String, imageView: UIImageView?){
        let storageRef = Storage.storage().reference()
        let ref = storageRef.child("profImages/\(uid).jpg")
        let placeholder = UIImage(named: "avatar")
        imageView?.sd_setImage(with: ref, placeholderImage: placeholder)
    }
}

extension UIViewController {
    func setImage(uid: String, imageView: UIImageView?){
        let storageRef = Storage.storage().reference()
        let ref = storageRef.child("profImages/\(uid).jpg")
        imageView?.sd_setImage(with: ref, placeholderImage: nil)
    }
}

enum BorderPosition {
    case top
    case left
    case right
    case bottom
}

extension UIButton {
    /// 特定の場所にborderをつける
    ///
    /// - Parameters:
    ///   - width: 線の幅
    ///   - color: 線の色
    ///   - position: 上下左右どこにborderをつけるか
    func addBorder(width: CGFloat, color: UIColor, position: BorderPosition) {

        let border = CALayer()

        switch position {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: width)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        case .right:
            print(self.frame.width)

            border.frame = CGRect(x: self.frame.width - width, y: 0, width: width, height: self.frame.height)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        case .bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - width, width: self.frame.width, height: width)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        }
    }
}

extension UIViewController {
    func makeFollowButton(button: UIButton, isFollowing: Bool) {
        button.backgroundColor = UIColor(red: 56/255, green: 180/255, blue: 139/255, alpha: 1)
        button.setTitle(LString("+Follow"), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        if isFollowing {
            button.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            button.setTitle(LString("Followed"), for: .normal)
            button.setTitleColor(UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1), for: .normal)
        }
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

extension UIImage {
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }

    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}

extension UIColor {
    func circleImage(size: CGSize) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(self.cgColor)
        context!.fillEllipse(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
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
