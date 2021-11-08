//
//  FlashbackManager.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

// MARK: 闪回管理器

/// 闪回管理器
public class FlashbackManager: NSObject {
    public typealias BackAction = FlashbackItem<AnyObject>.BackAction

    /// 单例
    public static let shared: FlashbackManager = .init()

    override private init() {}

    /// 闪回通知名
    public static let FlashbackNotificationName: NSNotification.Name = .init(rawValue: "FlashbackNotificationName")

    /// 配置
    public var config: FlashbackConfig = .default {
        didSet {
            backWindow.config = config
        }
    }

    /// 处理返回的目标窗口
    public lazy var targetWindow: UIWindow? = {
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

    /// 闪回前置，返回true继续向下执行，返回false终止
    public var preFlashback: BackAction?

    /// 返回栈
    public var backStack: [FlashbackItem<AnyObject>] = []

    /// 指示器窗口
    lazy var backWindow = FlashbackWindow(frame: UIScreen.main.bounds)

    /// 是否可用
    public var isEnable = false {
        didSet {
            setup()
        }
    }

    /// 初始化设置
    func setup() {
        if isEnable {
            DispatchQueue.main.async {
                self.backWindow.isHidden = false
                self.backWindow.windowLevel = .statusBar + 1
            }
        } else {
            DispatchQueue.main.async {
                self.backWindow.isHidden = true
                self.backWindow.windowLevel = .statusBar - 300
            }
        }
    }

    /// 添加返回栈
    /// - Parameters:
    ///   - target: 目标，如果为nil则会被移除
    ///   - action: 返回动作闭包，闭包返回true才从返回栈移除
    public func addFlahback<T: AnyObject>(_ target: T?, action: @escaping BackAction) {
        backStack.append(FlashbackItem(target: target, action: action))
    }

    /// 返回
    func doBack() {
        switch config.backMode {
        case .normal:
            // 闪回前置，返回true继续向下执行，返回false终止
            if let flag = preFlashback?(), !flag {
                return
            }
            // 如果backStack有数据，则优先执行
            if let stackTop = backStack.last {
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
                currentVC()?.onFlashback()
            }
        case .notify:
            // 一切交由通知接管
            NotificationCenter.default.post(name: FlashbackManager.FlashbackNotificationName, object: nil)
        }
    }

    /// 当前控制器
    func currentVC() -> UIViewController? {
        let vc = targetWindow?.rootViewController
        return FlashbackManager.topVC(of: vc)
    }

    /// 私有递归查找最顶级视图
    class func topVC(of viewController: UIViewController?) -> UIViewController? {
        if viewController == nil {
            return nil
        }
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
        if let pageViewController = viewController as? UIPageViewController,
           pageViewController.viewControllers?.count == 1
        { // UIPageController
            return topVC(of: pageViewController.viewControllers?.first)
        }
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return topVC(of: childViewController) // 子VC
            }
        }
        return viewController
    }
}
