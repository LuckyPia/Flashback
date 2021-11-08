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
    lazy var items: [ItemType] = {
        var list = ItemType.allCases
        if self.presentingViewController != nil {
            list.removeFirst()
        }
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DemoCell")
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flashback"
        view.backgroundColor = .white
        makeUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    @objc func onPush() {
        navigationController?.pushViewController(ViewController(), animated: true)
    }

    @objc func onPresent() {
        present(ViewController(), animated: true)
    }

    @objc func onVibrate() {
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
        switch FlashbackManager.shared.config.style {
        case .white:
            FlashbackManager.shared.config.style = .black
        case .black:
            FlashbackManager.shared.config.style = .custom
        case .custom:
            FlashbackManager.shared.config.style = .white
        }
    }

    func onVibrateStyle() {
        switch FlashbackManager.shared.config.vibrateStyle {
        case .light:
            if #available(iOS 13.0, *) {
                FlashbackManager.shared.config.vibrateStyle = .soft
            } else {
                FlashbackManager.shared.config.vibrateStyle = .heavy
            }
        case .soft:
            if #available(iOS 13.0, *) {
                FlashbackManager.shared.config.vibrateStyle = .rigid
            } else {
                FlashbackManager.shared.config.vibrateStyle = .heavy
            }
        case .rigid:
            FlashbackManager.shared.config.vibrateStyle = .heavy
        case .heavy:
            FlashbackManager.shared.config.vibrateStyle = .medium
        case .medium:
            FlashbackManager.shared.config.vibrateStyle = .light
        @unknown default:
            FlashbackManager.shared.config.vibrateStyle = .light
        }
    }

    /// 重写返回
    override func onFlashback() {
        super.onFlashback()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell")!
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item {
        case .style:
            onStyle()
        case .push:
            onPush()
        case .present:
            onPresent()
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
        }
        tableView.reloadData()
    }
}

enum ItemType: CaseIterable {
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
    /// 可滑动
    case scrollEnable

    var title: String {
        switch self {
        case .style:
            return "样式(\(FlashbackManager.shared.config.style.name))"
        case .push:
            return "Push"
        case .present:
            return "Present"
        case .vibrate:
            return "震动（\(FlashbackManager.shared.config.vibrateEnable ? "开" : "关")）"
        case .vibrateStyle:
            var name = "unknown"
            switch FlashbackManager.shared.config.vibrateStyle {
            case .light:
                name = "light"
            case .soft:
                name = "soft"
            case .rigid:
                name = "rigid"
            case .heavy:
                name = "heavy"
            case .medium:
                name = "medium"
            @unknown default:
                name = "unknown"
            }
            return "震动强度（\(name)）"
        case .leftPositionEnable:
            return "左侧启用（\(FlashbackManager.shared.config.enablePositions.contains(.left) ? "开" : "关")）"
        case .rightPositionEnable:
            return "右侧启用（\(FlashbackManager.shared.config.enablePositions.contains(.right) ? "开" : "关")）"
        case .scrollEnable:
            return "可滑动（\(FlashbackManager.shared.config.scrollEnable ? "开" : "关")）"
        }
    }
}
