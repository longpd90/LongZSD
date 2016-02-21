//
//  GenericTVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 13/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class HistoryTVC: UITableViewCell {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        // Do nothing
        //super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
