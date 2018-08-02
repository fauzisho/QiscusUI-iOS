//
//  ListChatViewController.swift
//  example
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI

class ListChatViewController: UIChatListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat List"
        // Do any additional setup after loading the view.
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "EditImage"), style: .done, target: self, action: #selector(self.addGroup))
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func addGroup() {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let target = ChatViewController()
        target.room = self.rooms[indexPath.row]
        self.navigationController?.pushViewController(target, animated: true)
    }

}
