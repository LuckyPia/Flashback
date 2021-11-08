//
//  FlashbackWindow.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/29.
//

import UIKit

// MARK: 闪回窗口

/// 闪回窗口
class FlashbackWindow: UIWindow {
    /// 配置
    var config: FlashbackConfig = .default {
        didSet {
            self.backVC.config = config
        }
    }

    /// 返回视图
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
        guard isUserInteractionEnabled, !isHidden, alpha > 0 else {
            return nil
        }
        if point.y < config.ignoreTopHeight {
            return nil
        }
        if (point.x < config.triggerRange && config.enablePositions.contains(.left)) || (point.x > bounds.width - config.triggerRange && config.enablePositions.contains(.right)) {
            return super.hitTest(point, with: event)
        }
        return nil
    }
}
