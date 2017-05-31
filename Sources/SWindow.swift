//
//  SWindow.swift
//  SWindow
//
//  Created by Shial on 30/5/17.
//  Copyright © 2017 Shial. All rights reserved.
//

import UIKit

public typealias SModalPriority = Float

extension SModalPriority {
    public static var Low: SModalPriority = 250
    public static var Required: SModalPriority = 500
    public static var High: SModalPriority = 750
}

public enum SModalStatus {
    case presented
    case waitingInStack
    case none
}

public class SModal {
    static let modalWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .clear
        window.windowLevel = windowLevel
        window.isHidden = true
        return window
    }()
    
    static var stack: [SModalPresentation] = []
    
    public static var shouldMakeKey: Bool {
        return false
    }
    
    public static var windowLevel: UIWindowLevel {
        return UIWindowLevelAlert - 1
    }
    
    public static var animationDuration: TimeInterval {
        return 0.2
    }
    
    fileprivate static func dropRootViewController() {
        modalWindow.isHidden = true
        modalWindow.rootViewController = nil
        modalWindow.resignKey()
    }
    
    fileprivate static func makeKey() {
        if shouldMakeKey {
            SModal.modalWindow.makeKey()
        }
    }
}

public protocol SModalStack {
    var stack: [SModalPresentation] { get }
    var modalStatus: SModalStatus { get }
    var canDismiss: Bool { get }
    var priority: SModalPriority { get }
}

public protocol SModalPresentation: class, SModalStack {
    func sPresent(animated: Bool, completion: (() -> Void)?)
    func sWithdraw(animated: Bool, completion: (() -> Void)?)
}

extension SModalPresentation {
    final var modalStatus: SModalStatus {
        if SModal.modalWindow.rootViewController === self {
            return .presented
        }
        if SModal.stack.contains(where: { $0 === self }) {
            return .waitingInStack
        }
        return .none
    }
    
    final var stack: [SModalPresentation] {
        return SModal.stack
    }
    
    public var canDismiss: Bool {
        return false
    }
    
    public var priority: SModalPriority {
        return .Required
    }
}

extension SModalPresentation where Self: UIViewController {
    public func sReplace<T: UIViewController>(with controller: T, animated: Bool = false, completion: (() -> Void)? = nil) where T: SModalPresentation {
        if animated {
            SModal.modalWindow.isHidden = false
            UIView.animate(withDuration: SModal.animationDuration, animations: {
                SModal.modalWindow.rootViewController = controller
                SModal.makeKey()
                SModal.modalWindow.alpha = 1
            }, completion: { completed in
                completion?()
            })
        } else {
            SModal.modalWindow.rootViewController = controller
            SModal.makeKey()
            SModal.modalWindow.isHidden = false
            completion?()
        }
        
    }
    
    public func sPresent(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let currentPresented = SModal.modalWindow.rootViewController else {
            SModal.modalWindow.rootViewController = self
            SModal.makeKey()
            if animated {
                SModal.modalWindow.alpha = 0
                SModal.modalWindow.isHidden = false
                UIView.animate(withDuration: SModal.animationDuration, animations: {
                    SModal.modalWindow.alpha = 1
                }, completion: { completed in
                    completion?()
                })
            } else {
                SModal.modalWindow.isHidden = false
                completion?()
            }
            return
        }
        SModal.stack.append(self)
        if (currentPresented as? SModalPresentation)?.canDismiss == true {
            (currentPresented as? SModalPresentation)?.sWithdraw(animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    public func sWithdraw(animated: Bool = false, completion: (() -> Void)? = nil) {
        func completedProcedure() {
            if let controller = SModal.stack.sorted(by: {$0.priority > $1.priority}).first {
                SModal.stack = SModal.stack.filter({ $0  !== controller })
                controller.sPresent(animated: animated, completion: completion)
            }else {
                completion?()
            }
        }
        
        if SModal.modalWindow.rootViewController === self {
            if animated {
                SModal.modalWindow.alpha = 1
                UIView.animate(withDuration: SModal.animationDuration, animations: {
                    SModal.modalWindow.alpha = 0
                }, completion: { completed in
                    SModal.dropRootViewController()
                    completedProcedure()
                })
            } else {
                SModal.dropRootViewController()
                completedProcedure()
            }
        } else if SModal.stack.contains(where: { $0 === self }) {
            SModal.stack = SModal.stack.filter() { !($0 === self) }
        }
    }
}
