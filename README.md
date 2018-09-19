# SWindow

<p align="center">
    <a href="https://raw.githubusercontent.com/shial4/SWindow/master/LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License" />
    </a>
    <a href="https://travis-ci.org/shial4/SWindow">
        <img src="https://travis-ci.org/shial4/SWindow.svg?branch=master" alt="TravisCI" />
    </a>
    <a href="https://cocoapods.org/pods/SWindow">
        <img src="https://img.shields.io/cocoapods/v/SWindow.svg" alt="CocoaPods" />
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat" alt="Carthage" />
    </a>
</p>

SWindow is an easy to use Swift windows manager. Don't spend hours writing your code to present and dismiss modal view controllers, stop wasting your time on debugging why your modal presentation disapear. Without issues, simple and safe present your controller!

## 💊 Usage
**Basic Example**
Make your controller conform to `SModalPresentation` protocol
```swift
class YourController: UIViewController, SModalPresentation {}
```
To present your controller simple call:
```swift
let controller = YourController()
controller.sPresent()
```
To dismiss or remove from wait queue call:
```swift
controller.sWithdraw()
```
If you want replace current presented controller with other call:
```swift
controller.sReplace(with: newController)
```

SWindow automatically add your controller to queue if other is currently presented. Moreover on `sWithdraw()` event after dismiss will present first controller from queue with highest priority.

**Advance Configuration**
Above was pretty simple example. However SWindow provides multiple configuration options.

First thing what you can do is to extend SModal class with your own values.
Belove you can see an example what can you modify.
```swift
extension SModal {
    static var shouldMakeKey: Bool {
        return false
    }
    
    static var windowLevel: UIWindowLevel {
        return UIWindowLevelAlert - 1
    }
    
    static var animationDuration: TimeInterval {
        return 0.2
    }
}
```
First of all in every project I would extend `SModal` to return `true` under `shouldMakeKey` thanks to that our window will become keyWindow and will receive system events.

Second thing you can adjust is `SModalPresentation`. your Controller can be dismiss by `SWindow` if you return `true` under `canDismiss`. Thanks to this parameter what ever will pop in to queue and the current presented controller will  be return positive value under this flag `SWindow` will dismiss it and present next one from the queue.
```swift
extension YourController {    
    public var canDismiss: Bool {
        return false
    }
    
    public var priority: SModalPriority {
        return .Required
    }
}
```
As I have wrote earlier YourController is ordered by priority during dequeue for presentation. You can change priority for each of your controllers coresponding to `SModalPresentation`.

Last things to extend are:
`sPresent()`
`sWithdraw()`
`sReplace(with: UIViewController)`
Each of this method have additional arguments with defaults set as follows `animated: Bool = false, completion: (() -> Void)? = nil`

## 🔧 Installation

**CocoaPods:**

Add the line `pod "SWindow"` to your `Podfile`

**Carthage:**

Add the line `github "shial4/swindow"` to your `Cartfile`

**Manual:**

Clone the repo and drag the file `SWindow.swift` into your Xcode project.

**Swift Package Manager:**

Add the line `.package(url: "https://github.com/shial4/SWindow.git", from: "0.1.10")` to your `Package.swift`

## ⭐ Contributing

Be welcome to contribute to this project! :)

## ❓ Questions

Just create an issue on GitHub.

## 📝 License

This project was released under the [MIT](LICENSE) license.
