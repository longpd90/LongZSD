//
//  OrderSizeVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 17/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class OrderSizeVC: ConnectionAwareVC {
    @IBOutlet var buttons: Array<UIButton>! = []
    @IBOutlet var priceContainers: Array<UIView>! = []
    
    @IBOutlet var priceLabels: Array<UILabel>! = []
    @IBOutlet var priceCentsLabels: Array<UILabel>! = []
    
    @IBOutlet var underlineLabels: Array<UILabel>! = []
    
    var allPricesDict: [OrderModel.OrderSize: Double?] = Dictionary<OrderModel.OrderSize, Double?>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in priceContainers {
            view.layer.cornerRadius = 6
            view.layer.borderColor = UIColor.whiteColor().CGColor
            view.layer.borderWidth = 1
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let prices = OrderManager.sharedInstance.currentOrder.pricesData!["prices"] as? Array< Dictionary<String, AnyObject>> {
            for (index, value) in prices.enumerate() {
                Utils.log("Item \(index + 1): \(value)")
                
                if index >= buttons.count {
                    break
                }
                
                var label: UILabel?
                var centsLabel: UILabel?
                
                if let price = value["price"] as? String {
                    let priceDouble = price.toNumber()!.doubleValue
                    
                    if let size = value["size"] as? String {
                        switch size {
                        case "SMALL":
                            allPricesDict[OrderModel.OrderSize.Small] = priceDouble
                            label = priceLabels[0]
                            centsLabel = priceCentsLabels[0]
                        case "MEDIUM":
                            allPricesDict[OrderModel.OrderSize.Medium] = priceDouble
                            label = priceLabels[1]
                            centsLabel = priceCentsLabels[1]
                        case "LARGE":
                            allPricesDict[OrderModel.OrderSize.Large] = priceDouble
                            label = priceLabels[2]
                            centsLabel = priceCentsLabels[2]
                        default:
                            break
                        }
                        
                        if label == nil {
                            continue
                        }
                        
                        let priceArray = price.componentsSeparatedByString(".")
                        
                        
                        var enot: String = priceArray.first! as String
                        enot.characters.count
                        
                        if (priceArray.first! as String).characters.count > 2
                        {
                            label!.text = Config.currency + priceArray.first!
                            centsLabel!.text = "-"/*priceArray.last!.substringToIndex(advance(priceArray.last!.startIndex, 1))*/
                        }
                        else
                        {
                            label!.text = Config.currency + priceArray.first!
                            centsLabel!.text = priceArray.last!
                        }
                    }
                }
            }
        }
        
        for label in underlineLabels {
            let attributedText = NSMutableAttributedString(attributedString: label.attributedText!)

            attributedText.addAttribute(NSUnderlineColorAttributeName,
                value: Config.Visuals.color_grayUnderline,
                range: NSMakeRange(0, attributedText.length))
            label.attributedText = attributedText
        }
    }
    
    private func proceed(size: OrderModel.OrderSize) {
        OrderManager.sharedInstance.currentOrder.orderSize = size
        if let price = allPricesDict[size] {
            OrderManager.sharedInstance.currentOrder.price = price
        }
        
        self.performSegueWithIdentifier("set order contacts", sender: self)
    }
    
    @IBAction func smallSizeTap() {
        proceed(.Small)
    }
    
    @IBAction func mediumSizeTap() {
        proceed(.Medium)
    }
    
    @IBAction func largeSizeTap() {
        proceed(.Large)
    }
}