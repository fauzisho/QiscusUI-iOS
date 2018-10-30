//
//  CustomChatInputButton.swift
//  Example
//
//  Created by Rahardyan Bisma on 15/10/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation
import QiscusUI
import QiscusCore

class CustomChatInputButton: UIChatInput {
    
    @IBOutlet weak var buttonAnswer: UIButton!
    private var isAppear: Bool = false
    let type : String = "answer"
    
    override func commonInit(nib: UINib) {
        let nib = UINib(nibName: "CustomChatInputButton", bundle: Bundle.main)
        super.commonInit(nib: nib)
    }
    
    @IBAction func clickSend(_ sender: Any) {
        
    }
    
    @IBAction func clickAttachment(_ sender: Any) {
        self.setHeight(self.isAppear ? 50 : 222)
        isAppear = !isAppear
        
        if isAppear {
            self.buttonAnswer.setTitle("Close", for: .normal)
        } else {
            self.buttonAnswer.setTitle("Answer", for: .normal)
        }
    }
    
    @IBAction func clickAnswerA(_ sender: Any) {
        let comment = CommentModel()
        comment.type = type
        comment.message = "AnswerA"
        self.send(message: comment)
    }
    
    @IBAction func clickAnswerB(_ sender: Any) {
        let comment = CommentModel()
        comment.type = type
        comment.message = "AnswerB"
        self.send(message: comment)
    }
    
    @IBAction func clickAnswerC(_ sender: Any) {
        let comment = CommentModel()
        comment.type = type
        comment.message = "AnswerC"
        self.send(message: comment)
    }
    
    @IBAction func clickAnswerD(_ sender: Any) {
        let comment = CommentModel()
        comment.type = type
        comment.message = "AnswerD"
        self.send(message: comment)
    }
    
}
