//
//  AccountVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 17/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class AccountVC: ConnectionAwareVC, UIAlertViewDelegate {
    @IBOutlet var appVersionLabel : UILabel!
    
    @IBOutlet weak var logoutButton: RoundedCornerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuButton = MenuButton(frame: CGRectMake(0, 0, 60, 30))
        menuButton.presentingViewController = self.navigationController
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        let dict = NSBundle.mainBundle().infoDictionary!
        let build = dict[kCFBundleVersionKey as String ] as? String
        let version = dict["CFBundleShortVersionString"] as? String
        appVersionLabel.text = "App version: \(version) (\(build))"
        
//        logoutButton.layer.borderColor = UIColor.redColor().CGColor
//        logoutButton.layer.borderWidth = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: UI callbacks
    
    @IBAction func changePhoneTap()
    {
        var changePhone = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RestorePasswordVC") as! RestorePasswordVC
        changePhone.isChangingPhone = true
        
        self.navigationController?.pushViewController(changePhone, animated: true)
    }
    
    @IBAction func logoutTap() {
        let alertView = UIAlertView(title: "Are you sure?", message: "", delegate: self, cancelButtonTitle: "No")
        alertView.addButtonWithTitle("Yes")
        alertView.show()
    }
    
    @IBAction func changeCreditCardTap() {
        self.performSegueWithIdentifier("manage cards", sender: self)
    }
    
    // MARK: UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if (buttonIndex == 1) {
            APIManager.sharedInstance.logout({ (arg) -> Void in
            }, failedCallback: { (arg) -> Void in
                // Fail silently
            })
            
            OrderManager.sharedInstance.deleteSavedOrder()
            
            NotificationManager.post(.UserDidLogout)
            
            AuthManager.sharedInstance.logout()
            
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            self.performSegueWithIdentifier("register", sender: self)
            
            delegate.resetNavigationStack()
            let mainController = delegate.mainMapNavigation.viewControllers[0] as? MapVC
            mainController?.shouldResetMap = true
            delegate.leftMenu.reloadHeader()
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}