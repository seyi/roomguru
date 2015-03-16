//
//  SettingsItem.swift
//  Roomguru
//
//  Created by Patryk Kaczmarek on 16/03/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct SettingsItem {
    
    var title: String
    var type: aType
    var action: String
    
    init(title: String, type: aType, action: String) {
        self.title = title
        self.type = type
        self.action = action
    }
    
    enum aType {
        case switchType, buttonType
    }
    
    func performActionWithTarget(target: AnyObject?) {
        if target != nil {
            NSThread.detachNewThreadSelector(Selector(self.action), toTarget:target!, withObject: nil)
        }
    }
    
    func signature() -> (identifier: String, registeredClass: AnyClass) {
        switch(self.type) {
        case .switchType:
            return ("RGRTableViewSwitchCell", RGRTableViewSwitchCell.self)
        default:
            return ("RGRSettingsCellReuseIdentifier", UITableViewCell.self)
        }
    }
    
    func selectable() -> Bool {
        switch(self.type) {
        case .buttonType:
            return true;
        default:
            return false;
        }
    }
}
