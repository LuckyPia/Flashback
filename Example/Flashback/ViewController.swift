//
//  ViewController.swift
//  Flashback
//
//  Created by LuckyPia on 11/01/2021.
//  Copyright (c) 2021 LuckyPia. All rights reserved.
//

import Flashback
import UIKit

class ViewController: UIViewController {
    
    var textColor: UIColor = .black

    lazy var items: [ItemType] = {
        var list = ItemType.allCases
        return list
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = nil
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.register(DemoCell.self, forCellReuseIdentifier: "DemoCell")
        tableView.tableFooterView = UIView()
        return tableView
    }()

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入内容"
        textField.backgroundColor = .lightGray
        textField.layer.cornerRadius = 10
        return textField
    }()

    @available(iOS 15.0, *)
    lazy var newAppearance: UINavigationBarAppearance = {
        let newAppearance = UINavigationBarAppearance()
        newAppearance.configureWithOpaqueBackground()
        newAppearance.backgroundColor = .white
        newAppearance.shadowImage = UIImage()
        newAppearance.shadowColor = nil

        return newAppearance
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flashback"
        setNavigationBar(backgroundColor: .white, textColor: .black)

        makeUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch FlashbackManager.shared.config.style {
        case .black:
            setNavigationBar(backgroundColor: .white, textColor: .black)
        case .custom:
            setNavigationBar(backgroundColor: .white, textColor: .black)
        case .white:
            setNavigationBar(backgroundColor: .black, textColor: .white)
        }

        tableView.reloadData()
    }

    func makeUI() {
        /// 禁用系统提供的手势返回
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let constTop = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let constRight = NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let constLeft = NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let constBottom = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        tableView.superview!.addConstraint(constTop)
        tableView.superview!.addConstraint(constRight)
        tableView.superview!.addConstraint(constLeft)
        tableView.superview!.addConstraint(constBottom)
    }

    /// 设置主题色
    func setNavigationBar(backgroundColor: UIColor, textColor: UIColor) {
        self.textColor = textColor
        UIApplication.shared.statusBarStyle = textColor == .white ? .lightContent : .default
        tableView.separatorColor = textColor.withAlphaComponent(0.2)
        view.backgroundColor = backgroundColor
        navigationController?.navigationBar.backgroundColor = backgroundColor
        navigationController?.navigationBar.tintColor = textColor
        navigationController?.navigationBar.barTintColor = textColor
        if #available(iOS 15.0, *) {
            self.newAppearance.backgroundColor = backgroundColor
            self.newAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]
            self.navigationController?.navigationBar.standardAppearance = self.newAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.newAppearance
        }
    }

    /// 重写返回
    override func onFlashback() {
        super.onFlashback()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if FlashbackManager.shared.isEnable {
            return items.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell") as! DemoCell
        cell.backgroundColor = .clear
        let item = items[indexPath.row]
        cell.setData(itemType: item)
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = textColor
        cell.slider.isHidden = true
        switch item {
        case .triggerRange:
            cell.slider.isHidden = false
            cell.slider.minimumValue = 0
            cell.slider.maximumValue = 30
            cell.slider.value = Float(FlashbackManager.shared.config.triggerRange)
            cell.onValueChange = { value in
                FlashbackManager.shared.config.triggerRange = value
                FlashbackManager.shared.config = FlashbackManager.shared.config
            }
        case .backgroundOpacity:
            cell.slider.isHidden = false
            cell.slider.minimumValue = 0
            cell.slider.maximumValue = 1
            cell.slider.value = Float(FlashbackManager.shared.config.opacity)
            cell.onValueChange = { value in
                FlashbackManager.shared.config.opacity = value
                FlashbackManager.shared.config = FlashbackManager.shared.config
            }
        case .maxWidth:
            cell.slider.isHidden = false
            cell.slider.minimumValue = 25
            cell.slider.maximumValue = 60
            cell.slider.value = Float(FlashbackManager.shared.config.maxWidth)
            cell.onValueChange = { value in
                FlashbackManager.shared.config.maxWidth = value
                FlashbackManager.shared.config = FlashbackManager.shared.config
            }
        case .height:
            cell.slider.isHidden = false
            cell.slider.minimumValue = 30
            cell.slider.maximumValue = 500
            cell.slider.value = Float(FlashbackManager.shared.config.height)
            cell.onValueChange = { value in
                FlashbackManager.shared.config.height = value
                FlashbackManager.shared.config = FlashbackManager.shared.config
            }
        case .edgeCurvature:
            cell.slider.isHidden = false
            cell.slider.minimumValue = 5
            cell.slider.maximumValue = 200
            cell.slider.value = Float(FlashbackManager.shared.config.edgeCurvature)
            cell.onValueChange = { value in
                FlashbackManager.shared.config.edgeCurvature = value
                FlashbackManager.shared.config = FlashbackManager.shared.config
            }
        case .centerCurvature:
            cell.slider.isHidden = false
            cell.slider.minimumValue = 5
            cell.slider.maximumValue = 100
            cell.slider.value = Float(FlashbackManager.shared.config.centerCurvature)
            cell.onValueChange = { value in
                FlashbackManager.shared.config.centerCurvature = value
                FlashbackManager.shared.config = FlashbackManager.shared.config
            }
        case .ignoreTopHeight:
            cell.slider.isHidden = false
            cell.slider.minimumValue = 0
            cell.slider.maximumValue = 500
            cell.slider.value = Float(FlashbackManager.shared.config.ignoreTopHeight)
            cell.onValueChange = { value in
                FlashbackManager.shared.config.ignoreTopHeight = value
                FlashbackManager.shared.config = FlashbackManager.shared.config
            }
        default:
            break
        }
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item {
        case .enable:
            onEnable()
        case .style:
            onStyle()
        case .push:
            onPush()
        case .present:
            onPresent()
        case .intercept:
            onIntercept()
        case .vibrate:
            onVibrate()
        case .vibrateStyle:
            onVibrateStyle()
        case .leftPositionEnable:
            onPositionEnable(.left)
        case .rightPositionEnable:
            onPositionEnable(.right)
        case .scrollEnable:
            FlashbackManager.shared.config.scrollEnable = !FlashbackManager.shared.config.scrollEnable
        case .showTriggerArea:
            FlashbackManager.shared.config.showTriggerArea = !FlashbackManager.shared.config.showTriggerArea
        case .triggerRange, .backgroundOpacity, .maxWidth, .height, .edgeCurvature, .centerCurvature, .ignoreTopHeight:
            break
        case .reset:
            FlashbackManager.shared.config = FlashbackConfig.default
            FlashbackManager.shared.preFlashback = nil
        }
        FlashbackManager.shared.config = FlashbackManager.shared.config
        tableView.reloadData()
    }
}

extension ViewController {
    func onEnable() {
        FlashbackManager.shared.isEnable = !FlashbackManager.shared.isEnable
    }

    func onPush() {
        navigationController?.pushViewController(ViewController(), animated: true)
    }

    func onPresent() {
        present(UINavigationController(rootViewController: ViewController()), animated: true)
    }

    func onIntercept() {
        if FlashbackManager.shared.preFlashback != nil {
            FlashbackManager.shared.preFlashback = nil
        } else {
            FlashbackManager.shared.preFlashback = {
                if let alertVC = FlashbackManager.shared.currentVC() as? UIAlertController,
                   alertVC.title == "提示"
                {
                    return false
                }

                let alertVC = UIAlertController(title: "提示", message: "拦截返回成功", preferredStyle: .alert)
                let action = UIAlertAction(title: "确定", style: .default) { [weak alertVC] _ in
                    guard let alertVC = alertVC else { return }
                    alertVC.dismiss(animated: true)
                }
                alertVC.addAction(action)
                FlashbackManager.shared.currentVC()?.present(alertVC, animated: true)

                return false
            }
        }
    }

    func onVibrate() {
        FlashbackManager.shared.config.vibrateEnable = !FlashbackManager.shared.config.vibrateEnable
    }

    func onPositionEnable(_ position: FlashbackConfig.Position) {
        var enablePositions = FlashbackManager.shared.config.enablePositions
        if enablePositions.contains(position) {
            enablePositions = enablePositions.filter { $0 != position }
        } else {
            enablePositions.append(position)
        }
        FlashbackManager.shared.config.enablePositions = enablePositions
    }

    func onStyle() {
        let alertVC = UIAlertController(title: "指示器样式", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "white", style: FlashbackManager.shared.config.style == .white ? .destructive : .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.setNavigationBar(backgroundColor: .black, textColor: .white)
            FlashbackManager.shared.config.style = .white
            FlashbackManager.shared.config = FlashbackManager.shared.config
            self.tableView.reloadData()
        }
        alertVC.addAction(action1)
        let action2 = UIAlertAction(title: "black", style: FlashbackManager.shared.config.style == .black ? .destructive : .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.setNavigationBar(backgroundColor: .white, textColor: .black)
            FlashbackManager.shared.config.style = .black
            FlashbackManager.shared.config = FlashbackManager.shared.config
            self.tableView.reloadData()
        }
        alertVC.addAction(action2)
        let action3 = UIAlertAction(title: "custom", style: FlashbackManager.shared.config.style == .custom ? .destructive : .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.setNavigationBar(backgroundColor: .white, textColor: .black)
            FlashbackManager.shared.config.style = .custom
            FlashbackManager.shared.config.indicatorColor = .yellow
            FlashbackManager.shared.config.backgroundColor = .black
            FlashbackManager.shared.config = FlashbackManager.shared.config
            self.tableView.reloadData()
        }
        alertVC.addAction(action3)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true)
    }

    func onVibrateStyle() {
        let alertVC = UIAlertController(title: "震动样式", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "light", style: FlashbackManager.shared.config.vibrateStyle == .light ? .destructive : .default) { [weak self] _ in
            guard let `self` = self else { return }
            FlashbackManager.shared.config.vibrateStyle = .light
            FlashbackManager.shared.config = FlashbackManager.shared.config
            self.tableView.reloadData()
        }
        alertVC.addAction(action1)
        let action2 = UIAlertAction(title: "medium", style: FlashbackManager.shared.config.vibrateStyle == .medium ? .destructive : .default) { [weak self] _ in
            guard let `self` = self else { return }
            FlashbackManager.shared.config.vibrateStyle = .medium
            FlashbackManager.shared.config = FlashbackManager.shared.config
            self.tableView.reloadData()
        }
        alertVC.addAction(action2)
        if #available(iOS 13.0, *) {
            let action3 = UIAlertAction(title: "soft", style: FlashbackManager.shared.config.vibrateStyle == .soft ? .destructive : .default) { [weak self] _ in
                guard let `self` = self else { return }
                FlashbackManager.shared.config.vibrateStyle = .soft
                FlashbackManager.shared.config = FlashbackManager.shared.config
                self.tableView.reloadData()
            }
            alertVC.addAction(action3)
            let action4 = UIAlertAction(title: "rigid", style: FlashbackManager.shared.config.vibrateStyle == .rigid ? .destructive : .default) { [weak self] _ in
                guard let `self` = self else { return }
                FlashbackManager.shared.config.vibrateStyle = .rigid
                FlashbackManager.shared.config = FlashbackManager.shared.config
                self.tableView.reloadData()
            }
            alertVC.addAction(action4)
        }
        let action5 = UIAlertAction(title: "heavy", style: FlashbackManager.shared.config.vibrateStyle == .heavy ? .destructive : .default) { [weak self] _ in
            guard let `self` = self else { return }
            FlashbackManager.shared.config.vibrateStyle = .heavy
            FlashbackManager.shared.config = FlashbackManager.shared.config
            self.tableView.reloadData()
        }
        alertVC.addAction(action5)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true)
    }
}

enum ItemType: CaseIterable {
    /// 启用
    case enable
    /// push
    case push
    /// present
    case present
    /// 样式
    case style
    /// 震动
    case vibrate
    /// 震动强度
    case vibrateStyle
    /// 左侧启用
    case leftPositionEnable
    /// 右侧启用
    case rightPositionEnable
    /// 拦截
    case intercept
    /// 可滑动
    case scrollEnable
    /// 显示触发区域
    case showTriggerArea
    /// 触发范围
    case triggerRange
    /// 背景透明度
    case backgroundOpacity
    /// 最大宽度
    case maxWidth
    /// 高度
    case height
    /// 边缘曲率
    case edgeCurvature
    /// 中心曲率
    case centerCurvature
    /// 忽略顶部高度
    case ignoreTopHeight
    /// 重置
    case reset

    var title: String {
        switch self {
        case .enable:
            return "启用(\(FlashbackManager.shared.isEnable ? "开" : "关"))"
        case .style:
            return "样式(\(FlashbackManager.shared.config.style.name))"
        case .push:
            return "Push"
        case .present:
            return "Present"
        case .intercept:
            return "拦截返回（\(FlashbackManager.shared.preFlashback != nil ? "开" : "关")）"
        case .vibrate:
            return "震动（\(FlashbackManager.shared.config.vibrateEnable ? "开" : "关")）"
        case .vibrateStyle:
            var name = "unknown"
            switch FlashbackManager.shared.config.vibrateStyle {
            case .light: name = "light"
            case .soft: name = "soft"
            case .rigid: name = "rigid"
            case .heavy: name = "heavy"
            case .medium: name = "medium"
            @unknown default: name = "unknown"
            }
            return "震动强度（\(name)）"
        case .leftPositionEnable:
            return "左侧启用（\(FlashbackManager.shared.config.enablePositions.contains(.left) ? "开" : "关")）"
        case .rightPositionEnable:
            return "右侧启用（\(FlashbackManager.shared.config.enablePositions.contains(.right) ? "开" : "关")）"
        case .scrollEnable:
            return "可滑动（\(FlashbackManager.shared.config.scrollEnable ? "开" : "关")）"
        case .showTriggerArea:
            return "显示触发范围（\(FlashbackManager.shared.config.showTriggerArea ? "开" : "关")）"
        case .triggerRange:
            return "触发范围（\(String(format: "%.2f", FlashbackManager.shared.config.triggerRange))）"
        case .backgroundOpacity:
            return "背景透明度（\(String(format: "%.2f", FlashbackManager.shared.config.opacity))）"
        case .maxWidth:
            return "宽度（\(String(format: "%.2f", FlashbackManager.shared.config.maxWidth))）"
        case .height:
            return "高度（\(String(format: "%.2f", FlashbackManager.shared.config.height))）"
        case .edgeCurvature:
            return "边缘曲率（\(String(format: "%.2f", FlashbackManager.shared.config.edgeCurvature))）"
        case .centerCurvature:
            return "中心曲率（\(String(format: "%.2f", FlashbackManager.shared.config.centerCurvature))）"
        case .ignoreTopHeight:
            return "忽略顶部高度（\(String(format: "%.2f", FlashbackManager.shared.config.ignoreTopHeight))）"
        case .reset:
            return "重置"
        }
    }
}
