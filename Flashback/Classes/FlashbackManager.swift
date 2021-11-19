//
//  FlashbackManager.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

// MARK: 闪回管理器

/// 闪回管理器
@objc public class FlashbackManager: NSObject {
    public typealias BackAction = FlashbackItem.BackAction

    /// 单例
    @objc public static let shared: FlashbackManager = .init()

    override private init() {}

    /// 是否可用
    @objc public var isEnable = false {
        didSet {
            setup()
        }
    }

    /// 闪回通知名
    @objc public static let FlashbackNotificationName: NSNotification.Name = .init(rawValue: "FlashbackNotificationName")

    /// 闪回配置，直接修改对象属性无效，重新赋值生效
    @objc public var config: FlashbackConfig = .default {
        didSet {
            backWindow.config = config
        }
    }

    /// 处理返回的目标窗口
    @objc public lazy var targetWindow: UIWindow? = {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for windowTemp in windows {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    window = windowTemp
                    break
                }
            }
        }
        return window
    }()

    /// 当前控制器
    @objc public var currentVC: (() -> UIViewController?) = {
        let rootVC = FlashbackManager.shared.targetWindow?.rootViewController
        return FlashbackManager.topVC(of: rootVC)
    }

    /// 返回动作
    @objc public var backAction: ((UIViewController) -> Void) = { currentVC in
        if currentVC.navigationController?.topViewController == currentVC,
           currentVC.navigationController?.viewControllers.count ?? 0 > 1
        {
            // pop
            currentVC.navigationController?.popViewController(animated: true)
        } else {
            if currentVC.presentingViewController == nil {
                // pop
                currentVC.navigationController?.popViewController(animated: true)
            } else {
                // dismiss
                currentVC.dismiss(animated: true)
            }
        }
    }

    /// 闪回前置，返回true继续向下执行，返回false终止
    @objc public var preFlashback: (() -> Bool)?

    /// 键盘是否弹出（可在preFlashback判断，决定是否先隐藏键盘，再退出）
    @objc public var showKeyboard: Bool = false

    /// 返回栈
    public var backStack: [FlashbackItem] = []

    /// 指示器窗口
    lazy var backWindow = FlashbackWindow(frame: UIScreen.main.bounds)

    /// 是否是竖屏，如果是横屏模式，不忽略顶部高度
    var isPortrait: Bool = true

    /// 初始化设置
    func setup() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.isEnable {
                self.backWindow.isHidden = false
                self.backWindow.windowLevel = .statusBar + 1
                self.monitorKeyboard(true)
            } else {
                self.backWindow.isHidden = true
                self.backWindow.windowLevel = .statusBar - 300
                self.monitorKeyboard(false)
            }
        }
    }

    /// 添加返回栈
    /// - Parameters:
    ///   - target: 目标，如果为nil则会被移除
    ///   - action: 返回动作闭包，闭包返回true才从返回栈移除
    @objc public func addFlahback(_ target: AnyObject?, action: @escaping BackAction) {
        backStack.append(FlashbackItem(target: target, action: action))
    }

    /// 执行返回逻辑
    func doBack() {
        switch config.backMode {
        case .normal:
            // 闪回前置，返回true继续向下执行，返回false终止
            // 您可以统一处理弹窗、收起键盘、提交日志等等...
            // 巧妙使用该回调，可以减小代码耦合度
            if let flag = preFlashback?(), !flag {
                return
            }
            // 如果backStack栈顶有数据，则执行backStack的栈顶
            if let stackTop = backStack.last {
                // 若对象已销毁，则跳过本次返回，执行下一次返回
                if stackTop.target == nil {
                    backStack.removeLast()
                    doBack()
                    return
                }
                // 返回true才从返回栈移除
                if stackTop.action() {
                    backStack.removeLast()
                }
            } else {
                // 获取当前VC，执行FlashbackProtocol协议实现的onFlashback()方法（该方法有默认实现）
                currentVC()?.onFlashback()
            }
        case .notify:
            // 一切交由通知接管
            NotificationCenter.default.post(name: FlashbackManager.FlashbackNotificationName, object: nil)
        }
    }

    /// 递归查找最顶级视图
    @objc public class func topVC(of viewController: UIViewController?) -> UIViewController? {
        if let presentedViewController = viewController?.presentedViewController {
            return topVC(of: presentedViewController) // presented的VC
        }
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController
        {
            return topVC(of: selectedViewController) // UITabBarController
        }
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController
        {
            return topVC(of: visibleViewController) // UINavigationController
        }
        return viewController
    }

    /// 监控键盘
    func monitorKeyboard(_ isMonitor: Bool) {
        let notify = NotificationCenter.default
        if isMonitor {
            notify.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: nil) { [weak self] _ in
                guard let `self` = self else { return }
                self.showKeyboard = true
            }
            notify.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] _ in
                guard let `self` = self else { return }
                self.showKeyboard = false
            }
        } else {
            notify.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
            notify.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
}
