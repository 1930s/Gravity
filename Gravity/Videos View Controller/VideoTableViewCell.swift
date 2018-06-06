//
//  VideoTableViewCell.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 6/6/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
