//
//  SWindow.swift
//  SWindow
//
//  Created by Shial on 30/5/17.
//  Copyright © 2017 Shial. All rights reserved.
//

import UIKit

/// Priority type of SModal
public typealias SModalPriority = Float

// MARK: - Priority default types
extension SModalPriority {
    /// Low Priority
    public static var Low: SModalPriority = 250
    /// Required Priority
    public static var Required: SModalPriority = 500
    /// High Priority
    public static var High: SModalPriority = 750
}

/// Presentation status of Your ViewController.
///
/// - presented: Means it's currently presented on screen.
/// - waitingInStack: Your controllers is waiting in queue.
/// - none: Your controller is not presented neither in queue
public enum SModalStatus {
    /// Means it's currently presented on screen.
    case presented
    /// Your controllers is waiting in queue.
    case waitingInStack
    /// Your controller is not presented neither in queue
    case none
}

/// Main object responsible for presentation flow
public class SModal {
    /// Window use to present your view controllers
    static let modalWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .clear
        window.windowLevel = UIWindow.Level(windowLevel)
        window.isHidden = true
        return window
    }()
    
    /// stack to store controllers in queue
    static var stack: [SModalPresentation] = []
    
    /// window level on which should appear on top of windows
    public static var windowLevel: CGFloat {
        return UIWindow.Level.alert.rawValue - 1
    }
    
    /// Discard curent root view controller and hide window
    fileprivate static func dropRootViewController() {
        modalWindow.isHidden = true
        modalWindow.rootViewController = nil
    }
}

/// Modal Stack protocol providing main information to operate with SWindow
public protocol SModalStack {
    /// Define if other objects can discard this one while presenting
    var canDismiss: Bool { get }
    /// Define priority of this object
    var priority: SModalPriority { get }
}

/// Modal Presentation protocol, provide methods to present and dismiss object.
public protocol SModalPresentation: class, SModalStack {
    /// Present current object or adding it to the stack if presentation in this time is not avaiable
    ///
    /// - Parameters:
    ///   - animated: Boolean value idicating if presentation should be animated
    ///   - completion: completion block called after presentation procedure or insert to stack
    func sPresent(animated: Bool, completion: (() -> Void)?)
    /// Dismiss current object from presentation or remove from stack.
    ///
    /// - Parameters:
    ///   - animated: Boolean value idicating if operation should be animated
    ///   - completion: completion block called after dismiss procedure
    func sWithdraw(animated: Bool, completion: (() -> Void)?)
    /// animation duration used to animated transition between presentations
    var animationDuration: TimeInterval { get }
    /// Boolean value defining if window upon presentation should become a key window.
    var shouldMakeKey: Bool { get }
}

// MARK: - Default implementation of Modal Presentation protocol
extension SModalPresentation {
    /// Provide information about current status
    var modalStatus: SModalStatus {
        if SModal.modalWindow.rootViewController === self {
            return .presented
        }
        if SModal.stack.contains(where: { $0 === self }) {
            return .waitingInStack
        }
        return .none
    }
    
    /// Return SWindow stack
    var stack: [SModalPresentation] {
        return SModal.stack
    }
    
    /// By default other objects are not allow to dimiss this one upon presentation
    public var canDismiss: Bool {
        return false
    }
    
    /// Default priority set to Required
    public var priority: SModalPriority {
        return .Required
    }
}


// MARK: - Default implementation of Modal Stac method with additional helper methods
extension SModalPresentation where Self: UIViewController {
    /// Helper method provide ability to replace current presented object with passed one in method argument with out touching stack.
    ///
    /// - Parameters:
    ///   - controller: Controller to replace current presented one
    ///   - animated: Boolean value idicating if operation should be animated
    ///   - completion: Completion block called on the end of operation
    public func sReplace<T: UIViewController>(with controller: T, animated: Bool = false, completion: (() -> Void)? = nil) where T: SModalPresentation {
        DispatchQueue.main.async {
            if animated {
                SModal.modalWindow.isHidden = false
                UIView.animate(withDuration: controller.animationDuration, animations: {
                    SModal.modalWindow.rootViewController = controller
                    SModal.modalWindow.alpha = 1
                }, completion: { completed in
                    if controller.shouldMakeKey {
                        SModal.modalWindow.makeKey()
                    }
                    completion?()
                })
            } else {
                SModal.modalWindow.rootViewController = controller
                SModal.modalWindow.alpha = 1
                SModal.modalWindow.isHidden = false
                if controller.shouldMakeKey {
                    SModal.modalWindow.makeKey()
                }
                completion?()
            }
        }
    }
    
    /// Default implementation, Object is presented if avaiable or placed in stack. If other object is current presented but can be dissmised SModal is replacing him the next one from stack.
    ///
    /// - Parameters:
    ///   - animated: Boolean value idicating if operation should be animated
    ///   - completion: Completion block called on the end of operation
    public func sPresent(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let currentPresented = SModal.modalWindow.rootViewController else {
            func presentController() {
                SModal.modalWindow.rootViewController = self
                if self.shouldMakeKey {
                    SModal.modalWindow.makeKey()
                }
                if animated {
                    SModal.modalWindow.alpha = 0
                    SModal.modalWindow.isHidden = false
                    UIView.animate(withDuration: self.animationDuration, animations: {
                        SModal.modalWindow.alpha = 1
                    }, completion: { completed in
                        SModal.modalWindow.alpha = 1
                        SModal.modalWindow.isHidden = false
                        completion?()
                    })
                } else {
                    SModal.modalWindow.alpha = 1
                    SModal.modalWindow.isHidden = false
                    completion?()
                }
            }
            if Thread.isMainThread {
                presentController()
            } else {
                DispatchQueue.main.sync { presentController() }
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
    
    /// Default implementation, upon withdraw object is removed from presentation or stack and the next one from the stack is presented if avaiable.
    ///
    /// - Parameters:
    ///   - animated: Boolean value idicating if operation should be animated
    ///   - completion: Completion block called on the end of operation
    public func sWithdraw(animated: Bool = false, completion: (() -> Void)? = nil) {
        func completedProcedure() {
            if let controller = SModal.stack.sorted(by: {$0.priority > $1.priority}).first {
                SModal.stack = SModal.stack.filter({ $0  !== controller })
                controller.sPresent(animated: animated, completion: completion)
            }else {
                completion?()
            }
        }
        DispatchQueue.main.async {
            if SModal.modalWindow.rootViewController === self {
                if animated {
                    SModal.modalWindow.alpha = 1
                    UIView.animate(withDuration: self.animationDuration, animations: {
                        SModal.modalWindow.alpha = 0
                    }, completion: { completed in
                        SModal.dropRootViewController()
                        completedProcedure()
                    })
                } else {
                    SModal.modalWindow.alpha = 0
                    SModal.dropRootViewController()
                    completedProcedure()
                }
            } else if SModal.stack.contains(where: { $0 === self }) {
                SModal.stack = SModal.stack.filter() { !($0 === self) }
            }
        }
    }
}
