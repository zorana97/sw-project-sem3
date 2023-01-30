//
//  RouteCell.swift
//  sw-proj
//
//  Created by Zorana Jevtic on 29.01.23.
//

import Foundation
import UIKit

class RouteCell: UITableViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
