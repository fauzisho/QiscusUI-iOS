//
//  UIChatInput.swift
//  QiscusUI
//
//  Created by Qiscus on 04/09/18.
//

import UIKit
import QiscusCore

// Blueprint public method
protocol UIChatInputAction {
    func send(message : CommentModel)
    func typing(_ value: Bool)
}

// internal function
protocol UIChatInputDelegate {
    func send(message : CommentModel)
    func typing(_ value: Bool)
}

open class UIChatInput: UIView {

    @IBOutlet weak var tvInput: UITextView?
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var btnSend: UIButton!

    var delegate : UIChatInputDelegate? {
        set {
            self._delegate = newValue
        }
        get {
            return self._delegate
        }
    }
    private var _delegate       : UIChatInputDelegate? = nil
    private var inputToBeCalculated: UITextView?
    private var inputViewMaxLines: CGFloat = 4
    var contentsView            : UIView!
    var onHeightChange: (CGFloat) -> Void = { _ in }
    open override var frame: CGRect {
        didSet {
            onHeightChange(frame.height)
        }
    }

    // If someone is to initialize a UIChatInput in code
    public override init(frame: CGRect) {
        // For use in code
        super.init(frame: frame)
        let nib = UINib(nibName: "UIChatInput", bundle: QiscusUI.bundle)
        commonInit(nib: nib)
    }
    
    // If someone is to initalize a UIChatInput in Storyboard setting the Custom Class of a UIView
    public required init?(coder aDecoder: NSCoder) {
        // For use in Interface Builder
        super.init(coder: aDecoder)
        let nib = UINib(nibName: "UIChatInput", bundle: QiscusUI.bundle)
        commonInit(nib: nib)
    }
    
    open func commonInit(nib: UINib) {
        self.contentsView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        // 2. Adding the 'contentView' to self (self represents the instance of a WeatherView which is a 'UIView').
        addSubview(contentsView)
        
        // 3. Setting this false allows us to set our constraints on the contentView programtically
        contentsView.translatesAutoresizingMaskIntoConstraints = false

        // 4. Setting the constraints programatically
        contentsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentsView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentsView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        self.autoresizingMask  = (UIViewAutoresizing.flexibleWidth)
        if let input = self.tvInput {
            input.delegate = self
        }
    }
    
    // set maxLines based on external UITextView (sorry my shortcut to create documentation doesn't work, i don't know why)
    open func setInputViewMaxLines(with lines: CGFloat, basedOn view: UITextView) {
        self.inputViewMaxLines = lines
        self.inputToBeCalculated = view
    }
    
    @IBAction private func clickUISendButton(_ sender: Any) {
        guard let text = self.tvInput?.text else {return}
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let message = CommentModel()
            message.message = text
            message.type    = "text"
            self._delegate?.send(message: message)
        }
        self.tvInput?.text = ""
    }
    
    private func calculateHeight() -> CGRect {
        
        if let customInputView = self.inputToBeCalculated {
            // do calculation based on custom view by client app
            return self.getInputHeight(inputView: customInputView)
        } else {
            // do calculation based default input view
            if let inputView = tvInput {
                return self.getInputHeight(inputView: inputView)
            }
        }
        
        return CGRect()
    }
    
    private func getInputHeight(inputView: UITextView) -> CGRect {
        var tvInputFrame = inputView.frame
        tvInputFrame.size.height = inputView.contentSize.height + 2
        
        var inputContainerFrame = self.frame
        inputContainerFrame.size.height = inputView.contentSize.height + 10
        return inputContainerFrame
    }
}

extension UIChatInput : UITextViewDelegate {
    open func textViewDidChange(_ textView: UITextView) {
        let fontHeight = textView.font?.lineHeight
        let line = textView.contentSize.height / fontHeight!
        
        if line < inputViewMaxLines {
            self.frame = self.calculateHeight()
            self.layoutIfNeeded()
        }
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        self._delegate?.typing(true)
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        self._delegate?.typing(false)
    }
}

extension UIChatInput : UIChatInputAction {
    public func typing(_ value: Bool) {
        self._delegate?.typing(value)
    }
    
    public func send(message : CommentModel) {
        self._delegate?.send(message: message)
    }
}
