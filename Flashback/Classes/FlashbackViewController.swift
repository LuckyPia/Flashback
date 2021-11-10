//
//  FlashbackViewController.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/30.
//

import UIKit

// MARK: 闪回控制器

/// 闪回控制器
class FlashbackViewController: UIViewController {
    /// 配置
    var config: FlashbackConfig = .default {
        didSet {
            self.backView.config = config
        }
    }

    /// 返回视图
    lazy var backView: FlashbackView = {
        let backView = FlashbackView()
        return backView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        view.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        let constTop = NSLayoutConstraint(item: backView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let constRight = NSLayoutConstraint(item: backView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let constLeft = NSLayoutConstraint(item: backView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let constBottom = NSLayoutConstraint(item: backView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        backView.superview!.addConstraint(constTop)
        backView.superview!.addConstraint(constRight)
        backView.superview!.addConstraint(constLeft)
        backView.superview!.addConstraint(constBottom)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            let orient = UIApplication.shared.statusBarOrientation
            if orient.isPortrait {
                FlashbackManager.shared.isPortrait = true
            } else if orient.isLandscape {
                FlashbackManager.shared.isPortrait = false
            }
        }) { _ in
        }
        super.willTransition(to: newCollection, with: coordinator)
    }
}
