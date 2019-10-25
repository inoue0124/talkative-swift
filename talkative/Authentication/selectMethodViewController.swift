//
//  selectMethodViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/24.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseFirestore

class selectMethodViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController!.navigationBar.shadowImage = nil
    }
}
