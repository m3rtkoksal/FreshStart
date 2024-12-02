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
            let additionalDays = calculateAdditionalDays(for: transaction)
            updateSubscriptionDetailsInFirestore(userId: userId, additionalDays: additionalDays)
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
        if let userId = Auth.auth().currentUser?.uid {
            let additionalDays = calculateAdditionalDays(for: transaction)
            updateSubscriptionDetailsInFirestore(userId: userId, additionalDays: additionalDays)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func updateSubscriptionDetailsInFirestore(userId: String, additionalDays: Int) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                let currentEndDateTimestamp = data?["subscriptionEndDate"] as? Timestamp
                var currentEndDate = currentEndDateTimestamp?.dateValue() ?? Date()
                currentEndDate.addTimeInterval(TimeInterval(additionalDays * 86400))
                let dataToSave: [String: Any] = [
                    "subscriptionEndDate": currentEndDate,
                    "isPremiumUser": true,
                    "maxmaxMealCount": 5,
                    "maxPlanCount": 3 + (ProfileManager.shared.user.dietPlanCount ?? 0)
                ]
                
                db.collection("users").document(userId).setData(dataToSave, merge: true) { error in
                    if let error = error {
                        print("Error updating subscription details: \(error.localizedDescription)")
                    } else {
                        print("Successfully updated subscription details in Firestore.")
                    }
                }
            } else {
                print("Document does not exist.")
            }
        }
    }
    private func calculateAdditionalDays(for transaction: SKPaymentTransaction) -> Int {
        // Return days based on the product identifier
        switch transaction.payment.productIdentifier {
        case "week_one":
            return 7  // 7 days for the 1-week subscription
        case "week_two":
            return 14  // 14 days for the 2-week subscription
        case "month_one":
            return 30  // 30 days for the 1-month subscription
        case "month_six":
            return 180  // 180 days for the 6-month subscription
        case "year_one":
            return 365  // 365 days for the 1-year subscription
        default:
            return 0  // Default to 0 days if product identifier is not recognized
        }
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.offers.removeAll() // Ensure modification is done on the main thread
        }
        for product in response.products {
            DispatchQueue.main.async {
                self.offers.append(product) // Add valid products to the offerings array
                print("Product available: \(product.localizedTitle) - \(product.priceLocale.currencySymbol ?? "")\(product.price)")
            }
        }
        DispatchQueue.main.async {
            self.offers.sort { $0.price.doubleValue < $1.price.doubleValue } // Sorting on main thread
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
