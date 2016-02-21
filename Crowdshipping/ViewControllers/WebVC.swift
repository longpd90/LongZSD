//
//  WebVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 18/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class WebVC: ConnectionAwareVC {

    var URL: NSURL?
    var webView: UIWebView?
    
    class func presentOnController(controller: UIViewController, URLString: String) {
        
        let rc = WebVC(URLString: URLString)
        let nc = UINavigationController(rootViewController: rc)
    }
    
    convenience init(URLString: String) {
        self.init()
        self.URL = NSURL(string: URLString)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: Selector("closeTap"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView = UIWebView(frame: self.view.bounds)
        self.view.addSubview(webView!)
        webView?.loadRequest(NSURLRequest(URL: URL!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UI callbacks

    func closeTap() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
}
