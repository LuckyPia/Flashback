//
//  AppDelegate.swift
//  Flashback
//
//  Created by 664454335@qq.com on 11/01/2021.
//  Copyright (c) 2021 664454335@qq.com. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController.init(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        
        var config = FlashbackConfig()
        config.style = .custom
        config.color = .black
        config.indicatorColor = .yellow
        FlashbackManager.shared.config = config
        FlashbackManager.shared.isEnable = true
        
        return true
    }


}

