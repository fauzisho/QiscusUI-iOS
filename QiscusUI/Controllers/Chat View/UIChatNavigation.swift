//
//  ChatTitleView.swift
//  QiscusUI
//
//  Created by Qiscus on 25/10/18.
//

import UIKit
import QiscusCore

open class UIChatNavigation: UIView {
    var contentsView            : UIView!
    // ui component
    /// UILabel title,
    @IBOutlet weak open var labelTitle: UILabel!
    /// UILabel subtitle
    @IBOutlet weak open var labelSubtitle: UILabel!
    /// UIImageView room avatar
    @IBOutlet weak open var imageViewAvatar: UIImageView!
    
    public var room: RoomModel? {
        set {
            self._room = newValue
            if let data = newValue { present(room: data) } // bind data only
        }
        get {
            return self._room
        }
    }
    private var _room : RoomModel? = nil
    
    // If someone is to initialize a UIChatInput in code
    public override init(frame: CGRect) {
        // For use in code
        super.init(frame: frame)
        let nib = UINib(nibName: "UIChatNavigation", bundle: QiscusUI.bundle)
        commonInit(nib: nib)
    }
    
    // If someone is to initalize a UIChatInput in Storyboard setting the Custom Class of a UIView
    public required init?(coder aDecoder: NSCoder) {
        // For use in Interface Builder
        super.init(coder: aDecoder)
        let nib = UINib(nibName: "UIChatNavigation", bundle: QiscusUI.bundle)
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
        
        self.autoresizingMask  = (UIView.AutoresizingMask.flexibleWidth)
        self.setupUI()
    }
    
    private func setupUI() {
        // default ui
        if self.imageViewAvatar != nil {
            self.imageViewAvatar.layer.cornerRadius = self.contentsView.frame.height/2
        }
    }
    
    open func present(room: RoomModel) {
        // title value
        self.labelTitle.text = room.name
        self.imageViewAvatar.af_setImage(withURL: room.avatarUrl ?? URL(string: "http://")!)
        if room.type == .group {
            self.labelSubtitle.text = getParticipant(room: room)
        }else {
            let user = QiscusCore.getProfile()
            guard let participants = room.participants else { return }
            guard let opponent = participants.filter({ $0.email == user?.email ?? ""}).first else { return }
            // guard let lastSeen = opponent.lastSeen() else { return }
            // self.labelSubtitle.text = lastSeen.timeAgoSinceDate(numericDates: false)
        }
    }
    
    open func isTyping(room: RoomModel, name: String, typing: Bool) {
        
    }
    
    open func isOnline(name: String, isOnline: Bool, message: String) {
       
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        print("height \(self.contentsView.frame)")
        if self.imageViewAvatar != nil {
            self.imageViewAvatar.layer.cornerRadius = self.contentsView.frame.height/2
        }
    }
    
}

extension UIChatNavigation {
    func getParticipant(room: RoomModel) -> String {
        var result = ""
        guard let participants = room.participants else { return result }
        for m in participants {
            if result.isEmpty {
                result = m.username
            }else {
                result = result + ", \(m.username)"
            }
        }
        return result
    }
}
