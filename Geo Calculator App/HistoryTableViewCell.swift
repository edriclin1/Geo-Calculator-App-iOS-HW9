//
//  HistoryTableViewCell.swift
//  Geo Calculator App
//
//  Created by user138338 on 5/30/18.
//  Copyright © 2018 GVSU. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var origPoint: UILabel!
    @IBOutlet weak var destPoint: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
