//
//  FlashbackView.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/28.
//

import UIKit

// MARK: 闪回视图

/// 闪回视图
class FlashbackView: UIView {
    typealias Position = FlashbackConfig.Position

    /// 返回配置
    var config: FlashbackConfig = .default {
        didSet {
            reinitIndicator()
            setShowTriggerArea()
        }
    }

    /// 拖拽开始位置
    var startPosition: Position = .left

    /// 拖拽开始y轴
    var startY: CGFloat = 0

    /// 开始震动时间，时间太短没有结束震动
    var startVibrateTimeInterval: TimeInterval = 0

    /// 拖拽X轴偏移
    var offsetX: CGFloat = 0 {
        didSet {
            indicatorWidth = min(config.maxWidth, config.maxWidth * abs(offsetX) / config.dragRange)
        }
    }

    /// 指示器宽度
    var indicatorWidth: CGFloat = 0 {
        didSet {
            setImageView()
            drawCurve()
            // 震动
            if config.vibrateEnable && oldValue < config.minWidth && indicatorWidth >= config.minWidth {
                UIImpactFeedbackGenerator(style: config.vibrateStyle).impactOccurred()
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

    /// 拖动手势
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        return panGesture
    }()

    /// 内容视图
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    /// 毛玻璃视图
    lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: config.blurStyle))
        return view
    }()

    /// 形状
    lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.white.cgColor
        return shapeLayer
    }()

    /// 指示器图片
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.frame = CGRect(origin: .zero, size: config.indicatorSize)
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    /// 触发区域视图
    lazy var triggerAreaShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.red.withAlphaComponent(0.2).cgColor
        shapeLayer.fillRule = .evenOdd
        return shapeLayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeUI() {
        isUserInteractionEnabled = true

        addSubview(contentView)
        contentView.addSubview(blurView)
        contentView.addSubview(imageView)
        addGestureRecognizer(panGesture)
        contentView.layer.mask = shapeLayer
        reinitIndicator()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        blurView.frame = bounds

        setShowTriggerArea()
    }

    /// 设置指示器
    func reinitIndicator() {
        switch config.style {
        case .white:
            contentView.backgroundColor = .white.withAlphaComponent(config.opacity)
            imageView.tintColor = .black
        case .black:
            contentView.backgroundColor = .black.withAlphaComponent(config.opacity)
            imageView.tintColor = .white
        case .custom:
            contentView.backgroundColor = config.backgroundColor.withAlphaComponent(config.opacity)
            imageView.tintColor = config.indicatorColor
        }

        if config.isBlur {
            blurView.isHidden = false
            blurView.effect = UIBlurEffect(style: config.blurStyle)
        } else {
            blurView.isHidden = true
        }
    }

    /// 显示触发区域
    func setShowTriggerArea() {
        let ignoreTopHeight = FlashbackManager.shared.isPortrait ? config.ignoreTopHeight : 0
        let leftPath = UIBezierPath(rect: CGRect(x: 0, y: ignoreTopHeight, width: config.triggerRange, height: bounds.size.height - ignoreTopHeight))
        let rightPath = UIBezierPath(rect: CGRect(x: bounds.size.width - config.triggerRange, y: ignoreTopHeight, width: config.triggerRange, height: bounds.size.height - ignoreTopHeight))
        let path = UIBezierPath()
        path.append(leftPath)
        path.append(rightPath)
        triggerAreaShapeLayer.path = path.cgPath
        if config.showTriggerArea {
            if triggerAreaShapeLayer.superlayer == nil {
                layer.addSublayer(triggerAreaShapeLayer)
            }
        } else {
            if triggerAreaShapeLayer.superlayer != nil {
                triggerAreaShapeLayer.removeFromSuperlayer()
            }
        }
    }

    /// 设置指示器图标
    func setImageView() {
        if indicatorWidth > config.minWidth {
            imageView.isHidden = false
            let x: CGFloat = startPosition == .left ? (indicatorWidth / 2) : (bounds.width - (indicatorWidth / 2))
            imageView.center = CGPoint(x: x, y: startY)
        } else {
            imageView.isHidden = true
        }
    }

    /// 手势回调
    @objc func pan(_ panGes: UIPanGestureRecognizer) {
        let offsetX = panGes.translation(in: self).x
        switch panGes.state {
        case .began:
            startVibrateTimeInterval = Date().timeIntervalSince1970
            releaseDisplayLink()
            let locationPoint = panGes.location(in: panGes.view)
            if locationPoint.x < bounds.width / 2 {
                startY = locationPoint.y
                startPosition = .left
                imageView.image = config.leftIndicatorImage
            }
            if locationPoint.x > bounds.width / 2 {
                startY = locationPoint.y
                startPosition = .right
                imageView.image = config.rightIndicatorImage
            }
        case .cancelled, .ended, .failed:
            // 是否需要返回
            needBack()

            // 指示器消失动画
            releaseDisplayLink()
            frameReduceWidth = indicatorWidth / (60 * config.dismissDuartion)
            displayLink = CADisplayLink(target: self, selector: #selector(cancelDrag))
            displayLink?.preferredFramesPerSecond = 60
            displayLink?.isPaused = false
            displayLink?.add(to: .current, forMode: .common)
        default:
            if startPosition == .left {
                self.offsetX = max(0, offsetX)
            } else {
                self.offsetX = min(0, offsetX)
            }
            // 上下滚动可用
            if config.scrollEnable {
                let locationPoint = panGes.location(in: panGes.view)
                startY = locationPoint.y
            }
        }
    }

    /// 绘制曲线
    func drawCurve() {
        let path = UIBezierPath()

        var startPoint: CGPoint
        var centerPoint: CGPoint
        var endPoint: CGPoint

        var controlPoint1: CGPoint
        var controlPoint2: CGPoint
        var controlPoint3: CGPoint
        var controlPoint4: CGPoint
        if startPosition == .left {
            startPoint = CGPoint(x: 0, y: startY - config.height / 2)
            centerPoint = CGPoint(x: 0 + indicatorWidth, y: startY)
            endPoint = CGPoint(x: 0, y: startY + config.height / 2)

            controlPoint1 = CGPoint(x: 0, y: startPoint.y + config.edgeCurvature)
            controlPoint2 = CGPoint(x: 0 + indicatorWidth, y: centerPoint.y - config.centerCurvature)
            controlPoint3 = CGPoint(x: 0 + indicatorWidth, y: centerPoint.y + config.centerCurvature)
            controlPoint4 = CGPoint(x: 0, y: endPoint.y - config.edgeCurvature)
        } else {
            startPoint = CGPoint(x: bounds.width, y: startY - config.height / 2)
            centerPoint = CGPoint(x: bounds.width - indicatorWidth, y: startY)
            endPoint = CGPoint(x: bounds.width, y: startY + config.height / 2)

            controlPoint1 = CGPoint(x: bounds.width, y: startPoint.y + config.edgeCurvature)
            controlPoint2 = CGPoint(x: bounds.width - indicatorWidth, y: centerPoint.y - config.centerCurvature)
            controlPoint3 = CGPoint(x: bounds.width - indicatorWidth, y: centerPoint.y + config.centerCurvature)
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
        indicatorWidth -= frameReduceWidth
        if indicatorWidth <= 0 {
            releaseDisplayLink()
        }
    }

    /// 释放动画
    func releaseDisplayLink() {
        if displayLink != nil {
            displayLink?.isPaused = true
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    /// 判断是否需要返回
    func needBack() {
        // 大于最小宽度，才执行返回
        if indicatorWidth >= config.minWidth {
            // 震动，从开始间隔大于0.15秒才有结束震动
            if config.vibrateEnable &&
                Date().timeIntervalSince1970 - startVibrateTimeInterval > 0.15
            {
                UIImpactFeedbackGenerator(style: config.vibrateStyle).impactOccurred()
            }
            doBack()
        }
    }

    /// 执行返回逻辑
    func doBack() {
        FlashbackManager.shared.doBack()
    }
}
