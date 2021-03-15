//
//  userShopLIstTableViewCell.swift
//  CheckIn
//
//  Created by Aroliant Developer on 2/25/19.
//  Copyright © 2019 Bin. All rights reserved.
//

import UIKit

class userShopLIstTableViewCell: UITableViewCell {

    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var shopListView: UIView!
    @IBOutlet weak var shopDetails: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
