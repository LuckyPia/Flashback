//
//  FlashbackProtecol.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

// MARK: 返回代理
@objc public protocol FlashbackDelegate {
    /// 返回回调
    @objc func onFlashBack()
}

// MARK: 默认实现
extension UIViewController: FlashbackDelegate {
    open func onFlashBack() {
        if self.presentingViewController != nil {
            // dismiss
            self.dismiss(animated: true)
        }else {
            // pop
            self.navigationController?.popViewController(animated: true)
        }
    }
}
