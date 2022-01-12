# Flashback - 超好用第三方的iOS手势返回
[![iOS Version](https://img.shields.io/badge/iOS-10.0%2B-blueviolet)](https://cocoapods.org/pods/Flashback)
[![Language](https://img.shields.io/badge/swift-5.0-ff501e)](https://cocoapods.org/pods/Flashback)
[![Flashback Version](https://img.shields.io/cocoapods/v/Flashback.svg?style=flat)](https://cocoapods.org/pods/Flashback)
[![License](https://img.shields.io/cocoapods/l/Flashback.svg?style=flat)](https://cocoapods.org/pods/Flashback)

## 效果图

<table>
    <tr>
        <td><img src="./Images/IMG_1595.jpg" /></td>
        <td><img src="./Images/IMG_1596.jpg" /></td>
    </tr>
</table>

## 前言
iOS自带的手势返回因为不是系统级别，也没有强制App使用，而且仅左侧可用，还有很多App不支持，导致了iOS App返回乱象。该库正是为了解决该问题而制作的，**支持全局返回，无论你是present出来的VC，还是各种各样的弹窗，都能返回**，让您的App一路顺滑返回到底。

## Demo例子
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Install安装
Flashback is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Flashback'
```

## Get start使用
1. 启用
```swift
import Flashback

// 禁用系统提供的手势返回
navigationController?.interactivePopGestureRecognizer?.isEnabled = false

// 启用闪回（必要）
FlashbackManager.shared.isEnable = true

// 以上功能仅在普通页面可返回，present出来UIViewController或在window上增加视图，都会导致手势返回无法使用，如果想获取更完整的返回体验，有两种方式。
// 1. 在AppDelegate中使用FlashbackWindow辅助将返回视图提到最上层
self.window = FlashbackWindow(frame: UIScreen.main.bounds.size)
// 2. 使用RxSwift扩展UIWindow的addSubview方法
FlashbackManager.shared.targetWindow?.rx.methodInvoked(#selector(UIWindow.addSubview(_:))).subscribe (onNext: { _ in
    FlashbackManager.shared.makeFlashbackToTop()
}).disposed(by: UIApplication.shared.rx.disposeBag)

```

2. 可配置
```swift
let config = FlashbackConfig.default
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
config.backgroundColor = .black
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
// 扩展普通VC
class TestViewController {

    // 省略不重要代码...
    
    /// 重写返回
    override func onFlashback() {
        // super.onFlashback()
        self.view.endEditing(true)
    }
}

// 扩展VC弹窗手势返回
extension AlertViewController {
    /// 弹窗闪回扩展
    open func onFlashback() {
        self.dismiss()
    }
}
```

4. 某些情况下禁用手势返回
```swift
FlashbackManager.shared.enable = {
    if let currentVC = FlashbackManager.shared.currentVC(FlashbackManager.shared.targetWindow) {
        if currentVC is RwaTestViewController {
            return false
        }
    }
    return true
}
```

5. 可前置处理（统一处理弹窗，减少代码侵入）
```swift
// 举例：判断VC上的视图是否满足某个协议，若满足，则执行其返回方法
// 不是一定要满足FlashbackProtocol协议，你可以选择自己的协议，更好的减少代码侵入
FlashbackManager.shared.preFlashback = { targetWindow, currentVC in
    // 返回true继续向下执行正常逻辑，返回false终止
    if let alertList = currentVC?.view.subviews.filter({ $0 is FlashbackProtocol }),
        let lastAlert = alertList.last as? FlashbackProtocol {
        lastAlert.onFlashback()
        // 返回false不再继续往下执行
        return false
    }
    // ...
    
    // 返回true继续正常执行
    return true
}

// 扩展View弹窗
extension AlertView: FlashbackProtocol {
    /// 弹窗闪回扩展
    open func onFlashback() {
        self.dismiss()
    }
}

```

6. 可通知返回，您可以全权接管返回逻辑
```swift
// 设置返回模式为通知
FlashbackManager.shared.config.backMode = .notify

// 通知回调
NotificationCenter.default.addObserver(forName: FlashbackManager.FlashbackNotificationName, object: nil, queue: nil) { [weak self] _ in
    guard let `self` = self else { return }
    // 执行返回逻辑
    // self.navigationController?.popViewController(animated: true)
}
```

**注意说明**：
- 在`backMode`为`normal`时，执行顺序为：`键盘收回` -> `preFlashback` -> `onFlashback`

## Update log更新日志

### 2.0.0
1. 解决手势返回时keyWindow变成手势返回的window
    移除通过添加window的方式添加手势返回，虽然通过此方式保持手势返回在最上层，但在iOS14以上的机型上返回操作时，会导致keyWindow变成手势返回的window，从而导致一系列的问题。
2. 移除自定义返回栈
3. 解决手势返回时还能操纵页面元素的bug
4. 手势返回时优先自动收回键盘
5. 增加某些情况禁用手势Flashback功能

### 1.3.5
1. 优化闪回配置

### 1.3.4
1. 单词拼写纠错

### 1.3.3
1. 优化回调方法，提高性能

### 1.3.2
1. 移除毛玻璃模糊效果，提高性能

### 1.3.1
1. 增加键盘弹出监听，您可以选择在返回之前先退出键盘
2. 优化代码

### 1.3.0
1. 暴露获取当前控制器方法，可自定义实现
2. 暴露控制器返回动作，可自定义实现

## Existing problems存在问题
1. 左右两侧有一部分像素用于了侧滑返回判断，所以不可使用，可通过修改triggerRange来改变触发范围大小。

## 其他手势返回
```swift
pod 'FDFullscreenPopGesture' # https://github.com/forkingdog/FDFullscreenPopGesture
pod 'TZScrollViewPopGesture' # https://github.com/banchichen/TZScrollViewPopGesture
```
- FDFullscreenPopGesture 为每个UIViewController添加【全屏滑动返回】，但遇到UIScrollView就无效了
- TZScrollViewPopGesture 主要是实现【边缘滑动返回】功能，不过这个是次要，主要是，它提供了给UIScrollView添加【边缘滑动返回】的功能。
这俩不会互相影响，功能互补。他们有交互式视觉差的返回效果，但他们的弱点很明显，只能控制UINavigationController中的UIViewController返回，无法控制其他（模态present出的VC，弹窗等）返回，无法从右侧向左滑返回，可与Flashback一起使用。
> 参考文章： [https://www.jianshu.com/p/0c698f71c49a?ivk_sa=1024320u](https://www.jianshu.com/p/0c698f71c49a?ivk_sa=1024320u)

## Contact me联系我
可通过邮件的方式联系我： 664454335@qq.com

## License许可证
Flashback is available under the MIT license. See the LICENSE file for more info.
