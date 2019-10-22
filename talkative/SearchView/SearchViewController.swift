//
//  FirstViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/08.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import FirebaseAuth
import RealmSwift

class SearchViewController: UIViewController {
    var natives: [UserModel]?
    var searchConditions: [String:Any]?

    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
//        var config = Realm.Configuration()
//        config.deleteRealmIfMigrationNeeded = true
//        let realm = try! Realm(configuration: config)
//        do {
//            try Auth.auth().signOut()
//        } catch let error {
//            print(error)
//        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //searchButton.layer.backgroundColor = UIColor.green.cgColor
        //searchButton.layer.cornerRadius = 50
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
    }

    @IBAction func presentConditions(_ sender: Any) {
        performSegue(withIdentifier: "presentConditions", sender: nil)
    }

    func showSearchResult() {
        print(self.searchConditions)
        performSegue(withIdentifier: "showResult", sender: nil)
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            let ResultVC = segue.destination as! SearchResultViewController
            ResultVC.searchConditions = self.searchConditions
        }
    }
}

