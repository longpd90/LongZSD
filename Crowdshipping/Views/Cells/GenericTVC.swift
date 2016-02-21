//
//  GenericTVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 13/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class GenericTVC: UITableViewCell {

    @IBOutlet weak var genericLabel: UILabel!
    
    @IBOutlet weak var leftPadding: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
