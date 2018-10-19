//
//  CustomChatListCell2.swift
//  Example
//
//  Created by Rahardyan Bisma on 19/10/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI
import AlamofireImage

class CustomChatListCell: BaseChatListCell {

    @IBOutlet weak var lblLastMessage: UILabel!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var ivRoomAvatar: UIImageView!
    
    override func setupUI() {
        super.setupUI()
        lblLastMessage.text = data?.lastComment?.message
        lblRoomName.text = data?.name
        
        if let avatar = data?.avatarUrl {
            self.ivRoomAvatar.af_setImage(withURL: avatar)
        }
    }
}
