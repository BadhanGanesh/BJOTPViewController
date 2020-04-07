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
     * - Parameter otp: The full otp string entered.
     * - Parameter viewController: The otp view controller.
     *
     * - Author: Badhan Ganesh
     */
    @objc func authenticate(_ otp: String, from viewController: BJOTPViewController)
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
open class BJOTPViewController: UIViewController {
    
    private var autoFillingFromSMS = false
    private var autoFillBuffer: [String] = []
    private var timeIntervalBetweenKeyStrokes: Date?
    
    private var headingString: String
    private let numberOfOtpCharacters: Int
    private var allTextFields: [BJOTPTextField] = []
    private var textFieldsIndexes: [BJOTPTextField:Int] = [:]
    
    private var closeButton: UIButton?
    private var stackView: UIStackView!
    private var isKeyBoardOn: Bool = false
    private var masterStackView: UIStackView!
    private var keyboardOffset: CGFloat = 0.0
    private var headingTitleLabel: UILabel?
    
    private var footerLabel: UILabel?
    private var primaryHeaderLabel: UILabel?
    private var secondaryHeaderLabel: UILabel?
    private var headerTextsStackView: UIStackView?
    
    private var authenticateButton: BJOTPAuthenticateButton!
    private var masterStackViewCenterYConstraint: NSLayoutConstraint!
    
    /**
     * The delegate object that is responsible for performing the actual authentication/verification process (with server via api call or whatever)
     *
     * - Author: Badhan Ganesh
     */
    @objc public var delegate: BJOTPViewControllerDelegate?
    
    /**
     * Setting this to true opens up the keyboard for the very first text field.
     *
     * Default is `false`. Consider the `hideLabelsWhenEditing` property when setting this one to `true`, because when the keyboard is open as soon as the view controller is presented/pushed, if `hideLabelsWhenEditing` is `true`, the labels will be hidden initially as a result, and the user won't even know that the labels exist. It will be a better user experience if the user sees the labels initially since it guides them what to do. Choose wisely.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var openKeyboadDuringStartup: Bool = false
    
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
    @objc public var currentTextFieldColor: UIColor?
    
    /**
     * The color of the authenticate button.
     *
     * Settings this color will override the `accentColor`.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var authenticateButtonColor: UIColor?
    
    /**
     * The title of the authenticate button.
     *
     * Settings this color will override the `accentColor`.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var authenticateButtonTitle: String = "AUTHENTICATE"
    
    /**
     * The title of the primary header which stays above the OTP textfields.
     *
     * This is optional. In case of nil, the label won't be constructed at all. So make sure to set a string, or leave it as it is (`nil`). Changing this value after presenting or pushing `BJOTPViewController` won't have an effect; the label won't be constructed.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var primaryHeaderTitle: String?
    
    /**
     * The title of the secondary header which comes below the primary header.
     *
     * This is optional. In case of nil, the label won't be constructed at all. So make sure to set a string, or leave it as it is (`nil`). Changing this value after presenting or pushing `BJOTPViewController` won't have an effect; the label won't be constructed.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var secondaryHeaderTitle: String?
    
    /**
     * The title of the footer label which comes below the authenticate button.
     *
     * This is optional. In case of nil, the label won't be constructed at all. So make sure to set a string, or leave it as it is (`nil`). Changing this value after presenting or pushing `BJOTPViewController` won't have an effect; the label won't be constructed.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var footerTitle: String?
    
    /**
     * Set whether the primary, secondary, and footer labels are to be hidden during editing, i.e., when the keyboard is open.
     *
     * Default is `false`
     *
     * - Author: Badhan Ganesh
     */
    @objc public var hideLabelsWhenEditing: Bool = false
    
    @objc public init(withHeading heading: String = "One Time Password",
                      withNumberOfCharacters numberOfOtpCharacters: Int,
                      delegate: BJOTPViewControllerDelegate) {
        self.delegate = delegate
        self.headingString = heading
        self.numberOfOtpCharacters = numberOfOtpCharacters
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.configureKeyboardNotifications()
        self.constructUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func authenticateButtonTapped(_ sender: UIButton) {
        var otpString = ""
        let numberOfEmptyTextFields: Int = allTextFields.reduce(0, { emptyTextsCount, textField in
            otpString += textField.text!
            return(textField.text ?? "") == "" ? emptyTextsCount + 1 : emptyTextsCount
        })
        if numberOfEmptyTextFields > 0 { return }
        self.view.endEditing(true)
        self.delegate?.authenticate(otpString, from: self)
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.headingTitleLabel?.numberOfLines = NSObject.deviceIsInLandscape ? 1 : 2
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: self.view, animation: { (coord) in
            let titleLabelHeight = (self.headingTitleLabel?.bounds.height ?? 0) / (NSObject.deviceIsInLandscape ? 1 : 2)
            let value = (titleLabelHeight - (self.headingTitleLabel == nil ? (-(self.navBarHeight + NSObject.statusBarHeight) / 2) : 25))
            self.masterStackViewCenterYConstraint = self.masterStackView.change(yOffset: value - self.keyboardOffset)
            self.primaryHeaderLabel?.sizeToFit()
            self.secondaryHeaderLabel?.sizeToFit()
            self.footerLabel?.sizeToFit()
            self.view.layoutIfNeeded()
        }, completion: nil)
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
        if ((string == "" || string == " ") && range.length == 0) {
            if string == "" {
                if let oldInterval = timeIntervalBetweenKeyStrokes {
                    if Date().timeIntervalSince(oldInterval) < 0.05 {
                        self.autoFillingFromSMS = true
                        timeIntervalBetweenKeyStrokes = nil
                    }
                }
                timeIntervalBetweenKeyStrokes = Date()
            }
            return false
        }
        
        ///Use this condition to determine if text is pasted.
        if string.count > 1 {
            ///If the string is of the same length as the number of otp characters, then we proceed to
            ///fill all the text fields with the characters
            if string.count == numberOfOtpCharacters {
                for (idx, element) in string.enumerated() {
                    allTextFields[idx].text = String(element)
                }
                textField.resignFirstResponder()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.delegate?.authenticate(string, from: self)
                }
                ///If the replacing string is of 1 character length, then we just allow it to be replaced
                ///and set the responder to be the next text field
            } else if string.count == 1 {
                setNextResponder(textFieldsIndexes[textField as! BJOTPTextField], direction: .right)
                textField.text = string
            }
        } else {
            if autoFillingFromSMS {
                self.masterStackView.layoutIfNeeded()
                var finalOTP = ""
                autoFillBuffer.append(string)
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(BJOTPViewController.checkOtpFromMessagesCount), object: nil)
                self.perform(#selector(BJOTPViewController.checkOtpFromMessagesCount), with: nil, afterDelay: 0.1)
                if autoFillBuffer.count == numberOfOtpCharacters {
                    for (idx, element) in autoFillBuffer.enumerated() {
                        let otpChar = String(element)
                        finalOTP += otpChar
                        allTextFields[idx].text = otpChar
                    }
                    textField.resignFirstResponder()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.delegate?.authenticate(finalOTP, from: self)
                    }
                    autoFillingFromSMS = false
                    autoFillBuffer.removeAll()
                }
                return false
            }
            if range.length == 0 {
                textField.text = string
                setNextResponder(textFieldsIndexes[textField as! BJOTPTextField], direction: .right)
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
        var otpString = ""
        let numberOfEmptyTextFields: Int = allTextFields.reduce(0, { emptyTextsCount, textField in
            otpString += textField.text!
            return (textField.text ?? "").isEmpty ? emptyTextsCount + 1 : emptyTextsCount
        })
        if numberOfEmptyTextFields > 0 { return }
        if let delegate = delegate {
            delegate.authenticate(otpString, from: self)
        } else {
            fatalError("Delegate is nil in BJTOPViewController.")
        }
    }
    
    /**
     * This method detects if the auto-filled code from SMS is less than that of the allowed number of characters.
     *
     * This checking needs to be done to come to a conclusion on when to populate the code (stored in `autoFillBuffer`) in text fields from SMS. Also this checking has to be done becuase of not allowing iOS to auto-fill the code, and we're doing it manually ourselves.
     *
     */
    @objc private func checkOtpFromMessagesCount() {
        if autoFillBuffer.count < numberOfOtpCharacters {
            autoFillingFromSMS = false
            autoFillBuffer.removeAll()
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
        
        /// All of the below UI code is strictly order-sensitive and tightly coupled to their previous elements' layout.
        /// Be careful and try not to change the order of the stuffs. Each UI element is laid out one by one,
        /// piece by piece to work correctly.
        
        /// 1. Layout Heading title lablel in case of navigation bar
        title = headingString
        
        /// 2. Setup textfields
        configureOTPTextFields()
        
        /// 3. Layout Heading title lablel in case of no navigation bar
        layoutHeadingLabel()
        
        /// 4. Layout all stackviews and its contents
        layoutAllStackViewsWith(allTextFields)
        
        /// 5. Make first text field the first responder or not based on the `openKeyboadDuringStartup` attribute
        self.openKeyboadDuringStartup ? (_ = allTextFields.first?.becomeFirstResponder()) : doNothing()
        
        /// 6. Save the centerY constraint of stack container view for offsetting its position for keyboard position
        saveMasterStackViewYConstraint()
        
        /// 7. Layout close button at the bottom
        layoutBottomCloseButton()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .otpVcBackgroundColor
        } else {
            view.backgroundColor = .white
        }
        
    }
    
    fileprivate func layoutBottomCloseButton() {
        if self.navigationController == nil {
            self.view.layoutIfNeeded()
            let closeButton = UIButton.init(type: .custom)
            closeButton.frame = .init(origin: .zero, size: .init(width: self.masterStackView.bounds.width, height: 40))
            closeButton.tarmic = false
            closeButton.setTitle("CLOSE", for: .normal)
            closeButton.showsTouchWhenHighlighted = true
            closeButton.setTitleColor(self.authenticateButtonColor ?? self.accentColor, for: .normal)
            closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.5, weight: .bold).normalized()
            closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            
            self.view.addSubview(closeButton)
            closeButton.pinTo(.bottomMiddle)
            self.closeButton = closeButton
        }
    }
    
    fileprivate func saveMasterStackViewYConstraint() {
        self.masterStackView.superview?.constraints.forEach { (constraint) in
            if constraint.identifier?.contains("BJConstraintCenterY - \(self.masterStackView.pointerString)") ?? false {
                self.masterStackViewCenterYConstraint = constraint
            }
        }
    }
    
    fileprivate func configureOTPTextFields() {
        ///Create text fields for laying out in stackview
        for _ in 0 ..< numberOfOtpCharacters { allTextFields.append(otpTextField()) }
        for idx in 0 ..< allTextFields.count { textFieldsIndexes[allTextFields[idx]] = idx }
    }
    
    @discardableResult fileprivate func otpTextField() -> BJOTPTextField {
        
        let textField = BJOTPTextField()
        
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
        
        textField.tarmic = false
        textField.delegate = self
        textField.textColor = .black
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.roundCorners(amount: 4)
        textField.backgroundColor = .white
        textField.isSecureTextEntry = true
        textField.keyboardType = .numberPad
        textField.setBorder(amount: 1.8, borderColor: UIColor.lightGray.withAlphaComponent(0.28), duration: 0.09)
        textField.widthAnchor.constraint(equalToConstant: NSObject.newWidth).isActive = numberOfOtpCharacters == 1
        textField.heightAnchor.constraint(equalTo: textField.widthAnchor, multiplier: 1.0).isActive = true
        
        return textField
    }
    
    fileprivate func layoutHeadingLabel() {
        
        if (self.navigationController?.isNavigationBarHidden ?? true) {
            
            let headingTitle = UILabel()
            headingTitle.tarmic = false
            headingTitle.tag = 2245
            headingTitle.numberOfLines = 2
            headingTitle.textAlignment = .center
            headingTitle.text = self.headingString
            headingTitle.adjustsFontSizeToFitWidth = true
            headingTitle.font = UIFont.systemFont(ofSize: 32, weight: .heavy).normalized()
            
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
            
            self.headingTitleLabel = headingTitle
            
        }
    }
    
    fileprivate func layoutPrimaryHeaderLabel() {
        if let _ = primaryHeaderTitle {
            let primaryHeaderLabel = UILabel()
            primaryHeaderLabel.adjustsFontForContentSizeCategory = true
            
            let headlineFontMetric = UIFontMetrics.init(forTextStyle: .headline)
            let primaryHeaderLabelFont = headlineFontMetric.scaledFont(for: .systemFont(ofSize: 21, weight: .bold))
            primaryHeaderLabel.font = primaryHeaderLabelFont
            
            primaryHeaderLabel.setContentHuggingPriority(.init(1000), for: .vertical)
            primaryHeaderLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
            primaryHeaderLabel.lineBreakMode = .byTruncatingMiddle
            primaryHeaderLabel.textAlignment = .center
            primaryHeaderLabel.numberOfLines = 0
            primaryHeaderLabel.text = self.primaryHeaderTitle
            primaryHeaderLabel.widthAnchor.constraint(equalToConstant: NSObject.newWidth).isActive = true
            self.primaryHeaderLabel = primaryHeaderLabel
        }
    }
    
    fileprivate func layoutSecondaryHeaderLabel() {
        if let _ = secondaryHeaderTitle {
            let secondaryHeaderLabel = UILabel()
            if #available(iOS 13.0, *) {
                secondaryHeaderLabel.textColor = .secondaryLabel
            } else {
                secondaryHeaderLabel.textColor = UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.6)
            }
            secondaryHeaderLabel.adjustsFontForContentSizeCategory = true
            secondaryHeaderLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
            secondaryHeaderLabel.setContentHuggingPriority(.init(1000), for: .vertical)
            secondaryHeaderLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
            secondaryHeaderLabel.lineBreakMode = .byTruncatingMiddle
            secondaryHeaderLabel.textAlignment = .center
            secondaryHeaderLabel.numberOfLines = 0
            secondaryHeaderLabel.text = self.secondaryHeaderTitle
            secondaryHeaderLabel.widthAnchor.constraint(equalToConstant: NSObject.newWidth).isActive = true
            self.secondaryHeaderLabel = secondaryHeaderLabel
        }
    }
    
    fileprivate func layoutFooterLabel() {
        if let _ = footerTitle {
            let footerLabel = UILabel()
            footerLabel.adjustsFontForContentSizeCategory = true
            
            let captionFontMetric = UIFontMetrics.init(forTextStyle: .caption2)
            let footerLabelFont = captionFontMetric.scaledFont(for: .systemFont(ofSize: 9, weight: .regular))
            
            footerLabel.font = footerLabelFont
            if #available(iOS 13.0, *) {
                footerLabel.textColor = UIColor.secondaryLabel.withAlphaComponent(0.4)
            } else {
                footerLabel.textColor = UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.6).withAlphaComponent(0.4)
            }
            footerLabel.setContentHuggingPriority(.init(1000), for: .vertical)
            footerLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
            footerLabel.lineBreakMode = .byTruncatingMiddle
            footerLabel.textAlignment = .center
            footerLabel.numberOfLines = 0
            footerLabel.text = self.footerTitle
            self.footerLabel = footerLabel
        }
    }
    
    fileprivate func layoutStackViewForHeaderLabels() {
        if let _ = self.primaryHeaderLabel, let _ = self.secondaryHeaderLabel {
            let headerTextsStackView = UIStackView(arrangedSubviews: [self.primaryHeaderLabel, self.secondaryHeaderLabel].compactMap { view in view } )
            headerTextsStackView.axis = .vertical
            headerTextsStackView.spacing = -2
            headerTextsStackView.alignment = .center
            headerTextsStackView.distribution = .fill
            self.headerTextsStackView = headerTextsStackView
        }
    }
    
    fileprivate func layoutAuthenticateButtonWith(sibling view: UIView) {
        
        let authenticateButton = BJOTPAuthenticateButton.init()
        authenticateButton.tarmic = false
        authenticateButton.roundCorners(amount: 6.0)
        authenticateButton.setTitle(self.authenticateButtonTitle, for: .normal)
        
        let authenticateButtonFontMetric = UIFontMetrics.init(forTextStyle: .headline)
        let authenticateButtonFont = authenticateButtonFontMetric.scaledFont(for: .boldSystemFont(ofSize: 14.5))
        
        authenticateButton.titleLabel?.adjustsFontForContentSizeCategory = true
        authenticateButton.titleLabel?.lineBreakMode = .byTruncatingTail
        authenticateButton.titleLabel?.font = authenticateButtonFont
        authenticateButton.backgroundColor = self.authenticateButtonColor ?? self.accentColor
        authenticateButton.addTarget(self, action: #selector(authenticateButtonTapped(_:)), for: .touchUpInside)
        
        authenticateButton.heightAnchor.constraint(equalToConstant: (NSObject.newHeight * (NSObject.deviceIsiPad ? 90 : 75)) / 100).isActive = true
        self.authenticateButton = authenticateButton
    }
    
    fileprivate func layoutOTPStackViewWith(_ subviews: [UIView]) {
        let otpStackView = UIStackView.init(arrangedSubviews: subviews)
        otpStackView.tag = 234
        otpStackView.spacing = 12
        otpStackView.alignment = .fill
        otpStackView.distribution = .fill
        otpStackView.widthAnchor.constraint(equalToConstant: NSObject.newWidth).isActive = numberOfOtpCharacters >= 5
        otpStackView.heightAnchor.constraint(equalToConstant: NSObject.newHeight).isActive = numberOfOtpCharacters < 5
        self.stackView = otpStackView
    }
    
    fileprivate func layoutMasterStackView() {
        let titleLabelHeight = (self.headingTitleLabel?.intrinsicContentSize.height ?? 0)
        let value = titleLabelHeight -
            (self.headingTitleLabel == nil ?
                (-(self.navBarHeight + NSObject.statusBarHeight) / 2) : 25)
        
        let masterStackView = UIStackView(arrangedSubviews: [self.headerTextsStackView, self.stackView, self.authenticateButton, self.footerLabel].compactMap { view in view } )
        masterStackView.axis = .vertical
        masterStackView.spacing = 10
        masterStackView.alignment = .center
        masterStackView.distribution = .fill
        self.view.addSubview(masterStackView)
        masterStackView.pinTo(.middle, yOffset: value)
        self.masterStackView = masterStackView
    }
    
    fileprivate func layoutAllStackViewsWith(_ subviews: [UIView]) {
        layoutOTPStackViewWith(subviews)
        layoutPrimaryHeaderLabel()
        layoutSecondaryHeaderLabel()
        layoutFooterLabel()
        layoutStackViewForHeaderLabels()
        layoutAuthenticateButtonWith(sibling: self.stackView)
        layoutMasterStackView()
        self.stackView.layoutIfNeeded()
        self.authenticateButton.widthAnchor.constraint(equalToConstant: self.stackView.bounds.width).isActive = true
        self.footerLabel?.widthAnchor.constraint(equalToConstant: self.stackView.bounds.width).isActive = true
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
        /**
         * Need this delay for the UI to finish being laid out
         * to check if the keyboard is obscuring the button or not initially.
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.offsetForKeyboardPosition(notification as NSNotification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.resetToDefaultOffsetForKeyboardPosition(notification as NSNotification)
        }
    }
    
    fileprivate func offsetForKeyboardPosition(_ notification: NSNotification) {
        
        var keyboardFrameEndKey = ""
        
        #if swift(>=5.0)
        keyboardFrameEndKey = UIResponder.keyboardFrameEndUserInfoKey
        #elseif swift(<5.0)
        keyboardFrameEndKey = UIKeyboardFrameEndUserInfoKey
        #endif
        
        self.isKeyBoardOn = true
        let window = UIApplication.shared.windows.first
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[keyboardFrameEndKey] as! NSValue).cgRectValue
        let authButtonMaxY = self.masterStackView.convert(self.authenticateButton.frame, to: window).maxY
        let keyboardMinY = keyboardFrame.origin.y
        
        ///Means the keyboard overlaps the auth button
        if authButtonMaxY > keyboardMinY {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [.curveEaseIn, .curveEaseOut], animations: {
                self.keyboardOffset = (authButtonMaxY - keyboardMinY + (NSObject.self.deviceIsiPad ? 10 : 5))
                self.masterStackViewCenterYConstraint.constant -= self.keyboardOffset
                self.setLabelsAlpha(0.0)
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    fileprivate func resetToDefaultOffsetForKeyboardPosition(_ notification: NSNotification) {
        
        var keyboardFrameEndKey = ""
        
        #if swift(>=5.0)
        keyboardFrameEndKey = UIResponder.keyboardFrameEndUserInfoKey
        #elseif swift(<5.0)
        keyboardFrameEndKey = UIKeyboardFrameEndUserInfoKey
        #endif
        
        if isKeyBoardOn {
            
            self.isKeyBoardOn = false
            let window = UIApplication.shared.windows.first
            let userInfo = (notification as NSNotification).userInfo!
            let keyboardFrame = (userInfo[keyboardFrameEndKey] as! NSValue).cgRectValue
            let authButtonLocalY = self.masterStackView.convert(self.authenticateButton.frame, to: window).maxY
            let keyboardLocalY = keyboardFrame.origin.y
            let keyboardLocalHeight = window?.convert(keyboardFrame, to: self.view).height ?? 0
            
            if keyboardLocalHeight >= CGFloat(0) ||
                authButtonLocalY >= (keyboardLocalY - self.keyboardOffset) {
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [.curveEaseIn, .curveEaseOut], animations: {
                    self.masterStackViewCenterYConstraint.constant += self.keyboardOffset
                    self.keyboardOffset = 0.0
                    self.setLabelsAlpha(1.0)
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    fileprivate func setLabelsAlpha(_ value: CGFloat) {
        if value == 0 {
            if !NSObject.deviceIsInLandscape {
                return
            }
        }
        let finalAlpha = value == 0.0 ? hideLabelsWhenEditing ? value : 1.0 : value
        self.headingTitleLabel?.alpha = value
        self.primaryHeaderLabel?.alpha = finalAlpha
        self.secondaryHeaderLabel?.alpha = finalAlpha
        self.footerLabel?.alpha = finalAlpha
    }
    
}

extension BJOTPViewController {
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [.curveEaseIn, .curveEaseOut], animations: {
            self.masterStackViewCenterYConstraint.constant += self.keyboardOffset
            self.keyboardOffset = 0.0
            self.setLabelsAlpha(1.0)
            self.view.layoutIfNeeded()
        }, completion: nil)
        self.view.endEditing(true)
    }
}

extension UILabel {
    open override func updateConstraints() {
        if self.tag == 2245 {
            for constraint in constraints {
                if constraint.identifier == "Width" {
                    constraint.constant = UIScreen.main.bounds.size.width * ( NSObject.deviceIsiPad ? 60 : 80) / 100
                }
            }
        }
        super.updateConstraints()
    }
}

extension NSObject {
    func doNothing() {}
}
