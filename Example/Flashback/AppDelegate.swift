//
//  AppDelegate.swift
//  Flashback
//
//  Created by LuckyPia on 11/01/2021.
//  Copyright (c) 2021 LuckyPia. All rights reserved.
//

import Flashback
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = NavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        
        FlashbackManager.shared.config = FlashbackConfig.default
        FlashbackManager.shared.isEnable = true
        FlashbackManager.shared.targetWindow = window
        return true
    }
}
