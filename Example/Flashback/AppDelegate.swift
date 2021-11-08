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
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()

        var config = FlashbackConfig.default
        config.enablePositions = [.left, .right]
        config.triggerRange = 20
        config.vibrateEnable = true
        if #available(iOS 13.0, *) {
            config.vibrateStyle = .soft
        } else {
            config.vibrateStyle = .light
        }
        config.style = .black
        config.backgroundColor = .black
        config.indicatorColor = .yellow
        config.scrollEnable = false
        config.ignoreTopHeight = 150
        FlashbackManager.shared.config = config
        FlashbackManager.shared.isEnable = true
        FlashbackManager.shared.targetWindow = window

        return true
    }
}
