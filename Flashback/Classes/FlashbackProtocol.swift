//
//  FlashbackProtecol.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

// MARK: 闪回协议

/// 闪回协议
@objc public protocol FlashbackProtocol: NSObjectProtocol {
    /// 返回回调
    @objc func onFlashback()
}

// MARK: 闪回代理默认实现

/// 闪回代理默认实现
extension UIViewController: FlashbackProtocol {
    open func onFlashback() {
        FlashbackManager.shared.backAction(self)
    }
}
