//
//  FlashbackViewController.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/30.
//

import Foundation
import UIKit

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
        
        self.view.backgroundColor = .clear
        
        
        self.view.addSubview(self.backView)
        self.backView.translatesAutoresizingMaskIntoConstraints = false
        let constTop = NSLayoutConstraint(item: self.backView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let constRight = NSLayoutConstraint(item: self.backView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        let constLeft = NSLayoutConstraint(item: self.backView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let constBottom = NSLayoutConstraint(item: self.backView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.backView.superview!.addConstraint(constTop)
        self.backView.superview!.addConstraint(constRight)
        self.backView.superview!.addConstraint(constLeft)
        self.backView.superview!.addConstraint(constBottom)
    }
}
