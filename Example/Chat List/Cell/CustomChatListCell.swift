//
//  CustomChatListCell.swift
//  Example
//
//  Created by Rahardyan Bisma on 19/10/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI

class CustomChatListCell: BaseChatListCell {
    lazy var lblRoomTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 12)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        return lbl
    }()
    
    lazy var lblLastMessage: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        return lbl
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        addSubview(lblRoomTitle)
        addSubview(lblLastMessage)
        
        NSLayoutConstraint.activate([
            // MARK: lblRoomTitle constraint
            lblRoomTitle.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            lblRoomTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
            lblRoomTitle.heightAnchor.constraint(equalToConstant: 15),
            lblRoomTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            lblRoomTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            
            // MARK: lblLastMessage constraint
            lblLastMessage.topAnchor.constraint(equalTo: lblRoomTitle.bottomAnchor, constant: 4),
            lblLastMessage.centerXAnchor.constraint(equalTo: centerXAnchor),
            lblLastMessage.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            lblLastMessage.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            lblLastMessage.heightAnchor.constraint(equalToConstant: 15)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
        lblRoomTitle.text = data?.name
        lblLastMessage.text = data?.lastComment?.message
    }
}
