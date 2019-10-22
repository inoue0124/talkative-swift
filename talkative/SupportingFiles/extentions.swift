//
//  extentions.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import RealmSwift

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
