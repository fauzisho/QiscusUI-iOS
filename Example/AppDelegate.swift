//
//  AppDelegate.swift
//  example
//
//  Created by Qiscus on 29/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        QiscusCore.enableDebugPrint = true
        QiscusCore.setup(WithAppID: "sampleapp-65ghcsaysse")
//        QiscusCore.set(customServer: URL.init(string: "https://54.254.226.35/api/v2/mobile")!, realtimeServer: "mqtt", realtimePort: 8001)
        
        let target : UIViewController
        if QiscusCore.isLogined {
            target = ListChatViewController()
        }else {
            target = LoginViewController()
        }
        let navbar = UINavigationController()
        navbar.viewControllers = [target]
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navbar
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

