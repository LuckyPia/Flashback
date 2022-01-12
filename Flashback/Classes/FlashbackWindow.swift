//
//  FlashbackWindow.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/29.
//

import UIKit

// MARK: 辅助将手势返回提到最上层的window
open class FlashbackWindow: UIWindow {
    
    open override func addSubview(_ view: UIView) {
        super.addSubview(view)
        // 添加subview后，将FlashbackView置于顶层
        if FlashbackManager.shared.isEnable {
            FlashbackManager.shared.makeFlashbackToTop()
        }
    }
}
