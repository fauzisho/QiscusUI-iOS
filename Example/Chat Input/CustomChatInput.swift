//
//  CustomChatInput.swift
//  Example
//
//  Created by Qiscus on 04/09/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI
import QiscusCore

protocol CustomChatInputDelegate {
    func sendAttachment()
}

class CustomChatInput: UIChatInput {
    
    @IBOutlet weak var tvInput: UITextView!
    var delegate : CustomChatInputDelegate? = nil
    
    override func commonInit(nib: UINib) {
        let nib = UINib(nibName: "CustomChatInput", bundle: Bundle.main)
        super.commonInit(nib: nib)
        self.tvInput.delegate = self
        self.setInputViewMaxLines(with: 10, basedOn: tvInput)
    }
    
    @IBAction func clickSend(_ sender: Any) {
        guard let text = self.tvInput.text else {return}
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let comment = CommentModel()
            comment.type = "text"
            comment.message = text
            self.send(message: comment)
        }
        self.tvInput.text = ""
    }
    
    @IBAction func clickAttachment(_ sender: Any) {
        self.delegate?.sendAttachment()
    }
    
    private func calculateHeight() -> CGRect {
        var tvInputFrame = tvInput.frame
        tvInputFrame.size.height = tvInput.contentSize.height + 2
        
        var inputContainerFrame = self.frame
        inputContainerFrame.size.height = tvInput.contentSize.height + 10
        return inputContainerFrame
    }
    
    /**
     * for advance size customization
     * UIChatInput are also implement UITextViewDelegate if you are using UITextView as your input view no need to conforming UITextViewDelegate on this custom class
     * if you want custom behavior or need another UITextViewDelegate function simply just write the UITextViewDelegate function or override the function if its also implemented in UIChatInput like the (textViewDidEndEditing, textViewDidBeginEditing, textViewDidChange)
     **/
//    override func textViewDidEndEditing(_ textView: UITextView) {
//        self.typing(false)
//    }
//
//    override func textViewDidBeginEditing(_ textView: UITextView) {
//        self.typing(true)
//    }
//
//
//    override func textViewDidChange(_ textView: UITextView) {
//        let fontHeight = textView.font?.lineHeight
//        let line = textView.contentSize.height / fontHeight!
//
//        if line < 4 {
//            self.frame = self.calculateHeight()
//            self.layoutIfNeeded()
//        }
//    }
}
