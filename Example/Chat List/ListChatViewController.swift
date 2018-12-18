//
//  ListChatViewController.swift
//  example
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI
import QiscusCore

class ListChatViewController: UIChatListViewController {

    override func viewDidLoad() {
        self.delegate = self
        super.viewDidLoad()
        self.title = "Chat List"
        // Do any additional setup after loading the view.
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChat))
        let play = UIBarButtonItem(title: "Group", style: .plain, target: self, action: #selector(addGroup))
        
        self.registerCell(cellClass: CustomChatListCell.self, forCellWithReuseIdentifier: "customCellIdentifier")
        self.registerCell(nib: UINib(nibName: "CustomChatListCell", bundle: nil), forCellWithReuseIdentifier: "customCellIdentifier")
        navigationItem.rightBarButtonItems = [add, play]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func logout() {
        QiscusCore.logout { (error) in
            let local = UserDefaults.standard
            local.removeObject(forKey: "AppID")
            local.synchronize()
            let app = UIApplication.shared.delegate as! AppDelegate
            app.auth()
        }
    }
    
    @objc func addChat() {
        let alert = UIAlertController(title: "Create chat with", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Qiscus User or email"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let name = alert.textFields?.first?.text {
                QiscusCore.shared.getRoom(withUser: name, onSuccess: { (results, _) in
                    self.chat(withRoom: results)
                }, onError: { (error) in
                    //
                })
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    @objc func addGroup() {
        let names = ["Semarang", "jogja", "jakarta", "bogor", "palembang"]
        let randomName = names[Int(arc4random_uniform(UInt32(names.count)))]
        QiscusCore.shared.createGroup(withName: randomName, participants: ["amsibsam", "amsibsan", "hijuju", "qwerty"], avatarUrl: nil, onSuccess: { (room) in
            self.chat(withRoom: room)
        }) { (error) in
            //
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = self.rooms[indexPath.row]
        self.chat(withRoom: room)
    }

    private func chat(withRoom room: RoomModel) {
        let target = ChatViewController()
        // alternative load ui then set room data, but you need to handle loading. only know room id
//        target.roomID = room.id
        target.room = room
        
        // Demo custom input
        let optionMenu = UIAlertController()
        let buttons = UIAlertAction(title: "Input Buttons", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            target.inputType = .buttons
            self.navigationController?.pushViewController(target, animated: true)
        })
        let attachment = UIAlertAction(title: "Input and Attachment", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            target.inputType = .attachment
            self.navigationController?.pushViewController(target, animated: true)
        })
        let clear = UIAlertAction(title: "Clear", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            QiscusCore.shared.deleteAllMessage(roomID: [room.id], completion: { (error) in
                //
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.navigationController?.pushViewController(target, animated: true)
        })
        optionMenu.addAction(buttons)
        optionMenu.addAction(attachment)
        optionMenu.addAction(clear)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
}

extension ListChatViewController: UIChatListViewDelegate {
    func uiChatList(tableView: UITableView, cellForRoom room: RoomModel, atIndexPath indexpath: IndexPath) -> BaseChatListCell? {
        if room.unreadCount > 5 {
            return tableView.dequeueReusableCell(withIdentifier: "customCellIdentifier", for: indexpath) as? BaseChatListCell
        }
        return nil
    }
}
