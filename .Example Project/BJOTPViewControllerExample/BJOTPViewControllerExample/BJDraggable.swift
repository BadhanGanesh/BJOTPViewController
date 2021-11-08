//
//  BJDraggable
//  Created by Badhan Ganesh on 28-05-2018
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright © 2018 Badhan Ganesh
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

fileprivate var kReferenceViewKey: UInt8 = 0
fileprivate var kDynamicAnimatorKey: UInt8 = 0
fileprivate var kAttachmentBehaviourKey: UInt8 = 0
fileprivate var kPanGestureKey: UInt8 = 0
fileprivate var kResetPositionKey: UInt8 = 0
fileprivate var kDebugModeEnabledKey: UInt8 = 0

fileprivate enum BehaviourName {
    case main
    case border
    case collision
    case attachment
}

fileprivate enum UniqueBorderViewTag:Int {
    case left = 223420
    case right = 223421
    case top = 223422
    case bottom = 223423
}

/**A simple protocol *(No need to implement methods and properties yourself. Just drop-in the BJDraggable file to your project and all done)* utilizing the powerful `UIKitDynamics` API, which makes **ANY** `UIView` draggable within a boundary view that acts as collision body, with a single method call.
 */
@objc protocol BJDraggable: AnyObject {
    
    /**
     Gives you the power to drag your `UIView` anywhere within a specified view, and collide within its bounds.
     - parameter referenceView: The boundary view which acts as a wall, and your view will collide with it and would never fall out of bounds hopefully. **Note that the reference view should contain the view that you're trying to add draggability to in its view hierarchy. The app would crash otherwise.**
     */
    @objc func addDraggability(withinView referenceView: UIView)
    
    /**
     This single method call will give you the power to drag your `UIView` anywhere within a specified view, and collide within its bounds.
     - parameter referenceView: This is the boundary view which acts as a wall, and your view will collide with it and would never fall out of bounds hopefully. **Note that the reference view should contain the view that you're trying to add draggability to in its view hierarchy. The app would crash otherwise.**
     - parameter insets: If you want to make the boundary to be offset positively or negatively, you can specify that here. This is nothing but a margin for the boundary.
     */
    @objc func addDraggability(withinView referenceView: UIView, withMargin insets:UIEdgeInsets)
    
    /**
     Removes the power from you, to drag the view in question
     */
    @objc func removeDraggability()
    
}

extension UIView: BJDraggable {
    
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    //MARK:-
    //MARK: Properties
    //MARK:-
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    
    /**
     * This will highlight the boundary views in red color for having an idea with which area you are dragging your view(s) in.
     */
    public var isDraggableDebugModeEnabled: Bool {
        get {
            return objc_getAssociatedObject(self, &kDebugModeEnabledKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &kDebugModeEnabledKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.highlightBoundaryViews(newValue)
        }
    }
    
    public var shouldResetViewPositionAfterRemovingDraggability: Bool {
        get {
            return objc_getAssociatedObject(self, &kResetPositionKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &kResetPositionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.translatesAutoresizingMaskIntoConstraints = !newValue
        }
    }
    
    fileprivate var referenceView: UIView? {
        get {
            return objc_getAssociatedObject(self, &kReferenceViewKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &kReferenceViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var animator: UIDynamicAnimator? {
        get {
            return objc_getAssociatedObject(self, &kDynamicAnimatorKey) as? UIDynamicAnimator
        }
        set {
            objc_setAssociatedObject(self, &kDynamicAnimatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var attachmentBehaviour: UIAttachmentBehavior? {
        get {
            return objc_getAssociatedObject(self, &kAttachmentBehaviourKey) as? UIAttachmentBehavior
        }
        set {
            objc_setAssociatedObject(self, &kAttachmentBehaviourKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &kPanGestureKey) as? UIPanGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &kPanGestureKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    //MARK:-
    //MARK: Method Implementations
    //MARK:-
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    
    public final func addDraggability(withinView referenceView: UIView) {
        self.addDraggability(withinView: referenceView, withMargin: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    public final func addDraggability(withinView referenceView: UIView, withMargin insets:UIEdgeInsets) {
        
        guard self.animator == nil else { return }
        
        ///////////////////////
        /////Configuration/////
        ///////////////////////
        
        performInitialConfiguration()
        addPanGestureRecognizer()
        
        ////////////////////////////////////////////
        /////Get Collision Items For Behaviours/////
        ////////////////////////////////////////////
        
        let collisionItems = self.drawAndGetCollisionViewsAround(referenceView, withInsets: insets)
        
        ////////////////////////
        /////Get Behaviours/////
        ////////////////////////
        
        let mainItemBehaviour = get(behaviour: .main, for: referenceView, withInsets: insets, configuredWith: collisionItems)!
        let borderItemsBehaviour = get(behaviour: .border, for: referenceView, withInsets: insets, configuredWith: collisionItems)!
        let collisionBehaviour = get(behaviour: .collision, for: referenceView, withInsets: insets, configuredWith: collisionItems)!
        let attachmentBehaviour = get(behaviour: .attachment, for: referenceView, withInsets: insets, configuredWith: collisionItems)!
        
        ////////////////////////////////////
        /////Add Behaviours to Animator/////
        ////////////////////////////////////
        
        let animator = UIDynamicAnimator.init(referenceView: referenceView)
        animator.addBehavior(mainItemBehaviour)
        animator.addBehavior(borderItemsBehaviour)
        animator.addBehavior(collisionBehaviour)
        animator.addBehavior(attachmentBehaviour)
        
        /////////////////////
        /////Persistence/////
        /////////////////////
        
        self.animator = animator
        self.referenceView = referenceView
        self.attachmentBehaviour = attachmentBehaviour as? UIAttachmentBehavior
        
    }
    
    public final func removeDraggability() {
        
        if let recognizer = self.panGestureRecognizer { self.removeGestureRecognizer(recognizer) }
        self.translatesAutoresizingMaskIntoConstraints = !self.shouldResetViewPositionAfterRemovingDraggability
        self.animator?.removeAllBehaviors()
        
        if let subviews = self.referenceView?.subviews {
            for view in subviews {
                if view.isKind(of: BoundaryCollisionView.self) {
                    view.removeFromSuperview()
                }
            }
        }
        
        self.referenceView = nil
        self.attachmentBehaviour = nil
        self.animator = nil
        self.panGestureRecognizer = nil
    }
    
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    //MARK:-
    //MARK: Helpers 1
    //MARK:-
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    
    fileprivate func performInitialConfiguration() {
        self.isUserInteractionEnabled = true
    }
    
    fileprivate func addPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.panGestureHandler(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = panGestureRecognizer
    }
    
    @objc final func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        guard let referenceView = self.referenceView else { return }
        let touchPoint = gesture.location(in: referenceView)
        self.attachmentBehaviour?.anchorPoint = touchPoint
    }
    
    fileprivate func get(behaviour:BehaviourName, for referenceView:UIView, withInsets insets:UIEdgeInsets, configuredWith boundaryCollisionItems:[UIDynamicItem]) -> UIDynamicBehavior? {
        
        let allItems = [self] + boundaryCollisionItems
        
        switch behaviour {
        case .border:
            let borderItemsBehaviour = UIDynamicItemBehavior.init(items: boundaryCollisionItems)
            borderItemsBehaviour.allowsRotation = false
            borderItemsBehaviour.isAnchored = true
            borderItemsBehaviour.elasticity = 100
            return borderItemsBehaviour
        case .main:
            let mainItemBehaviour = UIDynamicItemBehavior.init(items: [self])
            mainItemBehaviour.allowsRotation = false
            mainItemBehaviour.isAnchored = false
            mainItemBehaviour.elasticity = 100
            return mainItemBehaviour
        case .collision:
            let collisionBehaviour = UICollisionBehavior.init(items: allItems)
            collisionBehaviour.collisionMode = .items
            collisionBehaviour.setTranslatesReferenceBoundsIntoBoundary(with: insets)
            return collisionBehaviour
        case .attachment:
            let attachmentBehaviour = UIAttachmentBehavior.init(item: self, attachedToAnchor: self.center)
            return attachmentBehaviour
        }
    }
    
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    //MARK:-
    //MARK: Helpers 2
    //MARK:-
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    
    func alteredFrameByPoints(_ point:CGFloat) -> CGRect {
        return self.frame.insetBy(dx: -point, dy: -point)
    }
    
    fileprivate func boundaryPathFor(_ view:UIView, withInsets insets:UIEdgeInsets) -> UIBezierPath {
        
        let frameWithInsets = view.frame.inset(by: insets)
        var rect = frameWithInsets.insetBy(dx: -3, dy: -3)
        
        rect.origin.x = -3.0 - insets.left
        rect.origin.y = -3.0 - insets.top
        rect.size.width = -3.0 - insets.right
        rect.size.height = -3.0 - insets.bottom
        
        let path = UIBezierPath.init(rect: rect)
        return path
    }
    
    fileprivate func highlightBoundaryViews(_ yes:Bool) {
        guard let referenceView = self.referenceView else { return }
        referenceView.viewWithTag(UniqueBorderViewTag.left.rawValue)?.backgroundColor = yes ? .red : .clear
        referenceView.viewWithTag(UniqueBorderViewTag.right.rawValue)?.backgroundColor = yes ? .red : .clear
        referenceView.viewWithTag(UniqueBorderViewTag.top.rawValue)?.backgroundColor = yes ? .red : .clear
        referenceView.viewWithTag(UniqueBorderViewTag.bottom.rawValue)?.backgroundColor = yes ? .red : .clear
    }
    
    @discardableResult fileprivate func drawAndGetCollisionViewsAround(_ referenceView:UIView, withInsets insets:UIEdgeInsets) -> ([UIView]) {
        
        let boundaryViewWidth = CGFloat(1)
        let boundaryViewHeight = CGFloat(1)
        
        //////////////////////
        /////Get New Rect/////
        //////////////////////
        
        let newReferenceViewRect = referenceView.alteredFrameByPoints(1).inset(by: insets)
        
        /////////////////////////////
        /////Fabricate Left View/////
        /////////////////////////////
        
        let leftView = BoundaryCollisionView(frame: CGRect.init(x: -0.0 + insets.left, y: -0.0 + insets.top, width: boundaryViewWidth, height: newReferenceViewRect.size.height))
        leftView.isUserInteractionEnabled = false
        leftView.tag = UniqueBorderViewTag.left.rawValue
        leftView.backgroundColor = isDraggableDebugModeEnabled ? .red : .clear
        
        //////////////////////////////
        /////Fabricate Right View/////
        //////////////////////////////
        
        let rightView = BoundaryCollisionView(frame: CGRect.init(x: newReferenceViewRect.size.width + insets.left - 3.0, y:-0.0 + insets.top, width: boundaryViewWidth, height: newReferenceViewRect.size.height))
        rightView.isUserInteractionEnabled = false
        rightView.tag = UniqueBorderViewTag.right.rawValue
        rightView.backgroundColor = isDraggableDebugModeEnabled ? .red : .clear
        
        ////////////////////////////
        /////Fabricate Top View/////
        ////////////////////////////
        
        let topView = BoundaryCollisionView(frame: CGRect.init(x: -0.0 + insets.left, y: -0.0 + insets.top, width:newReferenceViewRect.size.width - 1.0, height: boundaryViewHeight))
        topView.isUserInteractionEnabled = false
        topView.tag = UniqueBorderViewTag.top.rawValue
        topView.backgroundColor = isDraggableDebugModeEnabled ? .red : .clear
        
        ///////////////////////////////
        /////Fabricate Bottom View/////
        ///////////////////////////////
        
        let bottomView = BoundaryCollisionView(frame: CGRect.init(x: -0.0 + insets.left, y: insets.top + newReferenceViewRect.size.height - 3.0, width: newReferenceViewRect.size.width - 1.0, height: boundaryViewHeight))
        bottomView.isUserInteractionEnabled = false
        bottomView.tag = UniqueBorderViewTag.bottom.rawValue
        bottomView.backgroundColor = isDraggableDebugModeEnabled ? .red : .clear
        
        /////////////////////
        /////Add Subview/////
        /////////////////////
        
        referenceView.addSubview(leftView)
        referenceView.addSubview(rightView)
        referenceView.addSubview(topView)
        referenceView.addSubview(bottomView)
        
        return [leftView, rightView, topView, bottomView]
    }
    
}

/**
 This is a special view for unique identification that gets invisibly added as a subview to the reference view for creating boundary around it.
 */
class BoundaryCollisionView: UIView { }
