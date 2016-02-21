//
//  MenuButton.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 17/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class MenuButton: UIButton, UIActionSheetDelegate {
    weak var delegate : UIViewController?
    weak var presentingViewController: UIViewController?
    
    @IBOutlet var menuView: UIView?
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var getSupportButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.customInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.customInit()
    }
    
    func customInit() {
        self.addTarget(self, action: Selector("menuTap"), forControlEvents: .TouchUpInside)
        self.setImage(UIImage(named: "BurgerMenu"), forState: .Normal)
        self.contentHorizontalAlignment = .Left
    }
    
    @IBAction func menuTap() {
        
        let sideMenu = (UIApplication.sharedApplication().delegate as! AppDelegate).sideMenu
        sideMenu?.toggleDrawerSide(.Left, animated: true, completion: { (bool finish) -> Void in
        
        })

    }
    
    func dismiss() {
        self.enabled = true
        
        UIView.animateWithDuration(Config.animationDurationDefault, animations: { () -> Void in
                self.menuView!.frame = CGRectOffset(self.menuView!.frame, -self.menuView!.frame.size.width, 0)
        }) { (completed) -> Void in
            self.menuView?.removeFromSuperview()
            self.menuView = nil
        }
    }
    
    // MARK: UI callbacks
    
    @IBAction func closeTap() {
        self.dismiss()
    }
    
    @IBAction func historyTap() {
        delegate!.performSegueWithIdentifier("show history", sender: self)
        self.dismiss()
    }
    
    @IBAction func accountTap() {
        delegate!.performSegueWithIdentifier("my account", sender: self)
        self.dismiss()
    }
    
    @IBAction func registerTap() {
        delegate!.performSegueWithIdentifier("register", sender: self)
        self.dismiss()
    }
    
    @IBAction func getSupportTap() {
        Intercom.presentMessageComposer()
        self.dismiss()
    }
}
