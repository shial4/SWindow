//
//  SWindowTests.swift
//  SWindowTests
//
//  Created by Shial on 30/5/17.
//  Copyright © 2017 Shial. All rights reserved.
//

import XCTest
@testable import SWindow

class SWindowTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLowPriority() {
        XCTAssert(SModalPriority.Low == 250)
    }
    
    func testRequiredPriority() {
        XCTAssert(SModalPriority.Required == 500)
    }
    
    func testHighPriority() {
        XCTAssert(SModalPriority.High == 750)
    }
    
    func testSModalWindow() {
        XCTAssertNotNil(SModal.modalWindow)
    }
    
    func testSModalWindowLevel() {
        XCTAssert(SModal.windowLevel == UIWindowLevelAlert - 1)
    }
    
    func testSModalWindowStack() {
        XCTAssertNotNil(SModal.stack)
    }
    
    func testSModalDuration() {
        XCTAssertEqualWithAccuracy(SModal.animationDuration, 0.2, accuracy: 0.01)
    }
    
    func testModalCanDismiss() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        XCTAssert(!controller.canDismiss)
    }
    
    func testModalStatusNone() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        XCTAssert(controller.modalStatus == .none)
    }
    
    func testModalStatusPresented() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        SModal.modalWindow.rootViewController = controller
        XCTAssert(controller.modalStatus == .presented)
    }
    
    func testModalStatusWaitingInStack() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        SModal.stack.append(controller)
        XCTAssert(controller.modalStatus == .waitingInStack)
    }
    
    func testModalStatusStack() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        XCTAssertNotNil(controller.stack)
    }
    
    func testModalStatusPriority() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        XCTAssertNotNil(controller.priority == .Required)
    }
    
    func testModalPresentationStack() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        SModal.modalWindow.rootViewController = controller
        
        let controllerToPresent = Controller()
        controllerToPresent.sPresent()
        XCTAssert(SModal.stack.contains(where: { $0 === controllerToPresent }))
    }
    
    func testModalPresentationCanDismiss() {
        class Controller: UIViewController, SModalPresentation {
            var canDismiss: Bool {
                return true
            }
        }
        let controller = Controller()
        SModal.modalWindow.rootViewController = controller
        class ControllerHigh: UIViewController, SModalPresentation {}
        let controllerToPresent = ControllerHigh()
        controllerToPresent.sPresent {
            XCTAssertTrue(SModal.modalWindow.rootViewController === controllerToPresent)
        }
    }
    
    func testModalPresentationStackWithdraw() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        
        class ControllerTwo: UIViewController, SModalPresentation {}
        let controllerTwo = ControllerTwo()
        
        class ControllerThree: UIViewController, SModalPresentation {}
        let controllerThree = ControllerThree()
        
        SModal.stack.append(controller)
        SModal.stack.append(controllerTwo)
        SModal.stack.append(controllerThree)
        
        controllerTwo.sWithdraw { 
            XCTAssertFalse(controller.modalStatus == .waitingInStack)
        }
    }
    
    func testModalPresentationPriorityAnimated() {
        class Controller: UIViewController, SModalPresentation {
            var canDismiss: Bool {
                return true
            }
        }
        let controller = Controller()
        SModal.modalWindow.rootViewController = controller
        class ControllerHigh: UIViewController, SModalPresentation {}
        let controllerToPresent = ControllerHigh()
        controllerToPresent.sPresent(animated: true) {
            XCTAssertFalse(SModal.modalWindow.rootViewController === controller)
        }
    }
    
    func testModalPresentationStackWithdrawAnimated() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        
        class ControllerTwo: UIViewController, SModalPresentation {}
        let controllerTwo = ControllerTwo()
        
        class ControllerThree: UIViewController, SModalPresentation {}
        let controllerThree = ControllerThree()
        
        SModal.stack.append(controller)
        SModal.stack.append(controllerTwo)
        SModal.stack.append(controllerThree)
        
        controllerTwo.sWithdraw(animated: true) {
            XCTAssertFalse(controller.modalStatus == .waitingInStack)
        }
    }
    
    func testModalPresentationReplace() {
        class Controller: UIViewController, SModalPresentation {}
        let controller = Controller()
        
        class ControllerTwo: UIViewController, SModalPresentation {}
        let controllerTwo = ControllerTwo()
        
        SModal.modalWindow.rootViewController = controller
        controller.sReplace(with: controllerTwo) {
            XCTAssertTrue(SModal.modalWindow.rootViewController === controllerTwo)
        }
    }
    
}
