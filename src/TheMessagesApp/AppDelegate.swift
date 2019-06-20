//
//  AppDelegate.swift
//  TheMessagesApp
//
//  Created by jabari on 5/30/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        if let user = Auth.auth().currentUser {
            window?.rootViewController = UINavigationController(rootViewController: ChannelsViewController(currentUser: user))
        } else {
            window?.rootViewController =  UINavigationController(rootViewController: LoginViewController())
        }
        
        return true
    }
}
