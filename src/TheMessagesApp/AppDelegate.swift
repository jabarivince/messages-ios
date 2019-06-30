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
        
        let loginViewController = LoginViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: loginViewController)
        
        if DefaultAuthenticationService.shared.userIsLoggedIn {
            let channelsViewController = UINavigationController(rootViewController: ChannelsViewController())
            loginViewController.present(channelsViewController, animated: false, completion: nil)
        }
        
        return true
    }
}
