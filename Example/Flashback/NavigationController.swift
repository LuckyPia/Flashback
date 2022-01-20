//
//  NavigationController.swift
//  Flashback_Example
//
//  Created by yupao_ios_macmini05 on 2021/12/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactivePopGestureRecognizer?.isEnabled = false
        
        // 从中间滑动返回
//        let target = self.interactivePopGestureRecognizer?.delegate
//        let handler = NSSelectorFromString("handleNavigationTransition:")
//        let pan = UIPanGestureRecognizer(target: target, action: handler)
//        pan.delegate = self
//        self.interactivePopGestureRecognizer?.view?.addGestureRecognizer(pan)
//        self.interactivePopGestureRecognizer?.isEnabled = false
//        weak var weakSelf = self
//        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)) {
//            self.interactivePopGestureRecognizer?.delegate = weakSelf
//        }
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 控制器栈里只有一个，不响应
        if self.viewControllers.count <= 1 {
            return false
        }
        // 当控制器正在返回的时候，不响应
        if let isTransitioning = self.value(forKey: "_isTransitioning") as? Bool, isTransitioning {
            return false
        }
        // 只能响应 从左到右的滑动
        if let translation = (gestureRecognizer as? UIPanGestureRecognizer)?.translation(in: gestureRecognizer.view) {
            if translation.x <= 0 {
                return false
            }
        }
        return true
    }
}
