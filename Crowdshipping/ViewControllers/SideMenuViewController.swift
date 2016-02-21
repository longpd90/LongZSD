//
//  SideMenuViewController.swift
//  Crowdshipping
//
//  Created by Ivan Kozlov on 21/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var registrationHeader: UIView!
    @IBOutlet weak var menuTableView : UITableView!
     var drawerController : MMDrawerController!
    
    var menuItems = Array<String>()
    
    enum MenuItems : String {
        case
        MyOrder = "MY ORDER",
        OrderHistory = "ORDER HISTORY",
        PaymentDetails = "PAYMENT DETAILS",
        BonusProgram = "BONUS PROGRAM",
        Settings = "SETTINGS"
    }
    
    internal func reloadHeader()
    {
        if OrderManager.sharedInstance.currentOrder.pk != nil
        {
            self.menuItems = ["MY ORDER", "ORDER HISTORY", "PAYMENT DETAILS", "SETTINGS"]
        }
        else
        {
            self.menuItems = ["CREATE ORDER", "ORDER HISTORY", "PAYMENT DETAILS", "SETTINGS"]
        }
        self.viewWillAppear(true)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if AuthManager.sharedInstance.isLoggedIn()
        {
            self.menuTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 42))
        }
        else
        {
            self.menuTableView.tableHeaderView = self.registrationHeader
        }
        
        self.menuTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.reloadHeader()
        
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        self.menuTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        
        menuTableView.registerNib(UINib(nibName: "GenericTVC", bundle: nil), forCellReuseIdentifier: "generic cell")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = "generic cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! GenericTVC
        
        cell.leftPadding.constant = 22;
        if (!AuthManager.sharedInstance.isLoggedIn() && 1...3 ~= indexPath.row)
        {
            cell.genericLabel.textColor = UIColor.darkGrayColor()
        }
        else
        {
            cell.genericLabel.textColor = UIColor.whiteColor()
        }
        cell.genericLabel.font = UIFont.systemFontOfSize(18.0)
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        cell.genericLabel.text = self.menuItems[indexPath.row]
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !(!AuthManager.sharedInstance.isLoggedIn() && 1...3 ~= indexPath.row)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if (!AuthManager.sharedInstance.isLoggedIn() && 1...3 ~= indexPath.row) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        let mainController = (UIApplication.sharedApplication().delegate as! AppDelegate).mainMapNavigation as UINavigationController
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        switch indexPath.row{
            case 0:
                self.drawerController.centerViewController = mainController
//                if let orderID = OrderManager.sharedInstance.currentOrder.pk?
//                {
//                    break
//                }
//                (self.drawerController.centerViewController as UINavigationController).popToRootViewControllerAnimated(true)
            case 1:
                let history  = storyboard.instantiateViewControllerWithIdentifier("HistoryVC") as! HistoryVC
                self.drawerController.centerViewController = UINavigationController(rootViewController: history)
            case 2:
                let cards  = storyboard.instantiateViewControllerWithIdentifier("ManageCardsVC") as! ManageCardsVC
                self.drawerController.centerViewController = UINavigationController(rootViewController: cards)
            case 3:
                let account  = storyboard.instantiateViewControllerWithIdentifier("AccountVC") as! AccountVC
                self.drawerController.centerViewController = UINavigationController(rootViewController: account)
        default:
            break
        }
        
        self.drawerController.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    @IBAction func registerButtonClicked()
    {
        let mainController = (self.drawerController.centerViewController as! UINavigationController).viewControllers[0] as UIViewController
        mainController.performSegueWithIdentifier("register", sender: self)
        self.drawerController.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
}
