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
        
        registerCell()
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
    }
    
    // MARK: How to implement custom view cell by comment type
    func registerCell() {
        self.registerClass(nib: UINib(nibName: "ImageViewCell", bundle: nil), forMessageCellWithReuseIdentifier: "image")
    }
    
    override func indentifierFor(message: CommentModel, atUIChatViewController : UIChatViewController) -> String {
        if message.type == "file_attachment" {
            return "image"
        }else {
            return super.indentifierFor(message: message, atUIChatViewController: atUIChatViewController)
        }
    }
    
    // MARK: How to implement custom input chat
    // register custom input
    override func chatInputBar() -> UIChatInput? {
        let inputBar = CustomChatInput()
        inputBar.delegate = self
        return inputBar
    }
}

extension ChatViewController : CustomChatInputDelegate {
    func sendAttachment() {
        let optionMenu = UIAlertController()
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Deleted")
        })
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Saved")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
}
