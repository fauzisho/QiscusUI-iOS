//
//  ChatViewController.swift
//  QiscusUI
//
//  Created by Qiscus on 31/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI
import QiscusCore

class ChatViewController: UIChatViewController {
    var roomID : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // alternative load ui then set room data, but you need to handle loading
        guard let roomid = roomID else { return }
        QiscusCore.shared.getRoom(withID: roomid) { (roomData, error) in
            if let data = roomData {
                self.room = data
            }else {
                // show error
                print("error load room \(String(describing: error?.message))")
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerCell() {
        self.registerClass(nib: UINib(nibName: "QimageCell", bundle: nil), forMessageCellWithReuseIdentifier: "image")
    }

}
