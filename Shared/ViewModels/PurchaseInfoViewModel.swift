//
//  PurchaseInfoViewModel.swift
//  PurchaseInfoViewModel
//
//  Created by Russell Archer on 21/07/2021.
//

import StoreKit
import SwiftUI

/// ViewModel for `PurchaseInfoView`. Enables gathering of purchase or subscription information.
struct PurchaseInfoViewModel {
    
    @ObservedObject var storeHelper: StoreHelper
    var productId: ProductId
    
    /// Provides text information on the purchase of a non-consumable product or auto-renewing subscription.
    /// - Parameter productId: The `ProductId` of the product or subscription.
    /// - Returns: Returns text information on the purchase of a non-consumable product or auto-renewing subscription.
    @MainActor func info(for productId: ProductId) async -> String {
        
        guard let product = storeHelper.product(from: productId) else { return "No purchase info available." }
        guard product.type != .consumable, product.type != .nonRenewable else { return "" }
        
        // Get detail purchase/subscription info on the product
        guard let info = await storeHelper.purchaseInfo(for: product) else { return "" }
        
        var text = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        if info.product.type == .nonConsumable {
            guard let transaction = info.latestVerifiedTransaction else { return "" }
            
            let today = Date()
            
//            text = "Today is \(dateFormatter.string(from: Date())) \n Purchased on \(dateFormatter.string(from: transaction.purchaseDate))"
            
          //  text = "Purchased on \(dateFormatter.string(from: transaction.purchaseDate))"
            
//            text += DateInterval(start: Date(), end: transaction.purchaseDate)
//            let between = Date().timeIntervalSinceReferenceDate - transaction.purchaseDate.timeIntervalSinceReferenceDate
            
            let trailStart = transaction.purchaseDate
            let userCalendar = Calendar.current
            let trailEndDate = userCalendar.date(byAdding: .day, value: 14, to: trailStart)
            let trailEndString =  dateFormatter.string(from: trailEndDate!)
            
            
            let remainingDays = userCalendar.dateComponents([.day], from: Date(),
                                                            to: trailEndDate!)
            
            if productId == "com.shenxiaochun.nonconsumable.trail" {
        
                if today > trailEndDate! {
                    text += ("\n 试用已过期 \n 为了测试，试用时间设置只设置了1分钟")
                }
                else {
                    text += ("\n Product: Name Free Trail ")
                    text += ("\n Days Remaining: \(remainingDays.day!) days")
                    text += ("\n Expires On: \(trailEndString)")
                    
                }
             //   text += ("\n expire after 14-day trail \(trailEndString)")
            }
            
            if transaction.revocationDate != nil {
                text += " App Store revoked the purchase on \(dateFormatter.string(from: transaction.revocationDate!))."
            }
            

        }
        
        return text
    }
}
