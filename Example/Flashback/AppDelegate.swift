//
//  AppDelegate.swift
//  Flashback
//
//  Created by LuckyPia on 11/01/2021.
//  Copyright (c) 2021 LuckyPia. All rights reserved.
//

import UIKit
import Flashback

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        
        var config = FlashbackConfig.default
        config.style = .custom
        config.color = .black
        config.indicatorColor = .yellow
        FlashbackManager.shared.config = config
        FlashbackManager.shared.isEnable = true
        
        return true
    }

}

