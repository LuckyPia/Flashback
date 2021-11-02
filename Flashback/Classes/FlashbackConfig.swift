//
//  FlashbackConfig.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

/// 配置
public struct FlashbackConfig {
    /// 返回模式
    public var backMode: BackMode = .normal
    /// 样式
    public var style: Style = .black
    /// 启用位置
    public var enablePositions: [Position] = [.left, .right]
    /// 触发范围
    public var triggerRange: CGFloat = 15
    /// 高度
    public var height: CGFloat = 320
    /// 返回所需最小宽度
    public var minWidth: CGFloat = 15
    /// 最大宽度
    public var maxWidth: CGFloat = 30
    /// 边缘曲率
    public var edgeCurvature: CGFloat = 100
    /// 中心曲率
    public var centerCurvature: CGFloat = 40
    /// 颜色
    public var color: UIColor = .black
    /// 透明度
    public var opacity: CGFloat = 1
    /// 指示器图片
    public var indicatorImage: UIImage = UIImage(named: "flashback_right_arrow")! {
        didSet {
            self.leftIndicatorImage = indicatorImage.withRenderingMode(.alwaysTemplate)
            self.rightIndicatorImage = UIImage(cgImage: self.indicatorImage.cgImage!, scale: 1, orientation: .upMirrored).withRenderingMode(.alwaysTemplate)
        }
    }
    /// 左边指示器图片
    public var leftIndicatorImage: UIImage = UIImage(named: "flashback_right_arrow")!.withRenderingMode(.alwaysTemplate)
    /// 右边指示器图片
    public var rightIndicatorImage: UIImage = UIImage(cgImage: UIImage(named: "flashback_right_arrow")!.cgImage!, scale: 1, orientation: .upMirrored).withRenderingMode(.alwaysTemplate)
    /// 指示器大小
    public var indicatorSize: CGSize = .init(width: 15, height: 15)
    /// 指示器颜色
    public var indicatorColor: UIColor = .white
    /// 消失持续时间
    public var dismissDuartion: CGFloat = 0.1
    /// 忽略顶部高度
    public var ignoreTopHeight: CGFloat = 150
    /// 震动开启
    public var vibrateEnable: Bool = true
    
    /// 默认配置
    public static var `default`: FlashbackConfig {
        let config = FlashbackConfig()
        return config
    }
    
    /// 返回位置
    public enum Position {
        /// 左边
        case left
        /// 右边
        case right
        
    }
    
    /// 样式
    public enum Style {
        /// 自动
        @available(iOS 12.0, *)
        case auto
        /// 白色
        case white
        /// 黑色
        case black
        /// 自定义
        case custom
        
        /// 模糊样式
        public var effectStyle: UIBlurEffect.Style {
            switch self {
            case .auto:
                return .regular
            case .white:
                return .light
            case .black:
                return .dark
            case .custom:
                return .regular
            }
        }
        
        /// 名称
        public var name: String {
            switch self {
            case .auto:
                return "自动"
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
    public enum BackMode {
        /// 通用
        case normal
        /// 通知 FlashbackNotificationName
        case notify
    }
}
