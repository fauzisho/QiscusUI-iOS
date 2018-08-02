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
        
        QiscusCore.setup(WithAppID: "sampleapp-65ghcsaysse")
        QiscusCore.enableDebugPrint = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickLogin(_ sender: Any) {
        let list = ListChatViewController()
        
        QiscusCore.connect(userID: "juang", userKey: "12345678") { (result, error) in
            if result != nil {
                self.navigationController?.pushViewController(list, animated: true)
            }else {
                print("error \(String(describing: error))")
            }
        }
        
        
    }
}
