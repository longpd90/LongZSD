//
//  InitialVC.swift
//  Crowdshipping
//
//  Created by Ivan Kozlov on 21/06/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

class InitialVC: ConnectionAwareVC {

    @IBOutlet weak var buttonContainer: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonContainer.layer.cornerRadius = Config.Visuals.cornerRadius
        buttonContainer.layer.masksToBounds = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .Plain, target: self, action: Selector("closeTap"))
    }
    
    func closeTap() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
}
