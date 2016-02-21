//
//  PhoneCodeVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 25/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

protocol PhoneCodeDelegate {
    mutating func setPhoneCode(code: String)
}

class PhoneCodeVC: ConnectionAwareVC, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var delegate: PhoneCodeDelegate?
    
    var tableView: UITableView?
    var searchBar: UISearchBar?
    
    var allCodes: Array<AnyObject> = []
    var filteredCodes: Array<AnyObject> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select your country"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("closeTap"))
        
        let path = NSBundle.mainBundle().pathForResource("codes", ofType: "plist")!
        allCodes = NSArray(contentsOfFile: path)! as Array<AnyObject>
        filteredCodes = allCodes
        
        tableView = UITableView(frame: self.view.bounds)
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.keyboardDismissMode = .OnDrag
        self.view.addSubview(tableView!)
        
        tableView!.registerNib(UINib(nibName: "GenericTVC", bundle: nil), forCellReuseIdentifier: "generic cell")
        
        searchBar = UISearchBar(frame: CGRectMake(0, 0, self.view.bounds.size.width, 44))
        searchBar!.delegate = self;
        searchBar!.placeholder = "Search"
        tableView!.tableHeaderView = searchBar;
    }
    
    // MARK: UI callbacks
    
    func closeTap() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = filteredCodes[indexPath.row] as! Dictionary<String, String>
        self.delegate?.setPhoneCode(item["Code"]!)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCodes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "generic cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? GenericTVC
        
        if let item = filteredCodes[indexPath.row] as? Dictionary<String, String> {
            cell?.genericLabel.text = item["Country"]! + "(" + item["Code"]! + ")"
        } else {
            cell?.genericLabel.text = nil
        }
        
        return cell!
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count != 0 {
            let predicate = NSPredicate(format:"Country CONTAINS[cd] %@ OR Code CONTAINS[cd] %@", searchText, searchText)
            filteredCodes = allCodes.filter { predicate.evaluateWithObject($0) }
        } else {
            filteredCodes = allCodes
        }

        tableView!.reloadData()
    }
}
