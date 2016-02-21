//
//  ManageCardsVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 11/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class ManageCardsVC: ConnectionAwareVC, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate  {
    @IBOutlet var tableView: UITableView!
    
    var cards: [BraintreePaymentMethodModel] = AuthManager.sharedInstance.getAllPaymentMethods()
    var currentCard: BraintreePaymentMethodModel?
    
    var canDelete: Bool = true
    
    
    var isRefreshing: Bool = false
    
    override func viewDidLoad() {
        
        let menuButton = MenuButton(frame: CGRectMake(0, 0, 60, 30))
        menuButton.presentingViewController = self.navigationController
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refresh()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let footer = self.tableView.tableFooterView!
        var frame = footer.frame
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 55)
        footer.frame = frame
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "edit card":
            ((segue.destinationViewController as! UINavigationController).viewControllers[0] as! BindCardVC).paymentMethodToEdit = currentCard
        default:
            break
        }
    }
    
    func refresh() {
        cards = AuthManager.sharedInstance.getAllPaymentMethods()
        self.tableView.reloadData()
    }
    
    // MARK: UI callbacks
    
    @IBAction func addCardTap() {
        self.performSegueWithIdentifier("add card", sender: self)
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "card cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! CardTVC
        
        let method = cards[indexPath.row]
        
        // Set data
        cell.numberLabel.text = "\(method.maskedNumber!)"
        
        if method.expirationMonth != nil &&
            method.expirationYear != nil
        {
            cell.expirationLabel.hidden = !method.checkIfExpired()
        }
        
        cell.logoIV.setIconForCard(method)
        
        if let isDefault = method.isDefault {
            cell.isDefaultImage.hidden = !isDefault.boolValue
//            if isDefault.boolValue {
//                cell.isDefaultImage
//                cell.isDefaultLabel.text = "Default"
//            }
        }
        
        return cell
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if isRefreshing {return}
        
        let method = cards[indexPath.row]
        canDelete = true
        if let isDefault = method.isDefault
        {
            if isDefault.boolValue {
                canDelete = false
            }
        }
        if cards.count < 2
        {
            canDelete = false
        }
        
        var actionSheet = UIActionSheet()
        
        if canDelete
        {
            actionSheet = UIActionSheet(title: nil,
                delegate: self,
                cancelButtonTitle: "Cancel",
                destructiveButtonTitle: "Delete card",
                otherButtonTitles: "Make primary", "Сhange the date of expiry")
        }
        else
        {
            actionSheet = UIActionSheet(title: nil,
                delegate: self,
                cancelButtonTitle: "Cancel",
                destructiveButtonTitle: nil,
                otherButtonTitles: "Сhange the date of expiry")
        }
        
        currentCard = cards[indexPath.row]
        
        actionSheet.showInView(self.view)
        
    }
    
    // MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        //Utils.log(buttonIndex)
        
        
        var index = buttonIndex
        
        if !canDelete
        {
            
            if index == 1
            {
                self.performSegueWithIdentifier("edit card", sender: self)
            }
            
            return
            
//            index++
        }
        
        switch index {
        case 0: // Delete
            self.showWaitOverlay()
            let card = currentCard!
            isRefreshing = true
            APIManager.sharedInstance.deleteCard(card.token!,
                successCallback: { (arg) -> Void in
                    self.removeAllOverlays()
                    self.isRefreshing = false
                    AuthManager.sharedInstance.removePaymentMethod(card)
                    self.refresh()
            }, failedCallback: { (arg) -> Void in
                self.removeAllOverlays()
                self.isRefreshing = false
                Utils.showErrorForJSON(arg)
            })
            
        case 2: // Make default
            self.showWaitOverlay()
            let card = currentCard!
            isRefreshing = true
            APIManager.sharedInstance.makeCardDefault(card.token!,
                successCallback: { (arg) -> Void in
                    self.removeAllOverlays()
                    self.isRefreshing = false
                    AuthManager.sharedInstance.setPaymentMethodDefault(card)
                    self.refresh()
            }, failedCallback: { (arg) -> Void in
                self.removeAllOverlays()
                self.isRefreshing = false
                Utils.showErrorForJSON(arg)
            })
            
        case 3: // Edit
            self.performSegueWithIdentifier("edit card", sender: self)
            
        default: // Close
            break
        }
        
        currentCard = nil
    }
}
