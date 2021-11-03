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
    
    public typealias BackAction = FlashbackItem.BackAction
    
    /// 单例
    public static let shared: FlashbackManager = .init()
    
    private override init() { }
    
    /// 闪回通知名
    public static let FlashbackNotificationName: NSNotification.Name = .init(rawValue: "FlashbackNotificationName")
    
    /// 配置
    public var config: FlashbackConfig = .default {
        didSet {
            self.backWindow.config = config
        }
    }
    
    ///  返回栈
    public var backStack: [FlashbackItem] = []
    
    /// 返回窗口
    lazy var backWindow: FlashbackWindow = {
        let window = FlashbackWindow(frame: UIScreen.main.bounds)
        return window
    }()
    
    /// 是否可用
    public var isEnable = false {
        didSet {
            self.setup()
        }
    }
    
    /// 初始化设置
    func setup() {
        if isEnable {
            DispatchQueue.main.async {
                self.backWindow.isHidden = false
                self.backWindow.windowLevel = .statusBar + 1
            }
        }else {
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
    public func addFlahback(_ target: Any?, action: @escaping BackAction) {
        self.backStack.append(FlashbackItem(target: target, action: action))
    }
    
    /// 返回
    func doBack() {
        switch config.backMode {
        case .normal:
            if let stackTop = self.backStack.last {
                if stackTop.target == nil {
                    self.backStack.removeLast()
                    self.doBack()
                }
                // 返回true才从返回栈移除
                if stackTop.action() {
                    self.backStack.removeLast()
                }
            }else {
                FlashbackManager.currentVC()?.onFlashBack()
            }
        case .notify:
            NotificationCenter.default.post(name: FlashbackManager.FlashbackNotificationName, object: nil)
        }
    }
    
    /// 当前控制器
    public class func currentVC() -> UIViewController? {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindow.Level.normal{
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindow.Level.normal{
                    window = windowTemp
                    break
                }
            }
        }
        let vc = window?.rootViewController
        return topVC(of: vc)
    }
    
    /// 私有递归查找最顶级视图
    class func topVC(of viewController: UIViewController?) -> UIViewController? {
        if viewController == nil {
            return nil
        }
        if let presentedViewController = viewController?.presentedViewController {
            return topVC(of: presentedViewController)// presented的VC
        }
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topVC(of: selectedViewController) // UITabBarController
        }
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return topVC(of: visibleViewController) // UINavigationController
        }
        if let pageViewController = viewController as? UIPageViewController,
           pageViewController.viewControllers?.count == 1 { // UIPageController
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

