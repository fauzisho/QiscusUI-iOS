//
//  UIChatInput.swift
//  QiscusUI
//
//  Created by Qiscus on 04/09/18.
//

import UIKit

public protocol UIChatInputDelegate {
    func send()
}

class UIChatInput: UIView {

    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var tfInput: UITextField!
    
    var contentsView: UIView!

    // If someone is to initialize a UIChatInput in code
    public override init(frame: CGRect) {
        // For use in code
        super.init(frame: frame)
        commonInit()
    }
    
    // If someone is to initalize a UIChatInput in Storyboard setting the Custom Class of a UIView
    public required init?(coder aDecoder: NSCoder) {
        // For use in Interface Builder
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // 1. Load the nib named 'UIChatInput' into memory, finding it in the bundle.
        let nib = UINib(nibName: "UIChatInput", bundle: QiscusUI.bundle)
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
    }
}

extension UIChatInput : UIChatInputDelegate {
    open func send() {
        //
    }
}
