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
    
    static var windowLevel: UIWindowLevel {
        return UIWindowLevelAlert - 1
    }
    
    static var animationDuration: TimeInterval {
        return 0.2
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
    public var modalStatus: SModalStatus {
        if SModal.modalWindow.rootViewController === self {
            return .presented
        }
        if SModal.stack.contains(where: { $0 === self }) {
            return .waitingInStack
        }
        return .none
    }
    
    public var canDismiss: Bool {
        return false
    }
    
    public var stack: [SModalPresentation] {
        return SModal.stack
    }
    
    public var priority: SModalPriority {
        return .Required
    }
}

extension SModalPresentation where Self: UIViewController {
    func sReplace<T: UIViewController>(with controller: T, animated: Bool, completion: (() -> Void)?) where T: SModalPresentation {
        if animated {
            SModal.modalWindow.isHidden = false
            UIView.animate(withDuration: SModal.animationDuration, animations: {
                SModal.modalWindow.rootViewController = controller
                SModal.modalWindow.makeKey()
                SModal.modalWindow.alpha = 1
            }, completion: { completed in
                completion?()
            })
        } else {
            SModal.modalWindow.rootViewController = controller
            SModal.modalWindow.makeKey()
            SModal.modalWindow.isHidden = false
            completion?()
        }
        
    }
    
    func sPresent(animated: Bool, completion: (() -> Void)?) {
        guard let currentPresented = SModal.modalWindow.rootViewController else {
            SModal.modalWindow.rootViewController = self
            SModal.modalWindow.makeKey()
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
        if let sModalController = currentPresented as? Self, sModalController.canDismiss == true {
            sModalController.sReplace(with: self, animated: animated, completion: completion)
        } else {
            SModal.stack.append(self)
        }
    }
    
    func sWithdraw(animated: Bool, completion: (() -> Void)?) {
        if SModal.modalWindow.rootViewController === self {
            if animated {
                SModal.modalWindow.alpha = 1
                UIView.animate(withDuration: SModal.animationDuration, animations: {
                    SModal.modalWindow.alpha = 0
                }, completion: { completed in
                    SModal.modalWindow.isHidden = true
                    completion?()
                })
            } else {
                SModal.modalWindow.isHidden = true
                completion?()
            }
            SModal.modalWindow.rootViewController = nil
            SModal.modalWindow.resignKey()
        } else if SModal.stack.contains(where: { $0 === self }) {
            SModal.stack = SModal.stack.filter() { !($0 === self) }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + SModal.animationDuration) {
            if let controller = SModal.stack.sorted(by: {$0.priority > $1.priority}).first {
                SModal.stack.removeFirst()
                controller.sPresent(animated: true, completion: nil)
            }
        }
    }
}



