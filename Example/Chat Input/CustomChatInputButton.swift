//
//  CustomChatInputButton.swift
//  Example
//
//  Created by Rahardyan Bisma on 15/10/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation
import QiscusUI

class CustomChatInputButton: UIChatInput {
    @IBOutlet weak var constraintInputButtonHeight: NSLayoutConstraint!
    private var isAppear: Bool = false
    
    override func commonInit(nib: UINib) {
        let nib = UINib(nibName: "CustomChatInputButton", bundle: Bundle.main)
        super.commonInit(nib: nib)
    }
    
    @IBAction func clickSend(_ sender: Any) {
        
    }
    
    @IBAction func clickAttachment(_ sender: Any) {
        self.constraintInputButtonHeight.constant = self.isAppear ? 0 : 172
        self.setHeight(self.isAppear ? 50 : 222)
        
        isAppear = !isAppear
        
    }
}
