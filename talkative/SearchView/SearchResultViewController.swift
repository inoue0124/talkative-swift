//
//  SearchResultViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Firebase

class SearchResultViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    var selectedOffer: OfferModel?
    var offers: [OfferModel]?
    let offersDb = Firestore.firestore().collection("offers")
    let usersDb = Firestore.firestore().collection("Users")
    var refreshControl:UIRefreshControl!
    let semaphore = DispatchSemaphore(value: 1)
    var selectedNativeID: String?
    var searchConditions: [String:Any]?

    @IBOutlet weak var SearchResultTable: UITableView!

  override func viewDidLoad() {
    SearchResultTable.dataSource = self
    SearchResultTable.delegate = self
    SearchResultTable.register(UINib(nibName: "nativeListRowTableViewCell", bundle: nil), forCellReuseIdentifier:"recycleCell")
    refreshControl = UIRefreshControl()
    refreshControl.attributedTitle = NSAttributedString(string: LString("Reloading"))
    refreshControl.addTarget(self, action: #selector(SearchResultViewController.refresh), for: UIControl.Event.valueChanged)
    SearchResultTable.addSubview(refreshControl)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        SearchResultTable.allowsSelection = true
        self.navigationItem.title = LString("Result")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.offersDb.whereField("isOnline", isEqualTo: true)
            .whereField("targetLanguage", isEqualTo: self.searchConditions!["targetLanguage"]!)
            .whereField("offerPrice", isLessThanOrEqualTo: self.searchConditions!["maxPrice"]!).getDocuments() { snapshot, error in
         if let _error = error {
             print("error\(_error)")
             return
         }
         guard let documents = snapshot?.documents else {
         print("error")
            return
        }
         self.offers = documents.map{ OfferModel(from: $0) }
        self.SearchResultTable.reloadData()
    }
    }

    func updateTable () {
        DispatchQueue.global().async {

         self.offersDb.whereField("isOnline", isEqualTo: true)
                .whereField("targetLanguage", isEqualTo: self.searchConditions!["targetLanguage"]!)
                .whereField("offerPrice", isLessThanOrEqualTo: self.searchConditions!["maxPrice"]!).getDocuments() { snapshot, error in
                 if let _error = error {
                     print("error\(_error)")
                     return
                 }
                 guard let documents = snapshot?.documents else {
                 print("error")
                    return
                }
                 self.offers = documents.map{ OfferModel(from: $0) }
            }
            DispatchQueue.main.async {
                // UI更新はメインスレッドで実行
                self.SearchResultTable.reloadData()
                self.semaphore.signal()
            }
        }
    }

    @objc func refresh() {
        updateTable()
        semaphore.wait()
        semaphore.signal()
        refreshControl.endRefreshing()
    }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return offers?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt numOfCells: IndexPath) -> UITableViewCell {
    let tableContent = tableView.dequeueReusableCell(withIdentifier: "recycleCell", for: numOfCells) as! nativeListRowTableViewCell
    tableContent.setRowData(numOfCells: numOfCells, offer: self.offers![numOfCells.row])
    return tableContent
  }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOffer = self.offers![indexPath.row]
        tableView.allowsSelection = false
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showNativeDetailView", sender: nil)
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNativeDetailView" {
            let DetailVC = segue.destination as! nativeDetailViewController
            DetailVC.offer = self.selectedOffer
        }
    }

    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
