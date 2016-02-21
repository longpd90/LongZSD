//
//  ConnectionAwareVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 30/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class ConnectionAwareVC: GAITrackedViewController {
    var reachability: Reachability!
    
    var label : UILabel?
    var isConnected: Bool = true
    
    deinit {
        reachability.stopNotifier()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = NSStringFromClass(self.classForCoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
        }

        weak var wSelf = self
        
        reachability.whenReachable = { reachability in
            Utils.log("whenReachable")
            
            if let sSelf = wSelf {
                dispatch_async(dispatch_get_main_queue()) {
                    if sSelf.label != nil {
                        UIView.animateWithDuration(Config.animationDurationDefault,
                            animations: { () -> Void in
                                sSelf.isConnected = true
                                sSelf.label!.alpha = 0
                                sSelf.label = nil
                        })
                    }
                }
            }
        }
        
        reachability.whenUnreachable = { reachability in
            Utils.log("whenUnreachable")
            
            if let sSelf = wSelf {
                dispatch_async(dispatch_get_main_queue()) {
                    sSelf.isConnected = false
                    sSelf.showNoConnectionMessage()
                }
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !reachability.isReachable() {
            showNoConnectionMessage()
        }
    }
    
    func showNoConnectionMessage() {
        if label != nil {
            return
        }
        
        let bounds = view.bounds
        label = UILabel(frame: CGRectMake(bounds.origin.x,/* self.topLayoutGuide.length*/0, bounds.size.width, 25))
        label!.text = "No active internet connection"
        label!.backgroundColor = UIColor.redColor()
        label!.textColor = UIColor.whiteColor()
        
        label!.alpha = 0
        label!.textAlignment = .Center
        
        view.addSubview(label!)

        label!.translatesAutoresizingMaskIntoConstraints = false
        var topGuide = self.topLayoutGuide
        let viewsDictionary = ["label": label!, "topGuide": topGuide]

        let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-0-[label(10@20)]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary as! [String : AnyObject])
        
        let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("|-0-[label]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary as! [String : AnyObject])
        
        let visualFormat = "H:[label(==\(bounds.size.width))]"
        let constraintsW = NSLayoutConstraint.constraintsWithVisualFormat(visualFormat,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary as! [String : AnyObject])
        
        self.view.addConstraints(constraintsV + constraintsH + constraintsW)
        
        UIView.animateWithDuration(Config.animationDurationDefault,
            animations: { () -> Void in
                self.label!.alpha = 0.5
        })
    }
}
