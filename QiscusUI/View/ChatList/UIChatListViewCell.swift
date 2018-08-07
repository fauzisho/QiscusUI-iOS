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
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLastMessage: UILabel!
    @IBOutlet weak var imageViewRoom: UIImageView!
    @IBOutlet weak var labelDate: UILabel!
    
    var data : RoomModel? {
        didSet {
            if data != nil {
                self.setupUI()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI() {
        if let data = data {
            self.labelName.text = data.name
//            self.labelDate.text = data.lastComment?.time
            self.labelLastMessage.text  = data.lastComment?.message
            self.imageViewRoom.af_setImage(withURL: URL.init(string: data.avatarUrl)!)
        }
    }
    
}
