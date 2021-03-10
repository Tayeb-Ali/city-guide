//
//  PurchaseManager.swift
//  trid
//
//  Created by Black on 5/5/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseManager: NSObject {
    static let shared = PurchaseManager()
    
    static let ItemPrefix = "vn.leaestudio.trid"
    static let ItemAll = "vn.leaestudio.trid.all_cities"
    
    // Variables
    var products = [SKProduct]()
    
    var fetchCompleted : (() -> Void)?
    var purchasedCompleted: ((_ result: String?, _ error: String?) -> Void)?
    var restoredCompleted: ((_ result: [String]?, _ error: String?) -> Void)?
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchProductForCity(id: String, completed: @escaping (() -> Void)){
        var ids : [String] = []
        let checkCity = products.first(where: {p in
            return p.productIdentifier == id
        })
        if checkCity == nil {
            ids.append(id)
        }
        let checkAll = products.first(where: {p in
            return p.productIdentifier == PurchaseManager.ItemAll
        })
        if checkAll == nil {
            ids.append(PurchaseManager.ItemAll)
        }
        if ids.count > 0 {
            fetchCompleted = completed
            fetchAvailableProducts(ids: [id, PurchaseManager.ItemAll])
        }
        else{
            completed()
        }
    }
    
    func fetchAvailableProducts(ids: [String]) {
        debugPrint("Get products: \(ids)")
        let productsRequest = SKProductsRequest(productIdentifiers: Set(ids))
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func purchaseProduct(_ productId: String, completed: @escaping ((_ result: String?, _ error: String?) -> Void)) {
        if SKPaymentQueue.canMakePayments() {
            for product in products {
                if product.productIdentifier == productId {
                    debugPrint("PRODUCT TO PURCHASE: \(product.productIdentifier)")
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(payment)
                    purchasedCompleted = completed
                    return
                }
            }
            // If not return -> not found product
            completed(nil, "Product not found")
        } else {
            completed(nil, "Purchase disabled")
        }
    }
    
    func restorePurchase(completed: @escaping ((_ result: [String]?, _ error: String?) -> Void)){
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
            restoredCompleted = completed
        }
        else {
            completed(nil, "Purchase disabled")
        }
    }
    
    fileprivate func purchaseSuccess(productId: String) {
        PurchaseManager.savePurchasedItem(id: productId)
    }
    
}

extension PurchaseManager : SKProductsRequestDelegate {
    func productsRequest(_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            products.append(contentsOf: response.products)
        }
        if fetchCompleted != nil {
            fetchCompleted!()
            fetchCompleted = nil
        }
    }
}

extension PurchaseManager : SKPaymentTransactionObserver {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        var ids = [String]()
        for tran in queue.transactions {
            let id = tran.payment.productIdentifier
            ids.append(id)
            purchaseSuccess(productId: id)
        }
        if restoredCompleted != nil {
            restoredCompleted!(ids, nil)
            restoredCompleted = nil
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            debugPrint("Received Payment Transaction", transaction.transactionState.rawValue)
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                let purchasedId = transaction.payment.productIdentifier
                purchaseSuccess(productId: purchasedId)
                if purchasedCompleted != nil {
                    purchasedCompleted!(purchasedId, nil)
                    purchasedCompleted = nil
                }
                break
                
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                // show error log
                debugPrint(transaction.error.debugDescription)
                if purchasedCompleted != nil {
                    purchasedCompleted!(nil, transaction.error?.localizedDescription)
                    purchasedCompleted = nil
                }
                if restoredCompleted != nil {
                    restoredCompleted!(nil, transaction.error?.localizedDescription)
                    restoredCompleted = nil
                }
                break
                
            default:
                break
            }
        }
    }
}

extension PurchaseManager {
    static func savePurchasedAllItem(){
        PurchaseManager.savePurchasedItem(id: PurchaseManager.ItemAll)
    }
    
    static func checkPurchasedAllItem() -> Bool {
        return UserDefaults.standard.bool(forKey: PurchaseManager.ItemAll)
    }
    
    static func savePurchasedItem(id: String){
        UserDefaults.standard.set(true, forKey: id)
        UserDefaults.standard.synchronize()
    }
    
    static func checkPurchasedItem(id: String) -> Bool {
        let purchased = UserDefaults.standard.bool(forKey: id)
        if purchased {
            return true
        }
        if id != PurchaseManager.ItemAll {
            let all = PurchaseManager.checkPurchasedAllItem()
            if all {
                return true
            }
        }
        return false
    }
}
