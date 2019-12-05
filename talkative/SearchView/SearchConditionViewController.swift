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

    var searchConditions: [String : Any?]?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.title = LString("Search")
        navigationItem.largeTitleDisplayMode = .never
        form +++ Section()

            <<< SwitchRow() {
                $0.title = LString("Only online")
                $0.value = true
                $0.tag = "online"
            }

            <<< DoublePickerInputRow<Int, Int>() {
                $0.title = LString("Age")
                $0.firstOptions = {([Int])(18...90)}
                $0.secondOptions = { _ in return ([Int])(18...90)}
                $0.value = Tuple(a:18, b:90)
                $0.tag = "age"
            }.onChange{ row in
                if row.value!.a > row.value!.b {
                    row.value = Tuple(a:row.value!.a, b:row.value!.a)
                }
            }

            <<< ActionSheetRow<String> {
                $0.title = LString("Gender")
                $0.options = Array(Gender.strings.dropFirst(1))
                $0.tag = "gender"
            }

            <<< PushRow<String> {
                $0.title = LString("Nationality")
                $0.options = Array(Nationality.strings.dropFirst(1))
                $0.tag = "nationality"
            }

        +++ Section()
            <<< PushRow<String> {
                $0.title = LString("Teaching language")
                $0.options = Array(Language.strings.dropFirst(1))
                $0.tag = "teachLanguage"
            }

            <<< PushRow<String> {
                $0.title = LString("Also speak")
                $0.options = Array(Language.strings.dropFirst(1))
                $0.tag = "studyLanguage"
            }

            <<< DoublePickerInputRow<String, String>() {
                $0.title = LString("Teachers' Second language proficiency")
                $0.firstOptions = {Proficiency.strings}
                $0.secondOptions = { _ in return Proficiency.strings}
                $0.value = Tuple(a: Proficiency.strings[1], b: Proficiency.strings[5])
                $0.tag = "proficiency"
            }.onChange{ row in
                if Proficiency.fromString(string: row.value!.a).rawValue > Proficiency.fromString(string: row.value!.b).rawValue {
                    row.value = Tuple(a:row.value!.a, b:row.value!.a)
                }
            }


        +++ Section()
            <<< DoublePickerInputRow<Int, Int>() {
                $0.title = LString("Length of call time")
                $0.firstOptions = {([Int])(5...30)}
                $0.secondOptions = { _ in return ([Int])(5...30)}
                $0.value = Tuple(a:5, b:30)
                $0.tag = "maxPrice"
            }.onChange{ row in
                if row.value!.a > row.value!.b {
                    row.value = Tuple(a:row.value!.a, b:row.value!.a)
                }
            }


        +++ Section()
            <<< ButtonRow() {
                $0.title = LString("search")
                $0.onCellSelection(self.buttonTapped)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    func buttonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        searchConditions = form.values()
        performSegue(withIdentifier: "showResult", sender: nil)
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            let ResultVC = segue.destination as! SearchResultViewController
            ResultVC.searchConditions = searchConditions
            ResultVC.navigationItem.rightBarButtonItems?.remove(at: 0)
        }
    }
}


