//
//  RGRTableViewSwitchCell.swift
//  Roomguru
//
//  Created by Patryk Kaczmarek on 16/03/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Cartography

class RGRTableViewSwitchCell: UITableViewCell {
    
    var aSwitch = UISwitch()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(aSwitch)
        defineConstraints()
    }
    
    private func defineConstraints() {
        
        layout(aSwitch) { (aSwitch) in
            
            let margin: CGFloat = 20
            
            aSwitch.centerY == aSwitch.superview!.centerY
            aSwitch.right == aSwitch.superview!.right - margin
        }
    }
}
