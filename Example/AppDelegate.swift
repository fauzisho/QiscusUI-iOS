//
//  AppDelegate.swift
//  example
//
//  Created by Qiscus on 29/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import QiscusUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1] as URL)
        QiscusCore.enableDebugPrint = true
        self.setupAppID()
        QiscusCore.setSync(interval: 10)
//        QiscusCore.set(customServer: URL.init(string: "https://54.254.226.35/api/v2/mobile")!, realtimeServer: "mqtt", realtimePort: 8001)
        auth()
        
        return true
    }
    
    func auth() {
        let target : UIViewController
        if QiscusCore.isLogined {
            target = ListChatViewController()
            // if your are using qiscus ui, qiscuscoredelegate already use in there. but, you can got qiscus event using ChatUIDelegate
            QiscusUI.delegate = self
            _ = QiscusCore.connect(delegate: self)
        }else {
            target = LoginViewController()
        }
        let navbar = UINavigationController()
        navbar.viewControllers = [target]
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navbar
        self.window?.makeKeyAndVisible()
    }

    // save app id from login with user or jwt
    func setupAppID() {
        let local = UserDefaults.standard
        if let appid = local.string(forKey: "AppID") {
            QiscusCore.setup(WithAppID: appid)
        }else {
            QiscusCore.setup(WithAppID: "sampleapp-65ghcsaysse") // default
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        QiscusCore.shared.sync(onSuccess: { (comments) in
            //
        }) { (error) in
             print(error.message)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        QiscusCore.shared.sync(onSuccess: { (comments) in
            //
        }) { (error) in
            print(error.message)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        QiscusCore.shared.sync(onSuccess: { (comments) in
            //
        }) { (error) in
            print(error.message)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
}

extension AppDelegate : UIChatDelegate {
    func onRoom(update room: RoomModel) {
        //
    }
    
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel) {
        print("got new comment: \(comment.message)")
    }
    
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus) {
        
    }
    
    func onRoom(_ room: RoomModel, thisParticipant user: MemberModel, isTyping typing: Bool) {
        
    }
    
    func onChange(user: MemberModel, isOnline online: Bool, at time: Date) {
        
    }
    
    func gotNew(room: RoomModel) {
        
    }
    
    func remove(room: RoomModel) {
        
    }
}

extension AppDelegate : QiscusConnectionDelegate {
    func disconnect(withError err: QError?) {
        //
    }
    
    func connected() {
        //
    }
    
    func connectionState(change state: QiscusConnectionState) {
        //
    }
    
}

