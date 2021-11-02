//
//  FlashbackView.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit
import AudioToolbox

class FlashbackView: UIView {
    
    typealias Position = FlashbackConfig.Position
    
    /// 返回配置
    var config: FlashbackConfig = .default {
        didSet {
            reinitIndicator()
        }
    }
    
    /// 拖拽开始位置
    var startPosition: Position = .left
    
    /// 拖拽开始y轴
    var startY: CGFloat = 0
    
    /// 拖拽X轴偏移
    var offsetX: CGFloat = 0 {
        didSet {
            self.indicatorWidth = min(config.maxWidth, config.maxWidth * abs(offsetX) / 120)
        }
    }
    
    /// 指示器宽度
    var indicatorWidth: CGFloat = 0 {
        didSet {
            self.setImageView()
            self.drag(width: indicatorWidth)
            // 震动
            if config.vibrateEnable && oldValue < config.minWidth && indicatorWidth >= config.minWidth {
                AudioServicesPlayAlertSound(SystemSoundID(1519))
            }
        }
    }
    
    /// 动画
    var displayLink: CADisplayLink?
    
    /// 每帧减去的宽度
    var frameReduceWidth: CGFloat = 0
    
    deinit {
        self.releaseDisplayLink()
    }
    
    lazy var swipe: UIPanGestureRecognizer = {
        let swipe = UIPanGestureRecognizer.init(target: self, action: #selector(swipe(_:)))
        swipe.minimumNumberOfTouches = 1
        swipe.maximumNumberOfTouches = 1
        return swipe
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 毛玻璃视图
    lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: config.style.effectStyle))
        return  view
    }()
    
    lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.white.cgColor
        return shapeLayer
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.frame = CGRect.init(origin: .zero, size: config.indicatorSize)
        view.isHidden = true
        return view
    }()
    
    lazy var testView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        isUserInteractionEnabled = true
        addSubview(contentView)
        contentView.addSubview(blurView)
        contentView.addSubview(imageView)
        addGestureRecognizer(swipe)
        contentView.layer.mask = shapeLayer
        reinitIndicator()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.bounds
        self.blurView.frame = self.bounds
    }
    
    /// 设置指示器背景
    func reinitIndicator() {
        switch self.config.style {
        case .auto:
            if #available(iOS 12.0, *) {
                switch self.traitCollection.userInterfaceStyle {
                case .light:
                    self.imageView.tintColor = .black
                    self.blurView.effect = UIBlurEffect(style: .light)
                case .dark:
                    self.imageView.tintColor = .white
                    self.blurView.effect = UIBlurEffect(style: .dark)
                default:
                    self.imageView.tintColor = .white
                    self.blurView.effect = UIBlurEffect(style: .dark)
                }
            } else {
                self.imageView.tintColor = .white
                self.blurView.effect = UIBlurEffect(style: .dark)
            }
            self.blurView.isHidden = false
            self.contentView.backgroundColor = .clear
        case .white:
            self.imageView.tintColor = .black
            self.contentView.backgroundColor = .clear
            self.blurView.isHidden = false
            self.blurView.effect = UIBlurEffect(style: config.style.effectStyle)
        case .black:
            self.imageView.tintColor = .white
            self.contentView.backgroundColor = .clear
            self.blurView.isHidden = false
            self.blurView.effect = UIBlurEffect(style: config.style.effectStyle)
        case .custom:
            self.imageView.tintColor = config.indicatorColor
            self.contentView.backgroundColor = config.color.withAlphaComponent(config.opacity)
            self.blurView.isHidden = true
        }
        
    }
    
    /// 设置指示器图标
    func setImageView() {
        if self.indicatorWidth > config.minWidth {
            self.imageView.isHidden = false
            let x: CGFloat = self.startPosition == .left ? (self.indicatorWidth / 2) : (self.bounds.width - (self.indicatorWidth / 2))
            self.imageView.center = CGPoint(x: x, y: self.startY)
        }else {
            self.imageView.isHidden = true
        }
    }
    
    /// 手势回调
    @objc func swipe(_ panGes: UIPanGestureRecognizer) {
        let offsetX = panGes.translation(in: self).x
        switch panGes.state {
        case .began:
            self.releaseDisplayLink()
            let locationPoint = panGes.location(in: panGes.view)
            if locationPoint.x < self.bounds.width / 2 {
                self.startY = locationPoint.y
                self.startPosition = .left
                self.imageView.image = config.leftIndicatorImage
            }
            if locationPoint.x > self.bounds.width / 2 {
                self.startY = locationPoint.y
                self.startPosition = .right
                self.imageView.image = config.rightIndicatorImage
            }
        case .cancelled, .ended, .failed:
            // 是否需要返回
            self.needBack()
            
            // 指示器消失动画
            self.releaseDisplayLink()
            self.frameReduceWidth = self.indicatorWidth / (60 * config.dismissDuartion)
            displayLink = CADisplayLink(target: self, selector: #selector(cancelDrag))
            displayLink?.preferredFramesPerSecond = 60
            displayLink?.isPaused = false
            displayLink?.add(to: .current, forMode: .common)
        default:
            self.offsetX = offsetX
        }
        
    }
    
    /// 拖拽
    func drag(width: CGFloat) {
        let path = UIBezierPath()
        
        var startPoint :CGPoint
        var centerPoint :CGPoint
        var endPoint :CGPoint
        
        var controlPoint1: CGPoint
        var controlPoint2: CGPoint
        var controlPoint3: CGPoint
        var controlPoint4: CGPoint
        if startPosition == .left {
            startPoint = CGPoint(x: 0, y: startY - config.height / 2)
            centerPoint = CGPoint(x: 0 + width, y: startY)
            endPoint = CGPoint(x: 0, y: startY + config.height / 2)
            
            controlPoint1 = CGPoint(x: 0, y: startPoint.y + config.edgeCurvature)
            controlPoint2 = CGPoint(x: 0 + width, y: centerPoint.y - config.centerCurvature)
            controlPoint3 = CGPoint(x: 0 + width, y: centerPoint.y + config.centerCurvature)
            controlPoint4 = CGPoint(x: 0, y: endPoint.y - config.edgeCurvature)
        }else {
            startPoint = CGPoint(x: bounds.width, y: startY - config.height / 2)
            centerPoint = CGPoint(x: bounds.width - width, y: startY)
            endPoint = CGPoint(x: bounds.width, y: startY + config.height / 2)
            
            controlPoint1 = CGPoint(x: bounds.width, y: startPoint.y + config.edgeCurvature)
            controlPoint2 = CGPoint(x: bounds.width - width, y: centerPoint.y - config.centerCurvature)
            controlPoint3 = CGPoint(x: bounds.width - width, y: centerPoint.y + config.centerCurvature)
            controlPoint4 = CGPoint(x: bounds.width, y: endPoint.y - config.edgeCurvature)
        }
        
        path.move(to: startPoint)
        path.addCurve(to: centerPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        path.addCurve(to: endPoint, controlPoint1: controlPoint3, controlPoint2: controlPoint4)
        path.move(to: endPoint)
        
        shapeLayer.path = path.cgPath
    }
    
    /// 取消拖拽
    @objc func cancelDrag() {
        self.indicatorWidth -= self.frameReduceWidth
        if self.indicatorWidth <= 0 {
            self.releaseDisplayLink()
        }
    }
    
    /// 释放动画
    func releaseDisplayLink() {
        if displayLink != nil {
            self.displayLink?.isPaused = true
            self.displayLink?.invalidate()
            self.displayLink = nil
        }
    }
    
    /// 判断是否需要返回
    func needBack() {
        if self.indicatorWidth >= config.minWidth {
            // 震动
            if config.vibrateEnable {
                AudioServicesPlayAlertSound(SystemSoundID(1520))
            }
            doBack()
        }
    }
    
    /// 执行返回逻辑
    func doBack() {
        FlashbackManager.shared.doBack()
    }
}
