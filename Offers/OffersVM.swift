//
//  OffersVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 2.12.2024.
//

import Foundation
import StoreKit
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class OffersVM: BaseViewModel, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    @Published var offers: [SKProduct] = []
    @Published var showAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var purchaseCompleted: Bool = false
    @Published var additionalDays = 0
    @Published var subscriptionEndDate: Date = Date()
    
    private var productIdentifiers: Set<String> = ["week_one", "week_two", "month_one", "month_six", "year_one"]
    private var productRequest: SKProductsRequest?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func fetchProducts() {
            productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            productRequest?.delegate = self
            productRequest?.start()
        }
    
    func purchaseProduct(product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else {
            showAlert = true
            errorMessage = "In-app purchases are not allowed on this device."
            return
        }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchase(transaction: transaction)
            case .failed:
                handleFailed(transaction: transaction)
            case .restored:
                handleRestored(transaction: transaction)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        }
    }
    private func handlePurchase(transaction: SKPaymentTransaction) {
        // Grant access to the purchased content
        if let userId = Auth.auth().currentUser?.uid {
            updateSubscriptionDetailsInFirestore(userId: userId)
        }
        purchaseCompleted = true
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleFailed(transaction: SKPaymentTransaction) {
        if let error = transaction.error as NSError? {
            errorMessage = error.localizedDescription
        } else {
            errorMessage = "Unknown error occurred."
        }
        showAlert = true
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleRestored(transaction: SKPaymentTransaction) {
        // Restore purchases
        if let userId = Auth.auth().currentUser?.uid {
            updateSubscriptionDetailsInFirestore(userId: userId)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    private func updateSubscriptionDetailsInFirestore(userId: String) {
        let db = Firestore.firestore()
        let subscriptionEndDate = Calendar.current.date(byAdding: .day, value: additionalDays, to: Date()) ?? Date()
        
        let dataToSave: [String: Any] = [
            "subscriptionEndDate": subscriptionEndDate,
            "isPremiumUser": true
        ]
        
        db.collection("users").document(userId).setData(dataToSave, merge: true) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
            } else {
                print("Successfully updated subscription details in Firestore.")
            }
        }
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Clear any previous product list
        offers.removeAll()
        
        // Iterate through the received products
        for product in response.products {
            offers.append(product) // Add valid products to the offerings array
            print("Product available: \(product.localizedTitle) - \(product.priceLocale.currencySymbol ?? "")\(product.price)")
        }
        
        // Sort the products by price (ascending order)
        offers.sort { $0.price.doubleValue < $1.price.doubleValue }
        
        // Check for invalid product identifiers
        if !response.invalidProductIdentifiers.isEmpty {
            print("Invalid product identifiers found: \(response.invalidProductIdentifiers)")
        }
        
        // Handle empty response scenario
        if response.products.isEmpty {
            errorMessage = "No products available."
            showAlert = true
        }
    }
}

extension SKProduct {
    var localizedPriceString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? "\(self.price)"
    }
}
