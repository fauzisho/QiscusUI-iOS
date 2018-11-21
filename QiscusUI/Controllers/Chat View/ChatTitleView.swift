//
//  ChatTitleView.swift
//  QiscusUI
//
//  Created by Qiscus on 25/10/18.
//

import UIKit

public class ChatTitleView: UIView {
    var contentsView            : UIView!
    // ui component
    @IBOutlet weak public var labelTitle: UILabel!
    @IBOutlet weak public var labelSubtitle: UILabel!
    @IBOutlet weak public var imageViewAvatar: UIImageView!
    
    // If someone is to initialize a UIChatInput in code
    public override init(frame: CGRect) {
        // For use in code
        super.init(frame: frame)
        let nib = UINib(nibName: "ChatTitleView", bundle: QiscusUI.bundle)
        commonInit(nib: nib)
    }
    
    // If someone is to initalize a UIChatInput in Storyboard setting the Custom Class of a UIView
    public required init?(coder aDecoder: NSCoder) {
        // For use in Interface Builder
        super.init(coder: aDecoder)
        let nib = UINib(nibName: "ChatTitleView", bundle: QiscusUI.bundle)
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
        self.customUI()
    }
    
    public func customUI() {
        // default ui
        print("height \(self.contentsView.frame)")
        self.imageViewAvatar.layer.cornerRadius = self.contentsView.frame.height/2
//        self.imageViewAvatar.cornerRadiusRatio = 0.5
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        print("height \(self.contentsView.frame)")
        self.imageViewAvatar.layer.cornerRadius = self.contentsView.frame.height/2
    }
    
}
