//
//  UIViewExtensions.swift
//  swiftextensions
//  Created by Badhan Ganesh on 10/10/18.
//
// Copyright © 2018 Badhan Ganesh


import UIKit

@objc enum UIViewPinPosition:Int {
    case topLeft = 0,
         topMiddle,
         topRight,
         middleRight,
         bottomRight,
         bottomMiddle,
         bottomLeft,
         middleLeft,
         middle,
         middleByHuggingAllSides
}

extension UIView {
    
    /**
     
     Pins the view to the specified position in its superview using autolayout constraints. **NOTE:** If you already have added any constraints that are conflicting for the constraints going to be added for the supplied `position`, they will be deactivated and removed.
     
     - Parameter position: The position you want to pin the view to its superview. See above for possible values.
     - Parameter shouldRespectSafeArea: Pass `true` to take the superview's safe area layout guide into account when pinning. Default is `true`. **NOTE:** This parameter will be ignored for iOS versions below 11.0.
     
     ```
     //Example Usage
     
     //This pins `myView` to top left of its super view.
     self.myView.pinTo(.topLeft)
     
     //This pins `myView` to top right of its super view respecting its safe area layout guide.
     self.myView.pinTo(.topRight, shouldRespectSafeArea:true)
     ```
     
     Use one of the below values for the `UIViewPinPosition`:
     
     * topLeft
     * topMiddle
     * topRight
     * middleRight
     * bottomRight
     * bottomMiddle
     * bottomLeft
     * middleLeft
     * middle
     * middleWithLeadTrailTopBottom
     
     - Author: Badhan Ganesh
     
     */
    @objc func pinTo(_ position: UIViewPinPosition, shouldRespectSafeArea: Bool = true, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        
        guard let superview = self.superview else { return }
        
        self.tarmic = false
        
        var shouldConsiderSafeArea = shouldRespectSafeArea
        if #available(iOS 11.0, *) { } else { shouldConsiderSafeArea = false }
        
        ///////////////////////////////////////////////////////////////////
        ////////Add width and height constraints from view's bounds////////
        ///////////////////////////////////////////////////////////////////
        
        if self.bounds.size != .zero {
            if self.constraints.isEmpty {
                self.addConstraints([self.widthAnchor.constraint(equalToConstant: self.bounds.width),
                                     self.heightAnchor.constraint(equalToConstant: self.bounds.height)])
            }
        }
        
        for constraint in superview.constraints {
            
            ///////////////////////////////////////////////////////
            ////////Remove possible conflicting constraints////////
            ///////////////////////////////////////////////////////
            
            if constraint.firstAttribute != .width && constraint.firstAttribute != .height {
                if let firstItem = constraint.firstItem as? UIView, firstItem == self {
                    superview.removeConstraint(constraint)
                }
            }
            
            ////////////////////////////////////////////
            ////////Remove old added constraints////////
            ////////////////////////////////////////////
            
            if constraint.identifier?.contains("BJConstraint - \(self.pointerString)") ?? false {
                constraint.isActive = false
                superview.removeConstraint(constraint)
            }
            
        }
        
        ///////////////////////////////////////////////////////
        ////////Use Safe Area for iOS 11 and above only////////
        ///////////////////////////////////////////////////////
        
        var safeAreaLeadingAnchor:NSLayoutXAxisAnchor?
        var safeAreaTrailingAnchor:NSLayoutXAxisAnchor?
        var safeAreaTopAnchor:NSLayoutYAxisAnchor?
        var safeAreaBottomAnchor:NSLayoutYAxisAnchor?
        
        if #available(iOS 11.0, *) {
            safeAreaLeadingAnchor = superview.safeAreaLayoutGuide.leadingAnchor
            safeAreaTrailingAnchor = superview.safeAreaLayoutGuide.trailingAnchor
            safeAreaTopAnchor = superview.safeAreaLayoutGuide.topAnchor
            safeAreaBottomAnchor = superview.safeAreaLayoutGuide.bottomAnchor
        }
        
        ///////////////////////////////////////////////
        ////////Prepare constraints to be added////////
        ///////////////////////////////////////////////
        
        let centerXConstraint = self.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: xOffset)
        centerXConstraint.identifier = "BJConstraintCenterX - \(self.pointerString)"
        
        let centerYConstraint = self.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: yOffset)
        centerYConstraint.identifier = "BJConstraintCenterY - \(self.pointerString)"
        
        let leadingConstraint = self.leadingAnchor.constraint(equalTo: shouldConsiderSafeArea ? safeAreaLeadingAnchor! : superview.leadingAnchor, constant: xOffset)
        leadingConstraint.identifier = "BJConstraintLeading - \(self.pointerString)"
        
        let trailingConstraint = self.trailingAnchor.constraint(equalTo: shouldConsiderSafeArea ? safeAreaTrailingAnchor! : superview.trailingAnchor, constant: xOffset)
        trailingConstraint.identifier = "BJConstraintTrailing - \(self.pointerString)"
        
        let topConstraint = self.topAnchor.constraint(equalTo: shouldConsiderSafeArea ? safeAreaTopAnchor! : superview.topAnchor, constant: yOffset)
        topConstraint.identifier = "BJConstraintTop - \(self.pointerString)"
        
        let bottomConstraint = self.bottomAnchor.constraint(equalTo: shouldConsiderSafeArea ? safeAreaBottomAnchor! : superview.bottomAnchor, constant: yOffset)
        bottomConstraint.identifier = "BJConstraintBottom - \(self.pointerString)"
        
        ////////////////////////////////////////
        ////////Add relevant constraints////////
        ////////////////////////////////////////
        
        switch position {
            case .topLeft:
                superview.addConstraints([leadingConstraint, topConstraint])
                break
            case .topMiddle:
                superview.addConstraints([centerXConstraint, topConstraint])
                break
            case .topRight:
                superview.addConstraints([trailingConstraint, topConstraint])
                break
            case .middleLeft:
                superview.addConstraints([centerYConstraint, leadingConstraint])
                break
            case .bottomLeft:
                superview.addConstraints([bottomConstraint, leadingConstraint])
                break
            case .bottomMiddle:
                superview.addConstraints([bottomConstraint, centerXConstraint])
                break
            case .bottomRight:
                superview.addConstraints([bottomConstraint, trailingConstraint])
                break
            case .middleRight:
                superview.addConstraints([centerYConstraint, trailingConstraint])
                break
            case .middle:
                superview.addConstraints([centerYConstraint, centerXConstraint])
                break
            case .middleByHuggingAllSides:
                superview.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
                break
        }
        
        CATransaction.flush()
        
    }
    
    func change(yOffset y: CGFloat = 0.0) -> NSLayoutConstraint? {
        if let superview = superview {
            for constraint in superview.constraints {
                if constraint.identifier == "BJConstraintCenterY - \(self.pointerString)" {
                    superview.removeConstraint(constraint)
                    let constraintToAdd = self.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
                    constraintToAdd.identifier = "BJConstraintCenterY - \(self.pointerString)"
                    constraintToAdd.isActive = true
                    constraintToAdd.constant += y
                    return constraintToAdd
                }
            }
        }
        return nil
    }
    
    func change(xOffset x: CGFloat = 0.0) -> NSLayoutConstraint? {
        if let superview = superview {
            for constraint in superview.constraints {
                if constraint.identifier == "BJConstraintCenterX - \(self.pointerString)" {
                    superview.removeConstraint(constraint)
                    let constraintToAdd = self.centerXAnchor.constraint(equalTo: superview.centerXAnchor)
                    constraintToAdd.identifier = "BJConstraintCenterX - \(self.pointerString)"
                    constraintToAdd.isActive = true
                    constraintToAdd.constant += x
                    return constraintToAdd
                }
            }
        }
        return nil
    }
    
    /**
     
     Adds soft shadow to view.
     
     You need to make the `view.layer.masksToBounds` to `false` for it to work.
     
     - Parameter radius: The blur radius (in points) used to render the layer’s shadow.
     - Parameter opacity: The opacity of the layer’s shadow.
     
     - Author: Badhan Ganesh
     
     */
    @objc func addShadow(withRadius radius: CGFloat = 25, opacity: Float = 0.3) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = .init(width: -2, height: 2)
    }
    
    /**
     You know what it does!
     - Author: Badhan Ganesh
     */
    @objc func roundCorners(amount: CGFloat) {
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.cornerRadius = amount
    }
    
    /**
     You know what it does!
     - Author: Badhan Ganesh
     */
    @objc func setBorder(amount: CGFloat, borderColor: UIColor = .clear, duration: TimeInterval) {
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = amount
    }
    
    /**
     
     This method, even though works for any UIView, is actually applicable to `UILabel`, `UITextView`, `UITextField` and basically any `UIView` descendant that has `text` property to it.
     
     ```
     //Example usages
     
     let textField = UITextField()
     textField.text = "Texttyyy"
     
     let textview1 = UITextView()
     textview1.text = nil
     
     let textview2 = UITextView()
     textview2.text = "Textview text"
     
     let view = UIView()
     
     print(textField.getText() as Any)   /* Optional("Texttyyy") */
     print(textView1.getText() as Any)   /* nil */
     print(textView2.getText() as Any)   /* Optional("Textview text") */
     print(view.getText() as Any)        /* nil */
     ```
     
     - Returns: An optional string value from the `text` property.
     
     - Author: Badhan Ganesh
     
     */
    @objc func getText() -> String? {
        return self.responds(to: #selector(getter: UILabel.text)) ?
        self.perform(#selector(getter: UILabel.text))?.takeUnretainedValue() as? String : nil
    }
    
    /**
     * It is the good old, and long f(d)ucking variable name (`translatesAutoresizingMaskIntoConstraints`).
     *
     * Thanks for reading this 🙃
     *
     * - Author: Badhan Ganesh
     */
    var tarmic: Bool {
        get {
            return translatesAutoresizingMaskIntoConstraints
        }
        set {
            translatesAutoresizingMaskIntoConstraints = newValue
        }
    }
    
    
}

/**
 * Neat little extension to get the memory address of a variable, from this SO answer:
 * https://stackoverflow.com/a/41067053/5912335
 */
extension NSObject {
    
    /**
     * Returns a string representation of the memory address of the object.
     *
     * - Author: Badhan Ganesh
     */
    var pointerString: String {
        return String(format: "%p", self)
    }
    
    /**
     * Tells if the device is in landscape mode.
     *
     * - Author: Badhan Ganesh
     */
    static var deviceIsInLandscape: Bool {
        get {
            return UIDevice.current.orientation.isLandscape ||
            UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
        }
    }
    
    /**
     * Tells if the device is an iPad.
     *
     * - Author: Badhan Ganesh
     */
    static var deviceIsiPad: Bool {
        get {
            return UIDevice.current.userInterfaceIdiom == .pad
        }
    }
    
    /**
     * Tells if the device is running in Mac Catalyst mode.
     *
     * - Author: Badhan Ganesh
     */
    static var deviceIsMacCatalyst: Bool {
        get {
            var isMac = false
            
            if #available(iOS 14.0, *) {
                if UIDevice.current.userInterfaceIdiom == .mac {
                    isMac = true
                }
            } else {
                #if targetEnvironment(macCatalyst)
                    isMac = true
                #endif
            }
            
            return isMac
        }
    }
    
    static var newWidth: CGFloat {
        get {
            var width = 400.0
            
            if deviceIsiPad { return width }
            
            if deviceIsMacCatalyst {
                width = 400.0
            } else {
                width = deviceIsInLandscape ?
                UIScreen.main.bounds.height / 1.3 :
                UIScreen.main.bounds.width / 1.3
            }
            
            return width
        }
    }
    
    static var newHeight: CGFloat {
        get {
            var height = 70.0
            
            if deviceIsiPad { return height }
            
            if deviceIsMacCatalyst {
                height = 70.0
            } else {
                height = deviceIsInLandscape ?
                UIScreen.main.bounds.width / 11.0 :
                UIScreen.main.bounds.height / 11.0
            }
            
            return height
        }
    }
    
    static var deviceIsMacOrIpad: Bool {
        get {
            return NSObject.deviceIsiPad || NSObject.deviceIsMacCatalyst
        }
    }
    
    func doNothing() {}
    
}

extension UILabel {
    open override func updateConstraints() {
        if self.tag == 2245 {
            for constraint in constraints {
                if constraint.identifier == "Width" {
                    constraint.constant = UIScreen.main.bounds.size.width * ( NSObject.deviceIsiPad || NSObject.deviceIsMacCatalyst ? 60 : 80) / 100
                }
            }
        }
        super.updateConstraints()
    }
}


