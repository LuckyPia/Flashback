//
//  FlashbackItem.swift
//  Flashback
//
//  Created by LuckyPia on 2021/10/29.
//

// MARK: 闪回回调项
/// 闪回回调项
public struct FlashbackItem<T: AnyObject> {
    
    public typealias BackAction = () -> Bool
    
    /// 目标
    public weak var target: T?
    
    /// 返回回调
    public let action: BackAction
    
}
