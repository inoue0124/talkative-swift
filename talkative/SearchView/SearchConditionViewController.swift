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
        form +++ Section(NSLocalizedString("conditions", comment: ""))
            <<< AlertRow<String> {
                $0.title = NSLocalizedString("conditions_language", comment: "")
                $0.options = [Language.Japanese.string(), Language.English.string(), Language.Chinese.string()]
                $0.value = Language.English.string()
                $0.tag = "targetLanguage"
            }

            <<< IntRow() {
                $0.title = NSLocalizedString("conditions_price", comment: "")
                $0.placeholder = "¥100"
                $0.value = 100
                $0.tag = "maxPrice"
            }

            <<< IntRow() {
                $0.title = NSLocalizedString("conditions_time", comment: "")
                $0.placeholder = "15分"
                $0.value = 15
                $0.tag = "timeLength"
            }

        +++ Section("")
            <<< ButtonRow() {
                $0.title = NSLocalizedString("search", comment: "")
                $0.onCellSelection(self.buttonTapped)
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


