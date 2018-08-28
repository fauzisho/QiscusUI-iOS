//
//  UIChatListViewCell.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import AlamofireImage

class UIChatListViewCell: UITableViewCell {

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: QiscusUI.bundle)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var viewBadge: UIView!
    @IBOutlet weak var imageViewPinRoom: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLastMessage: UILabel!
    @IBOutlet weak var imageViewRoom: UIImageView!
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var labelBadge: UILabel!
    var data : RoomModel? {
        didSet {
            if data != nil {
                self.setupUI()
            }
        }
    }
    
    var lastMessageCreateAt:String{
        get{
            return ""
            let createAt = data?.lastComment?.unixTimestamp
            if createAt == 0 {
                return ""
            }else{
                var result = ""
                let date = Date(timeIntervalSince1970: Double(createAt!))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d/MM"
                let dateString = dateFormatter.string(from: date)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                let timeString = timeFormatter.string(from: date)
                
                if date.isToday{
                    result = "\(timeString)"
                }
                else if date.isYesterday{
                    result = "Yesterday"
                }else{
                    result = "\(dateString)"
                }
                
                return result
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageViewRoom.layer.cornerRadius = imageViewRoom.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI() {
        if let data = data {
            self.labelName.text = data.name
            self.labelDate.text = lastMessageCreateAt
            
            var message = ""
            if data.lastComment?.type == ""{
                message = "File Attachment"
            }else{
                message = (data.lastComment?.message)!
            }
            
            if(data.type != .single){
                self.labelLastMessage.text  =  "\((data.lastComment?.username)!): \(message)"
            }else{
                 self.labelLastMessage.text  = message
            }
            if let avatar = data.avatarUrl {
                self.imageViewRoom.af_setImage(withURL: avatar)
            }
            if(data.unreadCount == 0){
                self.hiddenBadge()
            }else{
                self.showBadge()
                self.labelBadge.text = "\(data.unreadCount)"
            }
            
        }
    }
    
    public func hiddenBadge(){
        self.viewBadge.isHidden     = true
        self.labelBadge.isHidden    = true
    }
    
    public func showBadge(){
        self.viewBadge.isHidden     = false
        self.labelBadge.isHidden    = false
    }
    
}
