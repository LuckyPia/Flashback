//
//  FlashbackConfig.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

// MARK: 闪回配置
/// 闪回配置
@objc public class FlashbackConfig: NSObject {
    /// 返回模式
    @objc public var backMode: BackMode = .normal
    /// 样式
    @objc public var style: FlashbackStyle = .black
    /// 是否模糊
    @objc public var isBlur: Bool = false
    /// 模糊
    @objc public var blurStyle: UIBlurEffect.Style = .dark
    /// 启用位置
    public var enablePositions: [Position] = [.left, .right]
    /// 触发范围
    @objc public var triggerRange: CGFloat = 15
    /// 高度
    @objc public var height: CGFloat = 320
    /// 返回所需最小宽度
    @objc public var minWidth: CGFloat = 20
    /// 最大宽度
    @objc public var maxWidth: CGFloat = 30
    /// 拖动范围
    @objc public var dragRange: CGFloat = 80
    /// 边缘曲率
    @objc public var edgeCurvature: CGFloat = 100
    /// 中心曲率
    @objc public var centerCurvature: CGFloat = 40
    /// 背景颜色
    @objc public var backgroundColor: UIColor = .clear
    /// 背景透明度
    @objc public var opacity: CGFloat = 1
    /// 指示器图片
    @objc public var indicatorImage: UIImage? = rightArrowImage {
        didSet {
            leftIndicatorImage = indicatorImage?.withRenderingMode(.alwaysTemplate)
            rightIndicatorImage = UIImage(cgImage: indicatorImage?.cgImage ?? UIImage().cgImage!, scale: 1, orientation: .upMirrored).withRenderingMode(.alwaysTemplate)
        }
    }

    /// 左边指示器图片
    @objc public var leftIndicatorImage: UIImage? = rightArrowImage?.withRenderingMode(.alwaysTemplate)
    /// 右边指示器图片
    @objc public var rightIndicatorImage: UIImage? = UIImage(cgImage: rightArrowImage!.cgImage!, scale: 1, orientation: .upMirrored).withRenderingMode(.alwaysTemplate)
    /// 指示器图片大小
    @objc public var indicatorSize: CGSize = .init(width: 15, height: 15)
    /// 指示器图片颜色
    @objc public var indicatorColor: UIColor = .white
    /// 消失持续时间（0.1s）
    @objc public var dismissDuartion: CGFloat = 0.1
    /// 忽略顶部高度
    @objc public var ignoreTopHeight: CGFloat = 150
    /// 震动启用（默认true）
    @objc public var vibrateEnable: Bool = true
    /// 震动强度
    @objc public var vibrateStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
    /// 上下滚动开启（推荐false）
    @objc public var scrollEnable: Bool = false
    /// 展示触发区域
    @objc public var showTriggerArea: Bool = false

    /// 默认配置
    @objc public static var `default`: FlashbackConfig {
        let config = FlashbackConfig()
        return config
    }
    
    /// 设置可用位置
    @objc func setEnablePositions(_ positions: NSArray) {
        let _positions = positions as! [Position]
        self.enablePositions = _positions
    }

    /// 右箭头图片
    @objc public static var rightArrowImage: UIImage? {
        guard var url = Bundle.main.url(forResource: "Frameworks", withExtension: nil) else { return nil }
        let podName = "Flashback"
        url = url.appendingPathComponent("\(podName)")
        url = url.appendingPathExtension("framework")
        let mainBundle = Bundle(url: url)
        guard let bundleUrl = mainBundle?.url(forResource: podName, withExtension: "bundle") else { return nil }
        guard let bundle = Bundle(url: bundleUrl) else { return nil }
        let image = UIImage(contentsOfFile: bundle.path(forResource: "flashback_right_arrow.png", ofType: nil)!)
        return image
    }

    /// 返回位置
    @objc public enum Position: Int {
        /// 左边
        case left
        /// 右边
        case right
    }

    /// 样式
    @objc public enum FlashbackStyle: Int {
        /// 白色
        case white
        /// 黑色
        case black
        /// 自定义
        case custom

        /// 名称
        public var name: String {
            switch self {
            case .white:
                return "白色"
            case .black:
                return "黑色"
            case .custom:
                return "自定义"
            }
        }
    }

    /// 返回模式
    @objc public enum BackMode: Int {
        /// 通用
        case normal
        /// 通知 FlashbackNotificationName
        case notify
    }
}
