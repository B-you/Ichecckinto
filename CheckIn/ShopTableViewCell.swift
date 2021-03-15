//
//  ShopTableViewCell.swift
//  CheckIn
//
//  Created by Bin on 2018/10/4.
//  Copyright © 2018 Bin. All rights reserved.
//

import UIKit
import Cosmos

class ShopTableViewCell: UITableViewCell {
    @IBOutlet weak var img_photo: UIImageView!
    @IBOutlet weak var txt_coupon_desc: UITextView!
    @IBOutlet weak var lbl_time: UILabel!
    @IBOutlet weak var lbl_favCount: UILabel!
    @IBOutlet weak var btn_setFav: UIButton!
    @IBOutlet weak var starView: CosmosView!
    
    @IBOutlet weak var distance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func onClick_favBtn(_ sender: Any) {
    }
   
    
}
