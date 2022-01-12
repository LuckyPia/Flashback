//
//  DemoCell.swift
//  Flashback_Example
//
//  Created by yupao_ios_macmini05 on 2021/11/13.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import Flashback

class DemoCell: UITableViewCell {
    
    /// item类型
    var itemType: ItemType = .push
    
    /// 值改变回调
    var onValueChange: ((CGFloat) -> Void)?
    
    /// 滑块
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(valueChange), for: .valueChanged)
        slider.isHidden = true
        return slider
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        self.accessoryView = slider
    }
    
    /// 设置数据
    func setData(itemType: ItemType) {
        self.itemType = itemType
    }
    
    /// 同步数据
    func syncData() {
        self.textLabel?.text = self.itemType.title
    }
}

extension DemoCell {
    /// 值改变
    @objc func valueChange(_ sender: UISlider) {
        self.syncData()
        self.onValueChange?(CGFloat(sender.value))
    }
}
