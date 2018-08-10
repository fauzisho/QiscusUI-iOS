//
//  LoginViewController.swift
//  example
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import QiscusUI

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickLogin(_ sender: Any) {
        QiscusCore.connect(userID: "hijuju", userKey: "12345678") { (result, error) in
            if result != nil {
                self.navigationController?.pushViewController(ListChatViewController(), animated: true)
            }else {
                print("error \(String(describing: error))")
            }
        }  
    }
}
