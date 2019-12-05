//
//  SearchResultViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase
import Eureka
import DZNEmptyDataSet

class SearchResultViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    var selectedOffer: OfferModel?
    var natives: [UserModel]?
    var native: UserModel?
    let offersDb = Firestore.firestore().collection("offers")
    let usersDb = Firestore.firestore().collection("Users")
    var refreshControl:UIRefreshControl!
    let semaphore = DispatchSemaphore(value: 1)
    var selectedNativeID: String?
    var searchConditions: [String:Any?]?
    var targetLanguage: Int?

    @IBOutlet weak var SearchResultTable: UITableView!

    override func viewDidLoad() {
        SearchResultTable.dataSource = self
        SearchResultTable.delegate = self
        SearchResultTable.emptyDataSetDelegate = self
        SearchResultTable.emptyDataSetSource = self
        SearchResultTable.register(UINib(nibName: "nativeListRowTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: LString("Reloading"))
        refreshControl.addTarget(self, action: #selector(SearchResultViewController.refresh), for: UIControl.Event.valueChanged)
        SearchResultTable.addSubview(refreshControl)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tabBarController?.tabBar.isHidden = true
        navigationItem.largeTitleDisplayMode = .never
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        SearchResultTable.allowsSelection = true
        navigationItem.title = LString("Result")
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
        getNativeData()
    }

    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    func updateTable () {
        getNativeData()
    }

    @objc func refresh() {
        updateTable()
        semaphore.wait()
        semaphore.signal()
        refreshControl.endRefreshing()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return natives?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt numOfCells: IndexPath) -> UITableViewCell {
        let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! nativeListRowTableViewCell
        tableContent.setRowData(numOfCells: numOfCells, native: self.natives![numOfCells.row])
        return tableContent
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsSelection = false
        tableView.deselectRow(at: indexPath, animated: true)
        self.native = self.natives![indexPath.row]
        self.performSegue(withIdentifier: "showNativeDetailView", sender: nil)
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNativeDetailView" {
            let DetailVC = segue.destination as! userDetailViewController
            DetailVC.user = self.native
            DetailVC.offer = self.selectedOffer
            DetailVC.tabIndex = 0
        }
    }

    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func getNativeData() {
        usersDb.getDocuments() { snapshot, error in
            if let _error = error {
                print("error\(_error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("error")
                return
            }
            self.natives = documents.map{ UserModel(from: $0) }
            if let online = self.searchConditions!["online"] as? Bool {
                if online == true {
                    self.natives = self.natives!.filter{ $0.isOffering == true }
                }
            }
            if let age = self.searchConditions!["age"] as? Eureka.Tuple<Int, Int> {
                self.natives = self.natives!.filter{ age.a <= self.birthDateToAge(byBirthDate: $0.birthDate)}
                self.natives = self.natives!.filter{ age.b >= self.birthDateToAge(byBirthDate: $0.birthDate)}
            }
            if let gender = self.searchConditions!["gender"] as? String {
                self.natives = self.natives!.filter{ $0.gender == Gender.fromString(string: gender).rawValue }
            }
            if let nationality = self.searchConditions!["nationality"] as? String {
                self.natives = self.natives!.filter{ $0.nationality == Nationality.fromString(string: nationality).rawValue }
            }
            if let teachLanguage = self.searchConditions!["teachLanguage"] as? String {
                self.natives = self.natives!.filter{ $0.teachLanguage == Language.fromString(string: teachLanguage).rawValue }
            }
            if let studyLanguage = self.searchConditions!["studyLanguage"] as? String {
                self.natives = self.natives!.filter{ $0.studyLanguage == Language.fromString(string: studyLanguage).rawValue }
                if let proficiency = self.searchConditions!["proficiency"] as? Eureka.Tuple<String, String> {
                    self.natives = self.natives!.filter{ Proficiency.fromString(string: proficiency.a).rawValue <= $0.proficiency}
                    self.natives = self.natives!.filter{ Proficiency.fromString(string: proficiency.b).rawValue >= $0.proficiency}
                }
            }
            self.SearchResultTable.reloadData()
            self.semaphore.signal()
        }
    }
}

extension SearchResultViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "user")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = LString("Tutor not found")
        return NSAttributedString(string: text)
    }
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        SearchResultTable.separatorStyle = .none
    }
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView!) {
        SearchResultTable.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
    }
}
