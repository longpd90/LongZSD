//
//  CustomTabBarController.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 28/02/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    deinit {
        NotificationManager.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        NotificationManager.addObserver(self, selector: Selector("userDidLogout"), name: .UserDidLogout)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notifications
    
    func userDidLogout() {
        self.selectedIndex = 0
    }

    
    // MARK: UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        var shouldShowRegistrationScreen = false
        
        if viewController is UINavigationController {
            let rootVC = (viewController as! UINavigationController).viewControllers[0] as? HistoryVC
            
            if rootVC != nil && !AuthManager.sharedInstance.isLoggedIn() {
                shouldShowRegistrationScreen = true
            }
        }
        
        if viewController is AccountVC && !AuthManager.sharedInstance.isLoggedIn() {
            shouldShowRegistrationScreen = true
        }
        
        if shouldShowRegistrationScreen {
            self.performSegueWithIdentifier("register", sender: self)
            return false
        }
        
        return true
    }
}
