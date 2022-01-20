//
//  FlashbackWindow.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/29.
//

import UIKit

// MARK: 辅助将手势返回提到最上层的window
class FlashbackWindow: UIWindow {
    
    /// iOS15支持
    override var canBecomeKey: Bool {
        return false
    }
    
    override var isKeyWindow: Bool {
        return false
    }
    
    /// 配置
    var config: FlashbackConfig = .default {
        didSet {
            self.backVC.config = config
        }
    }

    /// 返回VC
    lazy var backVC: FlashbackViewController = {
        let vc = FlashbackViewController()
        return vc
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        windowLevel = .alert + 1
        backgroundColor = .clear

        rootViewController = backVC
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 如果正处于返回中，隔绝其他点击事件
        if FlashbackManager.shared.isBacking {
            return super.hitTest(point, with: event)
        }
        // 是否可操作，是否隐藏，是否透明
        guard isUserInteractionEnabled, !isHidden, alpha > 0 else {
            return nil
        }
        // 是否可以返回
        guard FlashbackManager.shared.enable() else {
            return nil
        }
        // 顶部高度忽略
        let ignoreTopHeight = FlashbackManager.shared.isPortrait ? config.ignoreTopHeight : 0
        if point.y < ignoreTopHeight {
            return nil
        }
        // 左右触发范围判断
        if (point.x < config.triggerRange && config.enablePositions.contains(.left)) || (point.x > bounds.width - config.triggerRange && config.enablePositions.contains(.right)) {
            return super.hitTest(point, with: event)
        }
        return nil
    }
    
}

