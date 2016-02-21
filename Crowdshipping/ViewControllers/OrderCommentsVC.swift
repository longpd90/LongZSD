//
//  OrderCommentsVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 22/05/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

protocol OrderCommentsVCDelegate{
    func orderCommentsVCDidFinish(controller:OrderCommentsVC, text:String)
}

class OrderCommentsVC: ConnectionAwareVC {
    @IBOutlet var textView: UITextView!
    
    var delegate: OrderCommentsVCDelegate?
    
    internal var isOrderCancellation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if !isOrderCancellation
        {
            let order = OrderManager.sharedInstance.currentOrder
            if let notes = order.notes {
                textView.text = notes
            }
        }
        else
        {
            self.title = "CANCELLATION REASON"
        }
        
        textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: UI callbacks
    
    @IBAction func doneTap()
    {
        
        
        if !isOrderCancellation
        {
            let order = OrderManager.sharedInstance.currentOrder
            order.notes = textView.text
        }
        else
        {
            
            if textView.text.isEmpty
            {
                    var alert = UIAlertView(title: "Provide a reason of cancellation", message: "", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Ok")
                    alert.show()
                    
                    return
            }
            
            if let weakDelegate = self.delegate
            {
                weakDelegate.orderCommentsVCDidFinish(self, text: textView.text)
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}
