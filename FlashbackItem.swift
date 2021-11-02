//
//  FlashbackItem.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/29.
//

// MARK: 返回项
public class FlashbackItem: NSObject {
    
    public typealias BackAction = () -> Void
    
    /// 目标
    public var target: Any?
    
    /// 返回回调
    public var action: BackAction
    
    public init(target: Any?, action: @escaping BackAction) {
        self.target = target
        self.action = action
    }
}
