//
//  SearchConditionViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/08.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Eureka

class SearchCondtionViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(header: NSLocalizedString("conditions", comment: ""), footer: "*1分=1ポイント")
            <<< AlertRow<String> {
                $0.title = NSLocalizedString("conditions_language", comment: "")
                $0.options = Language.strings
                $0.value = Language.strings[getUserData().secondLanguage]
                $0.tag = "targetLanguage"
            }.cellUpdate { cell, row in
                cell.height = ({return 80})
            }

            <<< IntRow() {
                $0.title = NSLocalizedString("conditions_time", comment: "")
                $0.value = 10
                $0.tag = "maxPrice"
            }.cellUpdate { cell, row in
                cell.height = ({return 80})
            }

        +++ Section("")
            <<< ButtonRow() {
                $0.title = NSLocalizedString("search", comment: "")
                $0.onCellSelection(self.buttonTapped)
            }.cellUpdate { cell, row in
                cell.height = ({return 80})
            }
    }

    func buttonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        let searchConditions = form.values()
        let tabVc = self.presentingViewController as! UITabBarController
        let navigationVc = tabVc.selectedViewController as! UINavigationController
        let searchViewVc = navigationVc.topViewController as! SearchViewController
        searchViewVc.searchConditions = searchConditions
        searchViewVc.showSearchResult()
        dismiss(animated: true, completion: nil)
    }
}


