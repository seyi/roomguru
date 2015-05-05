//
//  UIBaseTableView.swift
//  Roomguru
//
//  Created by Patryk Kaczmarek on 01/04/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Cartography

class UIBaseTableView: UIView {
    
    private(set) var tableView = UITableView()
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, tableViewStyle: .Plain)
    }
    
    init(frame: CGRect, tableViewStyle: UITableViewStyle) {
        tableView = UITableView(frame: frame, style: tableViewStyle)
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        tableView.hideSeparatorForEmptyCells()
        addSubview(tableView)
        defineConstraints()
    }
    
    func defineConstraints() {
        
        layout(tableView) { table in
            table.edges == table.superview!.edges; return
        }
    }
}
