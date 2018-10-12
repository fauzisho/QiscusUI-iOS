//
//  ImageViewCell.swift
//  Example
//
//  Created by Qiscus on 30/08/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI
import QiscusCore
import AlamofireImage

class ImageViewCell: UIBaseChatCell {

    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var imageViewMessage: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var imageViewStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        // parsing payload
        // get image
        self.labelName.text = message.username
        self.labelTime.text = self.hour(date: message.date)
        print("payload: \(message.payload)")
        guard let payload = message.payload else { return }
        let caption = payload["caption"] as? String
        
        self.labelCaption.text = caption
        if let url = payload["url"] as? String {
//            self.imageViewMessage.af_setImage(withURL: URL(string: url)!)
      
            // Download file, becareful for lag
            QiscusCore.shared.download(url: URL(string: url)!, onSuccess: { (localPath) in
                print("download result : \(localPath)")
                // handle lagging
                if let cache = ImageCache.shared.cache.object(forKey: NSString(string: url)) {
                    self.imageViewMessage.image = cache
                }else {
                    DispatchQueue.global(qos: .background).async {
                        let data    = NSData(contentsOf: localPath)
                        let image   = UIImage(data: data! as Data)
                        DispatchQueue.main.async {
                            ImageCache.shared.cache.setObject(image!, forKey: NSString(string: url))
                            self.imageViewMessage.image = image
                        }
                    }
                }
            }) { (progress) in
                print("Download Progress \(progress)")
            }
        }
    }
    
    override func update(message: CommentModel) {
        //
    }
    
    func hour(date: Date?) -> String {
        guard let date = date else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone      = TimeZone.current
        let defaultTimeZoneStr = formatter.string(from: date);
        return defaultTimeZoneStr
    }
}
