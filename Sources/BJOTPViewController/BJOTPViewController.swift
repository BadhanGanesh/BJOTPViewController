//
//  BJOTPViewController.swift
//  bjotpviewcontroller
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright © 2019 Badhan Ganesh
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

@objc public protocol BJOTPViewControllerDelegate {
    
    /**
     * Use this delegate method to make API calls, show loading animation in `viewController`, do whatever you want.
     * You can dismiss (if presented) the `viewController` when you're done.
     *
     * This method will get called only after the validation is successful, i.e., after the user has filled all the text fields.
     *
     * - Parameter viewController: The otp view controller.
     *
     * - Author: Badhan Ganesh
     */
    @objc func authenticate(from viewController: BJOTPViewController)
}

/**
 * A simple and neat-looking view controller that lets you type in OTP's quick and easy.
 *
 * This is intended to be a drag and drop view controller that gets the work done quickly, in and out, that's it. No fancy customizations, no cluttering the screen with tons of UI elements and crazy colors. You'll be good to go with the default settings.
 *
 * * Supports dark mode.
 * * Supports iOS and iPadOS.
 * * Supports portrait and landscape modes.
 *
 * - Author: Badhan Ganesh
 */
public class BJOTPViewController: UIViewController {
    
    /**
     * The delegate object that is responsible for performing the actual authentication/verification process (with server via api call or whatever)
     *
     * - Author: Badhan Ganesh
     */
    private var delegate: BJOTPViewControllerDelegate? = nil
    
    private var closeButton: UIButton!
    private var stackView: UIStackView!
    private var isKeyBoardOn: Bool = false
    private var keyboardOffset: CGFloat = 0.0
    private var headingTitleLabel: UILabel? = nil
    private var authenticateButton: BJOTPAuthenticateButton!
    private var containerViewForStackView: BJOTPStackViewContainerView!
    private var stackContainerViewCenterYConstraint: NSLayoutConstraint!
    
    /**
     * The color that will be used overall for the UI elements. Set this if you want a common color to be used in the view controller instead of worrying about each UI element's color.
     *
     * Separate colors can also be used for each UI element as allowed by the view controller (via public properties), which will override this property (`accentColor`). Default is `UIColor.systemBlue`
     *
     * - Author: Badhan Ganesh
     */
    @objc public var accentColor: UIColor = .systemBlue
    
    /**
     * The currently focused text field color. This color will appear faded (less opacity) to look good instead of a being saturated.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var currentTextFieldColor: UIColor? = nil
    
    /**
     * The color of the authenticate button.
     *
     * Settings this color will override the `accentColor`.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var authenticateButtonColor: UIColor? = nil
    
    /**
     * The title of the authenticate button.
     *
     * Settings this color will override the `accentColor`.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var authenticateButtonTitle: String = "AUTHENTICATE"
    
    private var headingString: String
    private let numberOfOtpCharacters: Int
    private var allTextFields: [BJOTPTextField] = []
    private var textFieldsIndexes: [BJOTPTextField:Int] = [:]
    
    
    @objc public init(withHeading heading: String = "One Time Password",
                      withNumberOfCharacters numberOfOtpCharacters: Int,
                      delegate: BJOTPViewControllerDelegate) {
        self.delegate = delegate
        self.headingString = heading
        self.numberOfOtpCharacters = numberOfOtpCharacters
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.constructUI()
        self.configureKeyboardNotifications()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func authenticateButtonTapped(_ sender: UIButton) {
        let numberOfEmptyTextFields: Int = allTextFields.reduce(0, { emptyTextsCount, textField in
            return(textField.text ?? "") == "" ? emptyTextsCount + 1 : emptyTextsCount
        })
        if numberOfEmptyTextFields > 0 { return }
        self.delegate?.authenticate(from: self)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            self?.containerViewForStackView.setNeedsUpdateConstraints()
        })
    }
    
}

////////////////////////////////////////////////////////////////
//MARK:-
//MARK: UITextField Delegate Methods
//MARK:-
////////////////////////////////////////////////////////////////

extension BJOTPViewController: UITextFieldDelegate {
    
    enum Direction { case left, right }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count > self.numberOfOtpCharacters { return false }
        
        if ((string == "" || string == " ") && range.length == 0) { return false }
        
        ///Checking if the string is the same the content that is present in clipboard.
        ///Use this condition to determine if text is copy-pasted.
        if string == UIPasteboard.general.string ?? "<empty-clipboard>" {
            ///If the string is of the same length as the number of otp characters, then we proceed to
            ///fill all the text fields with the characters
            if string.count == numberOfOtpCharacters {
                for (idx, element) in string.enumerated() {
                    allTextFields[idx].text = String(element)
                }
                textField.resignFirstResponder()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.delegate?.authenticate(from: self)
                }
                ///If the replacing string is of 1 character length, then we just allow it to be replaced
                ///and set the responder to be the next text field
            } else if string.count == 1 {
                setNextResponder(textFieldsIndexes[textField as! BJOTPTextField], direction: .right)
                textField.text = string
            }
        } else {
            if range.length == 0 {
                setNextResponder(textFieldsIndexes[textField as! BJOTPTextField], direction: .right)
                textField.text = string
            } else if range.length == 1 {
                setNextResponder(textFieldsIndexes[textField as! BJOTPTextField], direction: string.isEmpty ? .left : .right)
                textField.text = string.isEmpty ? "" : string
            }
        }
        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.roundCorners(amount: 4)
        textField.setBorder(amount: 3, borderColor: (currentTextFieldColor ?? accentColor).withAlphaComponent(0.4), duration: 0.09)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setBorder(amount: 1.8, borderColor: UIColor.lightGray.withAlphaComponent(0.3), duration: 0.09)
    }
    
    private func setNextResponder(_ index:Int?, direction:Direction) {
        
        guard let index = index else { return }
        
        if direction == .left {
            index == 0 ?
                (self.resignFirstResponder(textField: allTextFields.first)) :
                (_ = allTextFields[(index - 1)].becomeFirstResponder())
        } else {
            index == numberOfOtpCharacters - 1 ?
                (self.resignFirstResponder(textField: allTextFields.last)) :
                (_ = allTextFields[(index + 1)].becomeFirstResponder())
        }
        
    }
    
    private func resignFirstResponder(textField: BJOTPTextField?) {
        
        textField?.resignFirstResponder()
        
        let numberOfEmptyTextFields: Int = allTextFields.reduce(0, { emptyTextsCount, textField in
            return (textField.text ?? "").isEmpty ? emptyTextsCount + 1 : emptyTextsCount
        })
        
        if numberOfEmptyTextFields != 1 { return }
        
        if let delegate = delegate {
            delegate.authenticate(from: self)
        } else {
            fatalError("Delegate is nil in BJTOPViewController.")
        }
    }
    
}

////////////////////////////////////////////////////////////////
//MARK:-
//MARK: UI Construction Extensions
//MARK:-
////////////////////////////////////////////////////////////////

extension BJOTPViewController {
    
    internal func constructUI() {
        
        /// 1. Layout Heading title lablel in case of navigation bar
        title = headingString
        
        /// 2. Setup textfields
        setupTextFields()
        
        /// 3. Layout Heading title lablel in case of no navigation bar
        headingTitleLabel = layoutHeadingLabel()
        
        /// 4. Layout Enclosing view (superview) of stackview
        containerViewForStackView = layoutEnclosingViewForStackView()
        
        /// 5. Layout Stackview
        stackView = layoutStackView(subviews: allTextFields, inside: containerViewForStackView)
        
        /// 6. Layout Enclosing view (superview) of stackview
        authenticateButton = layoutAuthenticateButton(siblingView: containerViewForStackView)
        
        /// 7. Make first text field the first responder
        allTextFields.first?.becomeFirstResponder()
        
        /// 8. Set View Controller view's background color
        if #available(iOS 13.0, *) {
            view.backgroundColor = .otpVcBackgroundColor
        } else {
            view.backgroundColor = .white
        }
        
        /// 9. Save the centerY constraint of stack container view
        saveStackContainerViewConstraint()

    }
    
    fileprivate func saveStackContainerViewConstraint() {
        self.containerViewForStackView.superview?.constraints.forEach { (constraint) in
            if constraint.identifier == "BJConstraintCenterY" {
                self.stackContainerViewCenterYConstraint = constraint
            }
        }
    }
    
    fileprivate func setupTextFields() {
        ///Create text fields for laying out in stackview
        for _ in 0 ..< numberOfOtpCharacters { allTextFields.append(otpTextField()) }
        for idx in 0 ..< allTextFields.count { textFieldsIndexes[allTextFields[idx]] = idx }
    }
    
    @discardableResult fileprivate func otpTextField() -> BJOTPTextField {
        
        let textField = BJOTPTextField()
        textField.tarmic = false
        textField.delegate = self
        textField.textColor = .black
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.roundCorners(amount: 4)
        textField.backgroundColor = .white
        textField.isSecureTextEntry = true
        textField.keyboardType = .numberPad
        textField.setBorder(amount: 1.8, borderColor: UIColor.lightGray.withAlphaComponent(0.3), duration: 0.09)
        textField.heightAnchor.constraint(equalTo: textField.widthAnchor, multiplier: 1.0).isActive = true
        
        return textField
    }
    
    @discardableResult fileprivate func layoutHeadingLabel() -> UILabel? {
        
        if (self.navigationController?.isNavigationBarHidden ?? true) {
            
            let headingTitle = UILabel()
            headingTitle.tarmic = false
            headingTitle.tag = 2245
            headingTitle.numberOfLines = 2
            headingTitle.textAlignment = .center
            headingTitle.text = self.headingString
            headingTitle.font = UIFont.systemFont(ofSize: 30, weight: .heavy).normalized()
            
            self.view.addSubview(headingTitle)
            
            if #available(iOS 11.0, *) {
                headingTitle.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
            } else {
                headingTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25).isActive = true
            }
            
            headingTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            
            let widthConstraint = headingTitle.widthAnchor.constraint(equalToConstant: self.view.frame.size.width * 85 / 100)
            widthConstraint.identifier = "Width"
            
            headingTitle.addConstraint(widthConstraint)
            
            return headingTitle
        }
        
        return nil
    }
    
    @discardableResult fileprivate func layoutEnclosingViewForStackView() -> BJOTPStackViewContainerView {
        
        let view = BJOTPStackViewContainerView()
        view.tarmic = false
        view.tag = 1423
        view.backgroundColor = .clear
        
        self.view.addSubview(view)
        
        let widthConstraint = view.widthAnchor.constraint(equalToConstant: view.newWidth)
        widthConstraint.identifier = "Width_Constraint"
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: view.newHeight)
        heightConstraint.identifier = "Height_Constraint"
        
        view.addConstraints([widthConstraint, heightConstraint])
        
        view.pinTo(.middle, yOffset: -30)
        
        return view
    }
    
    @discardableResult fileprivate func layoutStackView(subviews: [UIView], inside superview: UIView) -> UIStackView {
        
        let stackView = UIStackView.init(arrangedSubviews: subviews)
        stackView.tag = 234
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        superview.addSubview(stackView)
        stackView.pinTo(.middle, shouldRespectSafeArea: false)
        stackView.widthAnchor.constraint(equalToConstant: (superview as! BJOTPStackViewContainerView).newWidth).isActive = numberOfOtpCharacters > 5
        stackView.heightAnchor.constraint(equalToConstant: (superview as! BJOTPStackViewContainerView).newHeight).isActive = numberOfOtpCharacters < 5
        
        return stackView
    }
    
    @discardableResult fileprivate func layoutAuthenticateButton(siblingView: UIView) -> BJOTPAuthenticateButton {
        
        let authenticateButton = BJOTPAuthenticateButton.init()
        authenticateButton.tarmic = false
        authenticateButton.roundCorners(amount: 6.0)
        authenticateButton.setTitle(self.authenticateButtonTitle, for: .normal)
        authenticateButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.5, weight: .bold).normalized()
        authenticateButton.titleLabel?.adjustsFontSizeToFitWidth = true
        authenticateButton.backgroundColor = self.authenticateButtonColor ?? self.accentColor
        authenticateButton.addTarget(self, action: #selector(authenticateButtonTapped(_:)), for: .touchUpInside)
        
        self.view.addSubview(authenticateButton)
        
        authenticateButton.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
        authenticateButton.heightAnchor.constraint(equalToConstant: ((siblingView as! BJOTPStackViewContainerView).newHeight * (deviceIsiPad ? 90 : 75)) / 100).isActive = true
        authenticateButton.centerXAnchor.constraint(equalTo: siblingView.centerXAnchor).isActive = true
        authenticateButton.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 15).isActive = true
        
        return authenticateButton
    }
    
    @discardableResult fileprivate func layoutCloseButton() -> UIButton {
        
        let closeButton = UIButton.init(type: .custom)
        closeButton.frame = .init(origin: .zero, size: .init(width: 60, height: 40))
        closeButton.tarmic = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(self.authenticateButtonColor ?? self.accentColor, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.5, weight: .bold).normalized()
        
        self.view.addSubview(closeButton)
        closeButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        closeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true

        return closeButton
    }
    
}

extension UILabel {
    open override func updateConstraints() {
        if self.tag == 2245 {
            for constraint in constraints {
                if constraint.identifier == "Width" {
                    constraint.constant = UIScreen.main.bounds.size.width * ( deviceIsiPad ? 60 : 80) / 100
                }
            }
        }
        super.updateConstraints()
    }
}

////////////////////////////////////////////////////////////////
//MARK:-
//MARK: Keyboard Handling Extensions
//MARK:-
////////////////////////////////////////////////////////////////

extension BJOTPViewController {
    
    fileprivate func configureKeyboardNotifications() {
        #if swift(>=5.0)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        #elseif swift(<5.0)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        #endif
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.offsetForKeyboardPosition(notification as NSNotification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.resetToDefaultOffsetKeyboardPosition(notification as NSNotification)
    }
    
    fileprivate func offsetForKeyboardPosition(_ notification: NSNotification) {
        
        var keyboardFrameEndKey = ""
        
        #if swift(>=5.0)
        keyboardFrameEndKey = UIResponder.keyboardFrameEndUserInfoKey
        #elseif swift(<5.0)
        keyboardFrameEndKey = UIKeyboardFrameEndUserInfoKey
        #endif
        
        self.isKeyBoardOn = true
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[keyboardFrameEndKey] as! NSValue).cgRectValue
        let keyboardLocalCoordinatesFrame = UIApplication.shared.windows.first?.convert(keyboardFrame, to: self.view)
        
        ///Means the keyboard overlaps the auth button
        if (self.authenticateButton.frame.maxY) > keyboardLocalCoordinatesFrame?.origin.y ?? 0 {
            UIView.animate(withDuration: 0.3) {
                if self.keyboardOffset == 0 {
                    self.keyboardOffset = self.deviceIsiPad ? 110 : 50
                    self.stackContainerViewCenterYConstraint.constant -= self.keyboardOffset
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    fileprivate func resetToDefaultOffsetKeyboardPosition(_ notification: NSNotification) {
        
        var keyboardFrameBeginKey = ""
        
        #if swift(>=5.0)
        keyboardFrameBeginKey = UIResponder.keyboardFrameBeginUserInfoKey
        #elseif swift(<5.0)
        keyboardFrameBeginKey = UIKeyboardFrameBeginUserInfoKey
        #endif
        
        if isKeyBoardOn {
            
            self.isKeyBoardOn = false
            
            let userInfo = notification.userInfo!
            let keyboardFrame: CGRect = (userInfo[keyboardFrameBeginKey] as! NSValue).cgRectValue
            let keyboardLocalCoordinatesFrame = UIApplication.shared.windows.first?.convert(keyboardFrame, to: self.view)
            
            guard (keyboardLocalCoordinatesFrame?.size.height ?? 0) > CGFloat(0) else {
                UIView.animate(withDuration: 0.3) {
                    self.stackContainerViewCenterYConstraint.constant += self.keyboardOffset
                    self.keyboardOffset = 0.0
                    self.view.layoutIfNeeded()
                }
                return
            }
            
            if (self.authenticateButton.frame.maxY) >= ((keyboardLocalCoordinatesFrame?.origin.y ?? 0) - 40) {
                UIView.animate(withDuration: 0.3) {
                    self.stackContainerViewCenterYConstraint.constant += self.keyboardOffset
                    self.keyboardOffset = 0.0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
}

extension BJOTPViewController {
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.3) {
            self.stackContainerViewCenterYConstraint.constant += self.keyboardOffset
            self.keyboardOffset = 0.0
            self.view.layoutIfNeeded()
        }
        self.view.endEditing(true)
    }
}
