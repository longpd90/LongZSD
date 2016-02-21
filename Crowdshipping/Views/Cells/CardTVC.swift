//
//  GenericTVC.swift
//  Crowdshipping
//
//  Created by Peter Prokop on 13/03/15.
//  Copyright (c) 2015 Whitescape. All rights reserved.
//

import UIKit

class CardTVC: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var isDefaultLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var logoIV: UIImageView!
    @IBOutlet weak var isDefaultImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
