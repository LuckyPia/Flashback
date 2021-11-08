//
//  FlashbackProtecol.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

// MARK: 闪回代理

/// 闪回代理
@objc public protocol FlashbackDelegate {
    /// 返回回调
    @objc func onFlashback()
}

// MARK: 闪回代理默认实现

/// 闪回代理默认实现
extension UIViewController: FlashbackDelegate {
    open func onFlashback() {
        if presentingViewController != nil {
            // dismiss
            dismiss(animated: true)
        } else {
            // pop
            navigationController?.popViewController(animated: true)
        }
    }
}
