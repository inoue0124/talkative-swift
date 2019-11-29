//
//  historyViewPager.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/11/13.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class historyViewPager: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
        }
        navigationItem.title = LString("History")
        navigationItem.largeTitleDisplayMode = .never
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //管理されるViewControllerを返す処理
        let firstVC = UIStoryboard(name: "HistoryView", bundle: nil).instantiateViewController(withIdentifier: "First")
        let secondVC = UIStoryboard(name: "teachHistoryView", bundle: nil).instantiateViewController(withIdentifier: "Second")
        return [firstVC, secondVC]
    }
}
