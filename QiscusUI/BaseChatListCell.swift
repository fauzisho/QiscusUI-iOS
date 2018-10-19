//
//  BaseChatListCell.swift
//  QiscusUI
//
//  Created by Rahardyan Bisma on 19/10/18.
//

import Foundation
import UIKit
import QiscusCore

open class BaseChatListCell: UITableViewCell {
    public var data : RoomModel? {
        didSet {
            if data != nil {
                self.setupUI()
            }
        }
    }
    
    open func setupUI() {
        
    }
}
