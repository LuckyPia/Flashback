//
//  FlashbackManager.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

// MARK: 闪回管理器

/// 闪回管理器
@objc
public class FlashbackManager: NSObject {

    /// 单例
    @objc
    public static let shared: FlashbackManager = .init()

    private override init() { }

    /// 是否可用
    @objc
    public var isEnable = false {
        didSet {
            setup()
        }
    }

    /// 闪回通知名
    @objc
    public static let FlashbackNotification: NSNotification.Name = .init(rawValue: "FlashbackNotification")

    /// 闪回配置，直接修改对象属性无效，重新赋值生效
    @objc
    public var config: FlashbackConfig = .default {
        didSet {
            self.flashbackWindow.config = config
        }
    }

    /// 处理返回的目标窗口
    @objc
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
    
    /// 指示器视图
    private lazy var flashbackWindow = FlashbackWindow(frame: UIScreen.main.bounds)
    
    /// 闪回前置，返回true继续向下执行，返回false终止
    @objc public var preFlashback: ((_ targetWindow: UIWindow?, _ currentVC: UIViewController?) -> Bool)?

    /// 键盘是否弹出（可在preFlashback判断，决定是否先隐藏键盘，再退出）
    @objc public var showKeyboard: Bool = false

    /// 是否是竖屏，如果是横屏模式，不忽略顶部高度
    var isPortrait: Bool = true
    
    /// 是否正在返回
    var isBacking: Bool = false {
        didSet {
            if let targetWindow = self.targetWindow , !targetWindow.isKeyWindow {
                targetWindow.makeKeyAndVisible()
            }
        }
    }
    
    /// 在那些情况下可用
    @objc
    public var enable: (() -> Bool) = {
        return true
    }

    /// 当前控制器
    @objc
    public var currentVC: ((_ targetWindow: UIWindow?) -> UIViewController?) = { targetWindow in
        let rootVC = targetWindow?.rootViewController
        return FlashbackManager.topVC(of: rootVC)
    }

    /// 返回动作
    @objc
    public var backAction: ((UIViewController) -> Void) = { vc in
        if vc.navigationController?.topViewController == vc,
           vc.navigationController?.viewControllers.count ?? 0 > 1
        {
            // pop
            vc.navigationController?.popViewController(animated: true)
        } else {
            if vc.presentingViewController == nil {
                // pop
                vc.navigationController?.popViewController(animated: true)
            } else {
                // dismiss
                vc.dismiss(animated: true)
            }
        }
    }
    
    /// 初始化设置
    func setup() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.isEnable {
                if let targetWindow = self.targetWindow {
                    self.flashbackWindow.isHidden = false
                    self.flashbackWindow.windowLevel = .statusBar + 1
                    self.monitorKeyboard(true)
                    self.monitorDeviceOrientation(true)
                }else {
                    fatalError("targetWindow can not be nil")
                }
            } else {
                self.flashbackWindow.isHidden = true
                self.flashbackWindow.windowLevel = .statusBar - 300
                self.monitorKeyboard(false)
            }
        }
    }

    /// 执行返回逻辑
    func doBack() {
        switch config.backMode {
        case .normal:
            /// 如果键盘打开，先消失键盘
            if showKeyboard {
                self.targetWindow?.endEditing(true)
                return
            }
            // 闪回前置，返回true继续向下执行，返回false终止
            // 您可以统一处理弹窗、收起键盘、提交日志等等...
            // 巧妙使用该回调，可以减小代码耦合度
            let currentVC = currentVC(targetWindow)
            if preFlashback?(targetWindow, currentVC) == false {
                return
            }
            // 获取当前VC，执行FlashbackProtocol协议实现的onFlashback()方法（该方法有默认实现）
            currentVC?.onFlashback()
        case .notify:
            // 一切交由通知接管
            NotificationCenter.default.post(name: FlashbackManager.FlashbackNotification, object: nil)
        }
    }

    /// 递归查找最顶级视图
    @objc
    public class func topVC(of viewController: UIViewController?) -> UIViewController? {
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
    
    /// 检测设备方向
    private func monitorDeviceOrientation(_ isMonitor: Bool) {
        let notify = NotificationCenter.default
        if isMonitor {
            notify.addObserver(self, selector: #selector(receivedRotation), name: UIDevice.orientationDidChangeNotification, object: nil)
        }else {
            notify.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    //通知监听触发的方法
    @objc
    private func receivedRotation(_ isMonitor: Bool){
        // 屏幕方向
        switch UIDevice.current.orientation {
        case .portrait: // Device oriented vertically, home button on the bottom
            self.isPortrait = true
        case .landscapeLeft: // Device oriented horizontally, home button on the right
            self.isPortrait = false
        case .landscapeRight: // Device oriented horizontally, home button on the left
            self.isPortrait = false
        default: break
        }
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
