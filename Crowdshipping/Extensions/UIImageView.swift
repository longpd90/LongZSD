//
//  UIImageView.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 15/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

extension UIImageView {
    func setIconForCard(card: BraintreePaymentMethodModel) {
        var imageName = "UnknownCard"
        
        if let type = card.cardType {
            switch type.lowercaseString {
                case "mastercard": imageName = "MasterCard"
                case "american express": imageName = "Amex"
                case "visa": imageName = "Visa"
                default: break
            }
        }
        
        self.image = UIImage(named: imageName)
    }
}