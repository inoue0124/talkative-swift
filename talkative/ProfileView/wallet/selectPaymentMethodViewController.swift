//
//  selectPaymentMethodViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/11/12.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAuth
import SwiftGifOrigin
import RealmSwift
import SCLAlertView
import Stripe
import FirebaseFirestore
import FirebaseFunctions
import Hydra

class selectPaymentMethodViewController: UIViewController {

    let paymentDb = Firestore.firestore().collection("stripe_customers")
    private var paymentContext: STPPaymentContext?
    private let useCase = StripeUseCase()
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var payButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func buttonTapped(_ sender: Any) {
        self.paymentDb.document(self.getUserUid()).getDocument { document, error in
            if let document = document, document.exists {
                let customerId = document.data()!["customer_id"] as! String
                let customerContext = STPCustomerContext(keyProvider: StripeProvider(customerId: customerId))
                self.paymentContext = STPPaymentContext(customerContext: customerContext)
                self.paymentContext!.delegate = self
                self.paymentContext!.hostViewController = self
                self.paymentContext!.paymentAmount = 5000
                self.paymentContext!.presentPaymentOptionsViewController()
            } else {
                print("Document does not exist")
            }
        }
    }

    @IBAction func payButtonTapped(_ sender: Any) {
        paymentContext?.requestPayment()
    }
}

class StripeProvider: NSObject, STPCustomerEphemeralKeyProvider {
    lazy var functions = Functions.functions()
    let customerId: String

    init(customerId: String){
        self.customerId = customerId
    }

    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let data: [String: Any] = [
            "customerId": self.customerId,
            "stripe_version": apiVersion
        ]
        functions.httpsCallable("createStripeEphemeralKeys").call(data) { result, error in
            if let error = error {
                print("error\(error)")
                completion(nil, error)
            } else if let data = result?.data as? [String: Any] {
                completion(data, nil)
            }
        }
    }
}

extension selectPaymentMethodViewController: STPPaymentContextDelegate {

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("paymentContextDidChange")
        cardNameLabel.text = paymentContext.selectedPaymentOption?.label
        cardImageView.image = paymentContext.selectedPaymentOption?.image
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("didFailToLoadWithError")
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        print("didCreatePaymentResult")
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        print("error in didCreatePaymentResult")
//        let sourceId = paymentResult.paymentMethod!.stripeId
//        let paymentAmount = paymentContext.paymentAmount
//        useCase.charge(sourceId: sourceId, amount: paymentAmount).then {_ in
//            completion(nil, Error)
//            }.catch { error in
//                completion(error)
//        }
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print("didFinishWith")

        switch status {
        case .error:
            self.showErrorDialog(error!)
        case .success:
            self.showOKDialog(title: "決済に成功しました")
        case .userCancellation:
            break
        @unknown default:
            break
        }
        print(status)
    }
}

extension selectPaymentMethodViewController {
    func showOKDialog(title: String, message: String? = nil, ok: String = "OK", completion: (() -> Void)? = nil){
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: ok, style: .default, handler: { _ in
                completion?()
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showErrorDialog(_ error: Error, completion: (() -> Void)? = nil){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: error.localizedDescription,
                                          message: nil, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion?()
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

class StripeUseCase {
    private let stripeRepo = StripeRepository()

    private func createStripeCustomerId(email: String) -> Promise<String> {
        return stripeRepo.createCustomerId(email: email)
    }

    func charge(sourceId: String, amount: Int) -> Promise<Void> {
        guard let customerId = UserDataStore.getString(.stripeCustomerId) else {
            return Promise<Void>.init(rejected: ClientError.cast)
        }
        return stripeRepo.createCharge(customerId: customerId, sourceId: sourceId, amount: amount)
    }
}

class StripeRepository {
    lazy var functions = Functions.functions()

    func createCustomerId(email: String) -> Promise<String> {
        return Promise<String> (in: .background, { resolve, reject, _ in
            let data: [String: Any] = [
                "email": email
            ]
            self.functions.httpsCallable("createStripeCustomer").call(data) { result, error in
                    if let error = error {
                        print(error.localizedDescription)
                        reject(error)
                    } else if let data = result?.data as? [String: Any],
                        let customerId = data["customerId"] as? String {
                        resolve(customerId)
                    } else {
                        reject(ClientError.noData)
                    }
            }
        })
    }

    func createCharge(customerId: String, sourceId: String, amount: Int) -> Promise<Void> {
        return Promise<Void> (in: .background, { resolve, reject, _ in
            let data: [String: Any] = [
                "customerId": customerId,
                "sourceId": sourceId,
                "amount": amount,
                "idempotencyKey": UUID().uuidString
            ]
            self.functions.httpsCallable("createStripeCharge").call(data) { result, error in
                if let error = error {
                    reject(error)
                } else {
                    resolve(())
                }
            }
        })
    }
}

class UserDataStore {
    private static let userDefaults = UserDefaults.standard

    enum UserKeys: String {
        case stripeCustomerId
    }

    static func setString(_ key: UserKeys, string: String){
        userDefaults.set(string, forKey: key.rawValue)
    }

    static func getString(_ key: UserKeys) -> String? {
        guard let string = userDefaults.string(forKey: key.rawValue) else {
            return nil
        }
        return string
    }
}

enum ClientError: LocalizedError {
    case noData
    case cast
}
