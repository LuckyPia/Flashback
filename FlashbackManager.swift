//
//  FlashbackManager.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

/// 闪回管理器
public class FlashbackManager: NSObject {
    
    typealias BackAction = FlashbackItem.BackAction
    
    /// 单例
    public static let shared: FlashbackManager = .init()
    
    private override init() { }
    
    /// 返回通知名
    public let FlashbackNotificationName: NSNotification.Name = .init(rawValue: "FlashbackNotificationName")
    
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
    func addFlahback(_ target: Any?, action: @escaping BackAction) {
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
                stackTop.action()
                self.backStack.removeLast()
            }else {
                FlashbackManager.currentVC()?.onFlashBack()
            }
        case .notify:
            NotificationCenter.default.post(name: FlashbackNotificationName, object: nil)
        }
    }
    
    /// 当前控制器
    class func currentVC() -> UIViewController? {
        var keyWindow: UIWindow?
        if #available(iOS 15.0, *) {
            let windows = UIApplication.shared.connectedScenes
                .filter{ $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
            keyWindow = windows?.first(where: { $0.windowLevel == .normal && !$0.isKind(of: FlashbackWindow.self)} )
        }else {
            keyWindow = UIApplication.shared.windows
                .filter{ $0.windowLevel == .normal && !$0.isKind(of: FlashbackWindow.self) }
                .first
        }

        let rootViewController: UIViewController? = keyWindow?.rootViewController
        return topVC(of: rootViewController)
    }
    
    /// 私有递归查找最顶级视图
    class func topVC(of viewController: UIViewController?) -> UIViewController? {
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

