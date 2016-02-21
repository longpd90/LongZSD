//
//  HistoryVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 25/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import Foundation

class HistoryVC: ConnectionAwareVC, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var orders : Array<OrderModel> = []
    
    let dateFormatter = NSDateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuButton = MenuButton(frame: CGRectMake(0, 0, 60, 30))
        menuButton.presentingViewController = self.navigationController
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        dateFormatter.dateFormat = "yy.MM.dd"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        update()
    }
    
    func update() {
        self.showWaitOverlay()
        
        APIManager.sharedInstance.getOrderList(1,
            successCallback: { (json) -> Void in
                self.removeAllOverlays()
                
                if let newOrders = json!["results"] as? Array< Dictionary<String, AnyObject> > {
                    
                    self.orders = []
                    
                    for orderDict: Dictionary<String, AnyObject> in newOrders {
                        if let order = Mapper<OrderModel>().map(orderDict) {
                            self.orders.append(order)
                        }
                    }
                    
                    self.tableView.reloadData()
                }
                
            }) { (json) -> Void in
                self.removeAllOverlays()
                
                Utils.showErrorForJSON(json)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        switch segue.identifier! {
            case "show order details":
                let covc = (segue.destinationViewController as! CurrentOrderVC)
                covc.order = sender as? OrderModel
                covc.didCameFromHistory = true
            default:
                break
        }
    }

    // MARK: UI callbacks
    
    @IBAction func closeTap() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let identifier = "history cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! HistoryTVC
        let order = orders[indexPath.row]
        
        // Clear
        cell.dateLabel.text = nil
        cell.statusLabel.text = nil
        
        // Set data
        if order.pk != nil && order.state != nil {
            
            
            var stateString = "FAILURE"
            
            switch order.state! {
                case .New:
                    stateString = "ASSIGNING"
                case .Cancelled:
                    stateString = "CANCELLED"
                case .Accepted:
                    stateString = "ASSIGNED"
                case .Delivery:
                    stateString = "IN PROGRESS"
                case .Completed:
                    stateString = "DELIVERED"
                case .CourierCancelled:
                    stateString = "COURIER CANCELLED"
                case .AdminCancelled:
                    stateString = "FAILURE"
                case .Returned:
                    stateString = "RETURNED"
                case .Returning:
                    stateString = "RETURNING"
                case .InOffice:
                    stateString = "IN OFFICE"
            }
            
            cell.statusLabel.text = "Order #\(order.pk!) \(stateString.capitalizedString)"
            
            switch order.state! {
                case .Completed:
                    cell.statusLabel.textColor = Config.Visuals.color_green
                case .Cancelled, .CourierCancelled, .AdminCancelled:
                    cell.statusLabel.textColor = Config.Visuals.color_red
                default: 
                    cell.statusLabel.textColor = Config.Visuals.color_textDefault
            }
        }
        
        if let created = order.created {
            cell.dateLabel.text = dateFormatter.stringFromDate(created)
        }

        var fromText = ""
        if let fromAddress = order.pickupAddress {
            fromText += fromAddress
        }
        if let fromDetails = order.pickupAddressDetail {
            fromText += "\n" + fromDetails
        }
        cell.fromLabel.text = fromText
        
        var toText = ""
        if let toAddress = order.destinationAddress {
            toText += toAddress
        }
        if let toDetails = order.destinationAddressDetail {
            toText += "\n" + toDetails
        }
        cell.toLabel.text = toText
        
        
        cell.setNeedsLayout();
        cell.layoutIfNeeded();
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let order = orders[indexPath.row]
        self.performSegueWithIdentifier("show order details", sender: order)
    }

}