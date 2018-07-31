//
//  UIChatListViewCell.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

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
    
    var data : QRoom? {
        didSet {
            self.setupUI()
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
        self.labelName.text = self.data?.roomName
//        self.labelDate.text = self.data
        
    }
    
}
