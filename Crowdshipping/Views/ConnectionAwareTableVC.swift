//
//  ConnectionAwareTableVC.swift
//  Crowdshipping
//
//  Created by Ivan Kozlov on 25/06/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

class ConnectionAwareTableVC: UITableViewController {

    var reachability: Reachability!
    
    var label : UILabel?
    
    deinit {
        reachability.stopNotifier()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        label?.removeFromSuperview()
    }
    
    func showNoConnectionMessage() {
        if label != nil {
            return
        }
        
        let bounds = view.bounds
        label = UILabel(frame: CGRectMake(bounds.origin.x, self.topLayoutGuide.length/*0*/, bounds.size.width, 25))
        label!.text = "No active internet connection"
        label!.backgroundColor = UIColor.redColor()
        label!.textColor = UIColor.whiteColor()
        
        label!.alpha = 0
        label!.textAlignment = .Center
        
        if let window = UIApplication.sharedApplication().windows[0] as? UIWindow{
            window.addSubview(label!)
        }
        
//        label!.setTranslatesAutoresizingMaskIntoConstraints(false)
//        var topGuide = self.topLayoutGuide
//        let viewsDictionary = ["label": label!, "topGuide": topGuide]
//        
//        let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-0-[label(10@20)]",
//            options: NSLayoutFormatOptions(rawValue: 0),
//            metrics: nil,
//            views: viewsDictionary)
//        
//        let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("|-0-[label]-0-|",
//            options: NSLayoutFormatOptions(rawValue: 0),
//            metrics: nil,
//            views: viewsDictionary)
//        
//        let visualFormat = "H:[label(==\(bounds.size.width))]"
//        let constraintsW = NSLayoutConstraint.constraintsWithVisualFormat(visualFormat,
//            options: nil,
//            metrics: nil,
//            views: viewsDictionary)
//        
//        self.view.addConstraints(constraintsV + constraintsH + constraintsW)
        
        UIView.animateWithDuration(Config.animationDurationDefault,
            animations: { () -> Void in
                self.label!.alpha = 0.5
        })
    }
    
}
