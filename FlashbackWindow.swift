//
//  FlashbackWindow.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/29.
//

import UIKit

class FlashbackWindow: UIWindow {
    
    /// 配置
    var config: FlashbackConfig = .default {
        didSet {
            self.backView.config = config
        }
    }
    
    /// 返回视图
    lazy var backView: FlashbackView = {
        let backView = FlashbackView()
        backView.frame = UIScreen.main.bounds
        return backView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        windowLevel = UIWindow.Level.alert + 1
        window?.backgroundColor = .clear
        
        addSubview(backView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
