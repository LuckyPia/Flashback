# Flashback - iOS侧滑返回组件

[![iOS Version](https://img.shields.io/badge/iOS-10.0%2B-blueviolet)](https://cocoapods.org/pods/Flashback)
[![Language](https://img.shields.io/badge/language-swift-ff69b4)](https://cocoapods.org/pods/Flashback)
[![Flashback Version](https://img.shields.io/cocoapods/v/Flashback.svg?style=flat)](https://cocoapods.org/pods/Flashback)
[![License](https://img.shields.io/cocoapods/l/Flashback.svg?style=flat)](https://cocoapods.org/pods/Flashback)
[![Platform](https://img.shields.io/cocoapods/p/Flashback.svg?style=flat)](https://cocoapods.org/pods/Flashback)

## 效果图
<table>
    <tr>
        <td><img src="https://github.com/LuckyPia/Flashback/blob/master/IMG_1587.png" /></td>
        <td><img src="https://github.com/LuckyPia/Flashback/blob/master/IMG_1588.png" /></td>
    </tr>
</table>

## 前言

iOS的侧滑返回手势很难用有木有，而且只能从左侧返回，因为不是系统级别，也不是强制使用，还有很多App还不支持，只能羡慕Android的返回手势。为了解决该问题制作的该库，还是希望苹果有一天能够带来系统级别的返回手势。

## Demo

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Install

Flashback is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Flashback'
```

## Use

1. 启用（必要）

```swift
import Flashback

FlashbackManager.shared.isEnable = true


/// 禁用系统提供的手势返回
self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
```



2. 可配置

```swift
var config = FlashbackConfig.default
// 左右侧启用
config.enablePositions = [.left, .right]
// 触发范围
config.triggerRange = 20
// 震动启用
config.vibrateEnable = true
// 震动强度
config.vibrateStyle = .light
// 指示器样式
config.style = .custom
// 指示器背景颜色
config.color = .black
// 指示器图片颜色
config.indicatorColor = .yellow
// 上下滚动开启
config.scrollEnable = true
// 震动启用
config.vibrateEnable = true
// 震动强度
config.vibrateStyle = .light
// 忽略顶部高度(顶部不可侧滑返回)
config.ignoreTopHeight = 150
// ...
FlashbackManager.shared.config = config
```



3. 可重写返回逻辑

```swift
extension ViewController {
    /// 重写返回
    override func onFlashBack() {
        super.onFlashBack()
    }
}
```



4. 可自定义返回栈

```swift
FlashbackManager.shared.addFlahback(self) { [weak self] in
    guard let `self` = self else { return }
    self.navigationController?.popViewController(animated: true)
    return true
}
```

**注意**：仅在`backMode`为`normal`时有效，优先执行返回栈的内容，若`target`为`nil`，则会移除顶项，递归继续执行返回，闭包返回为`true`时执行完移除，为`false`不移除。



5. 可通知返回

```swift
// 设置返回模式为通知
FlashbackManager.shared.config.backMode = .notify

// 通知回调
NotificationCenter.default.addObserver(forName: FlashbackManager.FlashbackNotificationName, object: nil, queue: nil) { [weak self] _ in
    guard let `self` = self else { return }
    // 执行返回逻辑
    self.navigationController?.popViewController(animated: true)
}
```

## Existing problems

1. 左右两侧有一部分像素用于了侧滑返回，所以不可点击，可通过修改triggerRange来改变触发范围大小。

## Author

可通过邮件的方式联系我： 664454335@qq.com

## License

Flashback is available under the MIT license. See the LICENSE file for more info.
