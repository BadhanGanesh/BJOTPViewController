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
     * This method gets called when the user has entered all the otp characters and tapped the button.
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
    
    /**
     * This method will get called whenever the otp view controller is closed, either by popping, dismissing, or tapping the close button.
     *
     * Use this to invalidate any timers, do clean-ups, etc..
     *
     * - Parameter viewController: The otp view controller.
     *
     * - Author: Badhan Ganesh
     */
    @objc func didClose(_ viewController: BJOTPViewController)
    
    /**
     * This delegate method will get called when the footer button at the bottom is tapped. Use this to resend one time code from the server
     *
     * This method will only be called when the `shouldFooterBehaveAsButton` is `true`.
     *
     * - Parameter button: The button that's tapped.
     * - Parameter viewController: The otp view controller. Use this to show loaders, spinners, present any other view controllers on top etc..
     *
     * - Author: Badhan Ganesh
     */
    @objc func didTap(footer button: UIButton, from viewController: BJOTPViewController)
}

/**
 * A simple and neat-looking view controller that lets you type in OTPs quick and easy
 *
 * This is intended to be a drag and drop view controller that gets the work done quickly, in and out, that's it. No fancy customizations, no cluttering the screen with tons of UI elements and crazy colors. You'll be good to go with the default settings.
 *
 * * Supports Portrait | Landscape
 * * Light Mode | Dark Mode
 * * iOS | iPadOS | macOS (Catalyst)
 *
 * **Example Usage:**
 
 * ```swift
 import BJOTPViewController
 
 ---------------------------------------------
 //PRESENTATION
 ---------------------------------------------
 
 // Initialise view controller
 let oneTimePasswordVC = BJOTPViewController.init(withHeading: "Two Factor Authentication",
                                                  withNumberOfCharacters: 6,
                                                  delegate: self)
 // Present it
 self.present(oneTimePasswordVC, animated: true, completion: nil)
 
 ---------------------------------------------
 //VISUALS
 ---------------------------------------------
 
 // Button title. Optional. Default is "AUTHENTICATE".
 oneTimePasswordVC.authenticateButtonTitle = "VERIFY OTP"

 // Sets the overall accent of the view controller. Optional. Default is system blue.
 oneTimePasswordVC.accentColor = UIColor.systemRed

 // Currently selected text field color. Optional. This takes precedence over the accent color.
 oneTimePasswordVC.currentTextFieldColor = UIColor.systemOrange

 // Button color. Optional. This takes precedence over the accent color.
 oneTimePasswordVC.authenticateButtonColor = UIColor.systemGreen
 
 ---------------------------------------------
 //DELEGATE
 ---------------------------------------------
 
 //Conform to BJOTPViewControllerDelegate

 func authenticate(_ otp: String, from viewController: BJOTPViewController) {
 
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
 
 }

 func didClose(_ viewController: BJOTPViewController) {
 
 /**
  * This method will get called whenever the otp view controller is closed, either by popping, dismissing, or tapping the close button.
  *
  * Use this to invalidate any timers, do clean-ups, etc..
  *
  * - Parameter viewController: The otp view controller.
  *
  * - Author: Badhan Ganesh
  */
  
 }

 func didTap(footer button: UIButton, from viewController: BJOTPViewController) {
 
 /**
  * This delegate method will get called when the footer button at the bottom is tapped. Use this to resend one time code from the server
  *
  * This method will only be called when the `shouldFooterBehaveAsButton` is `true`.
  *
  * - Parameter button: The button that's tapped.
  * - Parameter viewController: The otp view controller. Use this to show loaders, spinners, present any other view controllers on top etc..
  *
  * - Author: Badhan Ganesh
  */
  
 }
 ```
 * - Author: Badhan Ganesh
 */
open class BJOTPViewController: UIViewController {
    
    
    ////////////////////////////////////////////////////////////////
    //MARK:-
    //MARK: Private Properties
    //MARK:-
    ////////////////////////////////////////////////////////////////

    
    private var autoFillingFromSMS = false
    private var autoFillBuffer: [String] = []
    private var didTapToDismissKeyboard = false
    private var timeIntervalBetweenAutofilledCharactersFromSMS: Date?
    
    private var headingString: String
    private let numberOfOtpCharacters: Int
    private var allTextFields: [BJOTPTextField] = []
    private var textFieldsIndexes: [BJOTPTextField: Int] = [:]
    
    private var brandImageView: UIImageView?
    private var closeButton: UIButton?
    private var stackView: UIStackView!
    private var keyboardIsOn: Bool = false
    private var masterStackView: UIStackView!
    private var keyboardOffsetDuringEditing: CGFloat = 0.0
    private var headingTitleLabel: UILabel?
    
    private var footerButton: BJOTPAuthenticateButton?
    private var primaryHeaderLabel: UILabel?
    private var secondaryHeaderLabel: UILabel?
    private var headerTextsStackView: UIStackView?
    
    private var authenticateButton: BJOTPAuthenticateButton!
    private var masterStackViewCenterYConstraint: NSLayoutConstraint!
    private var originalMasterStackViewCenterYConstraintConstant: CGFloat!
    private var headingTitleLabelTopConstraint: NSLayoutConstraint?
    
    private weak var currentTextField: BJOTPTextField? = nil
    
    /**
     * Setting this property with a valid string will paste it in all the textfields and call the delegte method.
     *
     * - Author: Badhan Ganesh
     */
    private var stringToPaste: String = "" {
        didSet {
            if stringToPaste.count == self.numberOfOtpCharacters {
                for (idx, element) in stringToPaste.enumerated() {
                    allTextFields[idx].text = String(element)
                }
                self.touchesEnded(Set.init(arrayLiteral: UITouch()), with: nil)
                self.informDelegate(stringToPaste, from: self)
            }
        }
    }
    
    /**
     * Keeps track of the copied string from clipboard for the purpose of comparing old and new strings to decide on auto-pasting, or prompting user to paste it.
     *
     * - Author: Badhan Ganesh
     */
    private static var clipboardContent: String? = nil

    
    //
    ////////////////////////////////////////////////////////////////
    //MARK:-
    //MARK: Public Properties
    //MARK:-
    ////////////////////////////////////////////////////////////////
    //

    
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
    @objc public var accentColor: UIColor = .systemBlue {
        willSet {
            self.closeButton?.setTitleColor(self.authenticateButtonColor ?? newValue, for: .normal)
            if self.authenticateButton != nil {
                self.authenticateButton.backgroundColor = self.authenticateButtonColor ?? newValue
            }
            if let tf = currentTextField {
                tf.layer.borderColor = currentTextFieldColor?.cgColor ?? newValue.cgColor
            }
        }
    }
    
    /**
     * The currently focused text field color. This color will appear faded (less opacity) to look good instead of being saturated.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var currentTextFieldColor: UIColor? {
        willSet {
            if let tf = currentTextField {
                tf.setBorder(amount: 3, borderColor: (newValue ?? self.accentColor).withAlphaComponent(0.4), duration: 0)
            }
        }
    }
    
    /**
     * The color of the authenticate button.
     *
     * Settings this color will override the `accentColor`.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var authenticateButtonColor: UIColor? {
        willSet {
            guard self.authenticateButton != nil else { return }
            self.authenticateButton.backgroundColor = newValue ?? self.accentColor
        }
    }
    
    /**
     * The title of the authenticate button.
     *
     * Settings this color will override the `accentColor`.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var authenticateButtonTitle: String = "AUTHENTICATE" {
        willSet {
            guard self.authenticateButton != nil else { return }
            self.authenticateButton.setTitle(newValue, for: .normal)
        }
    }
    
    /**
     * The title of the primary header which stays above the OTP textfields.
     *
     * This is optional. In case of nil, the label won't be constructed at all. So make sure to set a string, or leave it as it is (`nil`).
     *
     * - Author: Badhan Ganesh
     */
    @objc public var primaryHeaderTitle: String? {
        willSet {
            self.primaryHeaderLabel?.text = newValue
        }
    }
    
    /**
     * The title of the secondary header which comes below the primary header.
     *
     * This is optional. In case of nil, the label won't be constructed at all. So make sure to set a string, or leave it as it is (`nil`).
     *
     * - Author: Badhan Ganesh
     */
    @objc public var secondaryHeaderTitle: String? {
        willSet {
            self.secondaryHeaderLabel?.text = newValue
        }
    }
    
    /**
     * The title of the footer label which comes below the authenticate button.
     *
     * This is optional. In case of nil, the label won't be constructed at all. So make sure to set a string, or leave it as it is (`nil`).
     *
     * - Author: Badhan Ganesh
     */
    @objc public var footerTitle: String? {
        willSet {
            self.footerButton?.setTitle(newValue, for: .normal)
        }
    }
    
    /**
     * Set whether the primary, secondary labels are to be hidden during editing, i.e., when the keyboard is open.
     *
     * Default is `false`
     *
     * - Author: Badhan Ganesh
     */
    @objc public var hideLabelsWhenEditing: Bool = false
    
    /**
     * Setting this to `true` will show an alert to the user whenever a compatible text is copied to clipboard asking whether or not to paste the same. Yes or No option will be provided.
     *
     * Default is `true`.
     *
     * Tapping "Yes" will auto-fill all the textfields with copied text and will call the `authenticate` delegate method.
     *
     * Pop-up won't be shown for the same string copied over and over. Clipboard will be checked when the app comes to foreground, and when the view controller's view finished appearing.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var shouldPromptUserToPasteCopiedStringFromClipboard: Bool = true
    
    /**
     * Setting this to `true` will automatically paste compatible text that is present in the clipboard and call the `authenticate` delegate method without asking any questions. This property will take precedence over `shouldPromptUserToPasteCopiedStringFromClipboard` property.
     *
     * Default is `false`.
     *
     * But be careful when setting this to `true` as this might not be the best user experiece all the time. This does not give the user the control of what code to paste.
     *
     * Some/most users may prefer quick submission and verification of OTP code without any extra clicks or taps. This saves a quite a few milliseconds from them.
     *
     * **Note:** OTP code won't be pasted for the same string copied over and over. Clipboard will be checked when the app comes to foreground, and when the view controller's view finished appearing.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var shouldAutomaticallyPasteCopiedStringFromClipboard: Bool = false
    
    /**
     * Uses haptics for touches, interactions, successes and errors within the OTP view controller.
     *
     * Default is `true`.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var hapticsEnabled: Bool = true
    
    /**
     * Asks whether the footer should behave as a button or just a normal label. Button will pass the action to the delegate method `didTap(footer button: UIButton)`.
     *
     * If `true`, the color of the footer will be `.systemBlue`, and gray otherwise. Default is `false`.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var shouldFooterBehaveAsButton: Bool = false
    
    /**
     * The color of the footer.
     *
     * This color will be applied only when `shouldFooterBehaveAsButton` is set to `true`. Default gray color will be used otherwise. Default color is `.systemBlue`.
     *
     * - Author: Badhan Ganesh
     */
    @objc public var footerButtonColor: UIColor?
    
    /**
     * The image (logo) of your brand that you would like to add to the top of the OTP UI
     *
     * - Author: Badhan Ganesh
     */
    @objc public var brandImage: UIImage? {
        willSet {
            UIView.animate(withDuration: 0.3) {
                self.brandImageView?.image = newValue
            }
        }
    }
    
    //
    ////////////////////////////////////////////////////////////////
    //MARK:-
    //MARK: Main Implementation
    //MARK:-
    ////////////////////////////////////////////////////////////////
    //

    /**
     * The init method to use to construct `BJOTPViewController`.
     *
     * - Parameter heading: The main heading title that will be displayed at the very top in case of a modal view controller, navigation bar title in case of navigation controller.
     * - Parameter delegate: The delegate object that is responsible for handling events sent by `BJOTPViewController`,
     * for example button tap event.
     * - Parameter numberOfOtpCharacters: The number of characters the view controller accepts. Generally 6 chars is the rule.
     */
    @objc public init(withHeading heading: String = "One Time Password",
                      withNumberOfCharacters numberOfOtpCharacters: Int,
                      delegate: BJOTPViewControllerDelegate? = nil) {
        self.delegate = delegate
        self.headingString = heading
        self.numberOfOtpCharacters = numberOfOtpCharacters
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.constructUI()
        self.initialConfiguration()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkClipboardAndPromptUserToPasteContent()
        self.openKeyboadDuringStartup ? _ = self.allTextFields.first?.becomeFirstResponder() : doNothing()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let isBeingPopped: Bool!
        
        #if swift(>=5.0)
        isBeingPopped = isMovingFromParent
        #elseif swift(<5.0)
        isBeingPopped = isMovingFromParentViewController
        #endif
        
        if isBeingDismissed || isBeingPopped {
            self.delegate?.didClose(self)
        }
    }
    
    @objc func authenticateButtonTapped(_ sender: UIButton) {
        var otpString = ""
        let numberOfEmptyTextFields: Int = allTextFields.reduce(0, { emptyTextsCount, textField in
            otpString += textField.text!
            return (textField.text ?? "") == "" ? emptyTextsCount + 1 : emptyTextsCount
        })
        if numberOfEmptyTextFields > 0 {
            if hapticsEnabled { UINotificationFeedbackGenerator().notificationOccurred(.error) }
            return
        }
        self.view.endEditing(true)
        self.informDelegate(otpString, from: self)
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        if self.navigationController == nil {
            self.askUserConsentBeforeDismissingModal()
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.headingTitleLabel?.numberOfLines = NSObject.deviceIsInLandscape ? 1 : self.brandImage == nil ? 2 : 1
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(in: self.view, animation: { (coord) in
            
            /// Adjusting the centering of the main stack view that holds all the elements
            self.masterStackViewCenterYConstraint = self.masterStackView.change(yOffset: self.offsetValueDuringRest())
            self.originalMasterStackViewCenterYConstraintConstant = self.masterStackViewCenterYConstraint.constant
            self.masterStackView.layoutIfNeeded()
            
            /// Adjusting width and height of the brand image view
            let imageWidth = NSObject.deviceIsMacOrIpad ? 150 : NSObject.deviceIsInLandscape ? self.view.frame.size.height / 8 : self.view.frame.size.width / 2.5
            self.brandImageView?.removeConstraints(self.brandImageView?.constraints ?? [])
            self.brandImageView?.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
            self.brandImageView?.heightAnchor.constraint(equalToConstant: imageWidth).isActive = true
            self.brandImageView?.setNeedsUpdateConstraints()
            
            /// Adjusting top heading title label
            if #available(iOS 11.0, *) {
                let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top
                let constraintConstant: CGFloat = (topInset ?? 0) <= 20.0 ?
                (!NSObject.deviceIsiPad && NSObject.deviceIsInLandscape ? 5 : 15) : 18
                self.headingTitleLabelTopConstraint?.constant = constraintConstant
            } else {
                self.headingTitleLabelTopConstraint?.constant = 12
            }
            self.headingTitleLabel?.setNeedsUpdateConstraints()
        }, completion: nil)
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    /**
     * Call this method to dismiss the keyboard, and reset the position of the master stack view to its original position, and reset all labels' alpha to 1.0.
     *
     * - Author: Badhan Ganesh
     */
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.didTapToDismissKeyboard = true
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [.curveEaseIn, .curveEaseOut], animations: {
            self.masterStackViewCenterYConstraint.constant = self.originalMasterStackViewCenterYConstraintConstant
            self.keyboardOffsetDuringEditing = 0.0
            self.setLabelsAlpha(1.0)
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()
        }) { (completed) in
            self.didTapToDismissKeyboard = false
        }
        
        ///Here below, we make the text field the first responder and then resign it because, when using
        ///OCR feature in iOS, after pasting the content, the secure text entry text field won't
        ///hide the character pasted unless we tap on that text field again - making it a first responder.
        ///
        ///We are manually making it the first responder to fix this issue.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.currentTextField?.becomeFirstResponder()
            self.currentTextField?.resignFirstResponder()
        }
    }
    
    deinit {
        self.removeListeners()
        self.allTextFields.removeAll()
        self.textFieldsIndexes.removeAll()
        debugPrint("**********\nBJOTPViewController deinit being called\n**********")
    }
}


////////////////////////////////////////////////////////////////
//MARK:-
//MARK: UITextFields Handling
//MARK:-
////////////////////////////////////////////////////////////////


extension BJOTPViewController: UITextFieldDelegate {
    
    enum Direction { case left, right }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        ///We don't need any string that is more than the maximum allowed number of characters
        if string.count > self.numberOfOtpCharacters { return false }
        
        if string == "\n" { return false }

        ///We don't need any white space either
        if (string == "" || string == " ") && range.length == 0 {
            
            ///But, auto-fill from SMS - before sending in the characters one by one - will
            ///send two (one in case of mac catalyst) empty strings ("") in succession very fast, unlike the speed a human may enter passcode.
            ///
            ///We need to check for it and have to decide/assume that what we have received is indeed auto-filled code from SMS.
            ///
            ///This has to be done since we use a new textfield for each character instead of a single text field with all characters.
            
            if string == "" {
                if NSObject.deviceIsMacCatalyst {
                    self.autoFillingFromSMS = true
                } else {
                    if let oldInterval = timeIntervalBetweenAutofilledCharactersFromSMS {
                        if Date().timeIntervalSince(oldInterval) < 0.08 {
                            self.autoFillingFromSMS = true
                            timeIntervalBetweenAutofilledCharactersFromSMS = nil
                        }
                    }
                    timeIntervalBetweenAutofilledCharactersFromSMS = Date()
                }
            }
            
            return false
        }
        
        ///We check if the text is pasted.
        if string.count > 1 {
            ///If the string is of the same length as the number of otp characters, then we proceed to
            ///fill all the text fields with the characters
            if string.count == numberOfOtpCharacters {
                
                for (idx, element) in string.enumerated() {
                    allTextFields[idx].text = String(element)
                }
                
                self.touchesEnded(Set.init(arrayLiteral: UITouch()), with: nil)
                self.informDelegate(string, from: self)
                ///If the replacing string is of 1 character length, then we just allow it to be replaced
                ///and set the responder to be the next text field
            } else if string.count == 1 {
                setNextResponder(textFieldsIndexes[textField as! BJOTPTextField], direction: .right)
                textField.text = string
            }
        } else {
            
            if autoFillingFromSMS {
                
                autoFillBuffer.append(string)

                ///`checkOtpFromMessagesCount` below specifically checks if the entered string is less than the maximum allowed characters.
                ///Since we are debouncing it, `checkOtpFromMessagesCount` will get called only once.
                ///And we don't allow any characters that are less than the allowed ones.
                
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(BJOTPViewController.checkOtpFromMessagesCount), object: nil)
                self.perform(#selector(BJOTPViewController.checkOtpFromMessagesCount), with: nil, afterDelay: 0.1)

                ///We check if the auto-fill from SMS has finished entering all the characters.
                ///In this case, we need only up to the maximum number of otp characters set by the developer.
                ///At a later stage, this might be controlled by a flag which will strictly allow only equal number of characters set by the `numberOfOtpCharacters` property.
                
                if autoFillBuffer.count == numberOfOtpCharacters {
                    var finalOTP = ""
                    for (idx, element) in autoFillBuffer.enumerated() {
                        let otpChar = String(element)
                        finalOTP += otpChar
                        allTextFields[idx].text = otpChar
                    }
                    self.touchesEnded(Set.init(arrayLiteral: UITouch()), with: nil)
                    self.informDelegate(finalOTP, from: self)
                    autoFillingFromSMS = false
                    autoFillBuffer.removeAll()
                }
                return false
            }
            
            ///Normal text entry
            
            if range.length == 0 {
                textField.text = string
                setNextResponder(textFieldsIndexes[textField as! BJOTPTextField], direction: .right)
            } else if range.length == 1 {
                if string == " " { return false }
                textField.text = string.isEmpty ? "" : string
                setNextResponder(textFieldsIndexes[textField as! BJOTPTextField], direction: string.isEmpty ? .left : .right)
            }
        }
        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentTextField = textField as? BJOTPTextField
        textField.roundCorners(amount: 4)
        textField.setBorder(amount: 3, borderColor: (self.currentTextFieldColor ?? self.accentColor).withAlphaComponent(0.4), duration: 0.15)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.currentTextField = nil
        textField.setBorder(amount: 1.8, borderColor: UIColor.lightGray.withAlphaComponent(0.3), duration: 0.15)
    }
    
    private func setNextResponder(_ index: Int?, direction: Direction) {
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
        self.touchesEnded(Set.init(arrayLiteral: UITouch()), with: nil)
        var otpString = ""
        let numberOfEmptyTextFields: Int = allTextFields.reduce(0, { emptyTextsCount, textField in
            otpString += textField.text!
            return (textField.text ?? "").isEmpty ? emptyTextsCount + 1 : emptyTextsCount
        })
        if numberOfEmptyTextFields > 0 { return }
        if let _ = delegate {
            self.informDelegate(otpString, from: self)
        } else {
            fatalError("Delegate is nil in BJTOPViewController.")
        }
    }
    
    /**
     * This method detects if the auto-filled code from SMS is less than that of the allowed number of characters.
     *
     * This checking needs to be done to come to a conclusion on when to populate the code (stored in `autoFillBuffer`) in text fields from SMS. We don't need to populate any characters that are less than what is allowed max..
     *
     * - Author: Badhan Ganesh
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
//MARK: UI Construction
//MARK:-
////////////////////////////////////////////////////////////////


extension BJOTPViewController {
    
    internal func constructUI() {
        
        /// All of the below UI code is strictly order-sensitive and tightly coupled to their previous elements' layout.
        /// Be careful and try not to change the order of the stuffs. Each UI element is laid out one by one,
        /// piece by piece to work correctly.
        
        /// 1. Layout Heading title lablel in case of navigation bar.
        title = headingString
        
        /// 2. Setup textfields.
        configureOTPTextFields()
        
        /// 3. Layout Heading title lablel in case of no navigation bar.
        layoutHeadingLabel()
        
        /// 4. Brand Logo / Image
        layoutBrandImageView()
        
        /// 4. Layout all stackviews and its contents.
        layoutAllStackViews(with: allTextFields)
        
        /// 6. Layout close button at the bottom.
        layoutBottomCloseButton()
        
        /// 7. Set background color.
        if #available(iOS 13.0, *) {
            view.backgroundColor = .otpVcBackgroundColor
        } else {
            view.backgroundColor = .white
        }
        
        /// 8. This fixes an issue where when used in macOS apps, the user cannot paste any text on to any text field at the very beginning. Can be pasted once a textfield has received any text though. But anyway a text has to be inserted in the beginning to avoid the issue. Not sure why this happens, weird.
        for tf in allTextFields { tf.insertText("") }
        
        /// 9. Offset and save the Top constraint of master stack view.
        saveMasterStackViewYConstraint()

    }
    
    fileprivate func layoutBottomCloseButton() {
        if self.navigationController == nil {
            self.view.layoutIfNeeded()
            let closeButton = BJOTPAuthenticateButton()
            closeButton.frame = .init(origin: .zero, size: .init(width: self.masterStackView.bounds.width, height: 35))
            closeButton.tarmic = false
            closeButton.useHaptics = false
            closeButton.setTitle("CLOSE", for: .normal)
            closeButton.showsTouchWhenHighlighted = false
            closeButton.setTitleColor(self.authenticateButtonColor ?? self.accentColor, for: .normal)
            closeButton.titleLabel?.font = UIFont.systemFont(ofSize: NSObject.deviceIsMacOrIpad ? 14.5 : 12, weight: .bold)
            closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            
            self.view.addSubview(closeButton)
            closeButton.pinTo(.bottomMiddle)
            self.closeButton = closeButton
        }
    }
    
    fileprivate func saveMasterStackViewYConstraint() {
        self.masterStackViewCenterYConstraint = self.masterStackView.change(yOffset: offsetValueDuringRest())
        self.originalMasterStackViewCenterYConstraintConstant = self.masterStackViewCenterYConstraint.constant
    }
    
    fileprivate func layoutBrandImageView() {
        guard let image = self.brandImage else { return }
        
        let brandImageView = UIImageView.init(image: image)
        brandImageView.contentMode = .scaleAspectFit
        brandImageView.roundCorners(amount: 6)

        let imageWidth = NSObject.deviceIsMacOrIpad ? 150 : NSObject.deviceIsInLandscape ? self.view.frame.size.height / 8 : self.view.frame.size.width / 2.5
        brandImageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        brandImageView.heightAnchor.constraint(equalToConstant: imageWidth).isActive = true
        
        self.brandImageView = brandImageView
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
        textField.menuActionDelegate = self
        textField.setBorder(amount: 1.8, borderColor: UIColor.lightGray.withAlphaComponent(0.28), duration: 0.09)
        textField.widthAnchor.constraint(equalToConstant: NSObject.newWidth).isActive = numberOfOtpCharacters == 1
        textField.heightAnchor.constraint(equalTo: textField.widthAnchor, multiplier: 1.0).isActive = true
        
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
        return textField
    }
    
    fileprivate func layoutHeadingLabel() {
        
        if self.navigationController?.isNavigationBarHidden ?? true {
            
            let headingTitle = UILabel()
            headingTitle.tarmic = false
            headingTitle.tag = 2245
            headingTitle.numberOfLines = 2
            headingTitle.textAlignment = .center
            headingTitle.text = self.headingString
            headingTitle.adjustsFontSizeToFitWidth = true
            
            let headingFontMetric = UIFontMetrics.init(forTextStyle: .largeTitle)
            let headingTitleFont = headingFontMetric.scaledFont(for: .systemFont(ofSize: NSObject.deviceIsMacOrIpad ? 23 : 28, weight: .bold))
            headingTitle.font = headingTitleFont
            
            self.view.addSubview(headingTitle)
            
            if #available(iOS 11.0, *) {
                let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top
                let constraintConstant: CGFloat = (topInset ?? 0) <= 20.0 ?
                (!NSObject.deviceIsiPad && NSObject.deviceIsInLandscape ? 5 : 15) : 18
                
                self.headingTitleLabelTopConstraint = headingTitle.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: constraintConstant)
                self.headingTitleLabelTopConstraint?.isActive = true
            } else {
                self.headingTitleLabelTopConstraint = headingTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 12)
                self.headingTitleLabelTopConstraint?.isActive = true
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
            let primaryHeaderLabelFont = headlineFontMetric.scaledFont(for: .systemFont(ofSize: NSObject.deviceIsMacOrIpad ? 30 : 20, weight: .bold))
            primaryHeaderLabel.font = primaryHeaderLabelFont
            
            primaryHeaderLabel.adjustsFontSizeToFitWidth = true
            primaryHeaderLabel.setContentHuggingPriority(.init(1000), for: .vertical)
            primaryHeaderLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
            primaryHeaderLabel.lineBreakMode = .byTruncatingMiddle
            primaryHeaderLabel.textAlignment = .center
            primaryHeaderLabel.numberOfLines = 1
            primaryHeaderLabel.text = self.primaryHeaderTitle
            primaryHeaderLabel.widthAnchor.constraint(equalToConstant: NSObject.newWidth).isActive = true
            primaryHeaderLabel.heightAnchor.constraint(equalToConstant: NSObject.deviceIsMacOrIpad ? 45 : 35).isActive = true
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
            secondaryHeaderLabel.font = UIFont.preferredFont(forTextStyle: NSObject.deviceIsMacOrIpad ? .subheadline : .caption1)
            secondaryHeaderLabel.setContentHuggingPriority(.init(1000), for: .vertical)
            secondaryHeaderLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
            secondaryHeaderLabel.lineBreakMode = .byTruncatingMiddle
            secondaryHeaderLabel.textAlignment = .center
            secondaryHeaderLabel.numberOfLines = 2
            secondaryHeaderLabel.adjustsFontSizeToFitWidth = true
            secondaryHeaderLabel.text = self.secondaryHeaderTitle
            secondaryHeaderLabel.widthAnchor.constraint(equalToConstant: NSObject.newWidth).isActive = true
//            secondaryHeaderLabel.heightAnchor.constraint(equalToConstant: NSObject.deviceIsMacOrIpad ? 30 : 25).isActive = true
            self.secondaryHeaderLabel = secondaryHeaderLabel
        }
    }
    
    @objc func footerButtonTapped(_ button: UIButton) {
        self.delegate?.didTap(footer: button, from: self)
    }
    
    fileprivate func layoutFooterLabel() {
        if let _ = footerTitle {
            let footerButton = BJOTPAuthenticateButton()
            let footerLabelFontSize = NSObject.deviceIsMacOrIpad ? 13.0 : 11.0
            let captionFontMetric = UIFontMetrics.init(forTextStyle: .caption2)
            let footerLabelFont = captionFontMetric.scaledFont(for: .systemFont(ofSize: footerLabelFontSize, weight: .regular))
            
            footerButton.useHaptics = hapticsEnabled
            footerButton.animate = shouldFooterBehaveAsButton
            footerButton.isUserInteractionEnabled = shouldFooterBehaveAsButton
            
            footerButton.titleLabel?.font = footerLabelFont
            footerButton.titleLabel?.textAlignment = .center
            footerButton.titleLabel?.adjustsFontForContentSizeCategory = true
            footerButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            var labelTitleColor: UIColor!
            
            if #available(iOS 13.0, *) {
                labelTitleColor = UIColor.secondaryLabel.withAlphaComponent(0.4)
            } else {
                labelTitleColor = UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.6).withAlphaComponent(0.4)
            }
            
            if shouldFooterBehaveAsButton {
                footerButton.addTarget(self, action: #selector(footerButtonTapped(_:)), for: .touchUpInside)
            }
            
            footerButton.setTitleColor(shouldFooterBehaveAsButton ? (self.footerButtonColor ?? .systemBlue) : labelTitleColor, for: .normal)
            footerButton.titleLabel?.lineBreakMode = .byTruncatingMiddle
            footerButton.titleLabel?.textAlignment = .center
            footerButton.titleLabel?.numberOfLines = 3
            footerButton.setTitle(self.footerTitle, for: .normal)
            
            self.footerButton = footerButton
        }
    }
    
    fileprivate func layoutStackViewForHeaderLabels() {
        let headerTextsStackView = UIStackView(arrangedSubviews: [self.primaryHeaderLabel, self.secondaryHeaderLabel].compactMap { view in view } )
        headerTextsStackView.axis = .vertical
        headerTextsStackView.spacing = 0
        headerTextsStackView.alignment = .center
        headerTextsStackView.distribution = .fill
        self.headerTextsStackView = headerTextsStackView
    }
    
    fileprivate func layoutAuthenticateButton(withSibling view: UIView) {
        
        let authenticateButton = BJOTPAuthenticateButton()
        authenticateButton.tarmic = false
        authenticateButton.roundCorners(amount: 6.0)
        authenticateButton.useHaptics = self.hapticsEnabled
        authenticateButton.setTitle(self.authenticateButtonTitle, for: .normal)
        
        let authenticateButtonFontMetric = UIFontMetrics.init(forTextStyle: .headline)
        let authenticateButtonFont = authenticateButtonFontMetric.scaledFont(for: .boldSystemFont(ofSize: 14))
        
        authenticateButton.titleLabel?.adjustsFontForContentSizeCategory = true
        authenticateButton.titleLabel?.lineBreakMode = .byTruncatingTail
        authenticateButton.titleLabel?.font = authenticateButtonFont
        authenticateButton.backgroundColor = self.authenticateButtonColor ?? self.accentColor
        authenticateButton.addTarget(self, action: #selector(authenticateButtonTapped(_:)), for: .touchUpInside)
        
        authenticateButton.heightAnchor.constraint(equalToConstant: (NSObject.newHeight * (NSObject.deviceIsiPad ? 90 : 75)) / 100).isActive = true
        
        self.authenticateButton = authenticateButton
    }
    
    fileprivate func layoutOTPStackView(with subviews: [UIView]) {
        let otpStackView = UIStackView.init(arrangedSubviews: subviews)
        otpStackView.tag = 234
        otpStackView.spacing = 10
        otpStackView.alignment = .fill
        otpStackView.distribution = .fill
        otpStackView.widthAnchor.constraint(equalToConstant: NSObject.newWidth).isActive = numberOfOtpCharacters >= 5
        otpStackView.heightAnchor.constraint(equalToConstant: NSObject.newHeight).isActive = numberOfOtpCharacters < 5
        self.stackView = otpStackView
    }
    
    fileprivate func layoutMasterStackView() {
        let masterStackView = UIStackView(arrangedSubviews: [self.brandImageView, self.headerTextsStackView, self.stackView, self.authenticateButton, self.footerButton].compactMap { view in view } )
        masterStackView.axis = .vertical
        masterStackView.spacing = NSObject.deviceIsMacOrIpad ? 15 : 8
        masterStackView.alignment = .center
        masterStackView.distribution = .fill
        self.view.addSubview(masterStackView)
        self.masterStackView = masterStackView
        masterStackView.pinTo(.middle)
    }
    
    fileprivate func layoutAllStackViews(with subviews: [UIView]) {
        layoutOTPStackView(with: subviews)
        layoutPrimaryHeaderLabel()
        layoutSecondaryHeaderLabel()
        layoutFooterLabel()
        layoutStackViewForHeaderLabels()
        layoutAuthenticateButton(withSibling: self.stackView)
        layoutMasterStackView()
        self.stackView.layoutIfNeeded()
        self.authenticateButton.widthAnchor.constraint(equalToConstant: self.stackView.bounds.width).isActive = true
        self.footerButton?.widthAnchor.constraint(equalToConstant: self.stackView.bounds.width).isActive = true
    }
    
    fileprivate func offsetValueDuringRest() -> CGFloat {
        
        var bottomInset: CGFloat = 0
        var statusBarHeight: CGFloat = 0
        let headingLabelTopOffset: CGFloat = 25
        
        #if targetEnvironment(macCatalyst)
        bottomInset = !(self.navigationController?.isNavigationBarHidden ?? true) ? self.brandImage != nil ? 24 : 0 : 0
        
        #else
        bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        #endif
        
        if !(self.navigationController?.isNavigationBarHidden ?? true) {
            return (self.navBarHeight + statusBarHeight - bottomInset) / (self.brandImage != nil ? 2 :  NSObject.deviceIsInLandscape ? 2 : 1) - (!NSObject.deviceIsInLandscape ? (self.navBarHeight) : 0)
        } else {
            return bottomInset == 0 ?
            ((self.headingTitleLabel?.intrinsicContentSize.height ?? 0 + headingLabelTopOffset) / 8) :
            (NSObject.deviceIsInLandscape || NSObject.deviceIsMacCatalyst) ? -(bottomInset / 8) : (self.brandImage != nil ? -bottomInset : 0)
        }
    }
    
}


////////////////////////////////////////////////////////////////
//MARK:-
//MARK: Keyboard Handling
//MARK:-
////////////////////////////////////////////////////////////////


extension BJOTPViewController {
    
    fileprivate func initialConfiguration() {
        self.modalAndNavBarConfig()
        self.configureKeyboardAndOtherNotifications()
    }
    
    fileprivate func modalAndNavBarConfig() {
        if self.navigationController == nil {
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = true
                self.presentationController?.delegate = self
            }
        }
    }
    
    fileprivate func configureKeyboardAndOtherNotifications() {
        #if swift(>=5.0)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        #elseif swift(<5.0)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        #endif
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        var keyboardFrameBeginKey = ""
        var keyboardFrameEndKey = ""
        
        #if swift(>=5.0)
        keyboardFrameBeginKey = UIResponder.keyboardFrameBeginUserInfoKey
        keyboardFrameEndKey = UIResponder.keyboardFrameEndUserInfoKey
        #elseif swift(<5.0)
        keyboardFrameBeginKey = UIKeyboardFrameBeginUserInfoKey
        keyboardFrameEndKey = UIKeyboardFrameEndUserInfoKey
        #endif
        
        let beginFrame = (notification.userInfo?[keyboardFrameBeginKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo?[keyboardFrameEndKey] as! NSValue).cgRectValue

        ///Since `keyboardWillShow` method gets called sporadically, we handle it only when the start and end frames differ.
        ///We don't proceed further if there is no change in the keyboard's frame.
        guard !beginFrame.equalTo(endFrame) else {
            return
        }
        
        /**
         * Need this delay for the UI to finish being laid out
         * to check if the keyboard is obscuring the button or not initially.
         */
        self.offsetForKeyboardPosition(notification as NSNotification)

    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.resetToDefaultOffsetForKeyboardPosition(notification as NSNotification)
    }
    
    @objc func appWillEnterForeground(_ notification: Notification) {
        checkClipboardAndPromptUserToPasteContent()
    }
    
    @objc fileprivate func offsetForKeyboardPosition(_ notification: NSNotification) {
        
        var keyboardFrameEndKey = ""
        
        #if swift(>=5.0)
        keyboardFrameEndKey = UIResponder.keyboardFrameEndUserInfoKey
        #elseif swift(<5.0)
        keyboardFrameEndKey = UIKeyboardFrameEndUserInfoKey
        #endif
        
        self.keyboardIsOn = true
        let window = UIApplication.shared.windows.first
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrame = (userInfo[keyboardFrameEndKey] as! NSValue).cgRectValue
        let authButtonMaxY = self.masterStackView.convert(self.authenticateButton.frame, to: window).maxY
        let keyboardMinY = keyboardFrame.origin.y
        
        self.keyboardOffsetDuringEditing = (authButtonMaxY - keyboardMinY + (NSObject.self.deviceIsiPad ? 10 : 5))
        ///Means the keyboard overlaps the authenticate button
        if authButtonMaxY > keyboardMinY {
            UIView.animate(withDuration: 0.35) {
                self.masterStackViewCenterYConstraint.constant -= self.keyboardOffsetDuringEditing
                self.setLabelsAlpha(0.0)
                self.view.layoutIfNeeded()
                self.view.setNeedsUpdateConstraints()
            }
        }
    }
    
    fileprivate func resetToDefaultOffsetForKeyboardPosition(_ notification: NSNotification) {
        
        var keyboardFrameEndKey = ""
        
        #if swift(>=5.0)
        keyboardFrameEndKey = UIResponder.keyboardFrameEndUserInfoKey
        #elseif swift(<5.0)
        keyboardFrameEndKey = UIKeyboardFrameEndUserInfoKey
        #endif
        
        if keyboardIsOn {
            self.keyboardIsOn = false
            let window = UIApplication.shared.windows.first
            let userInfo = (notification as NSNotification).userInfo!
            let keyboardFrame = (userInfo[keyboardFrameEndKey] as! NSValue).cgRectValue
            let authButtonLocalY = self.masterStackView.convert(self.authenticateButton.frame, to: window).maxY
            let keyboardLocalY = keyboardFrame.origin.y
            let keyboardLocalHeight = window?.convert(keyboardFrame, to: self.view).height ?? 0
            
            if keyboardLocalHeight >= CGFloat(0) ||
                authButtonLocalY >= (keyboardLocalY - self.keyboardOffsetDuringEditing) {
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [.curveEaseIn, .curveEaseOut], animations: {
                    if self.didTapToDismissKeyboard == false {
                        self.masterStackViewCenterYConstraint.constant = self.originalMasterStackViewCenterYConstraintConstant
                        self.keyboardOffsetDuringEditing = 0.0
                        self.setLabelsAlpha(1.0)
                        self.view.layoutIfNeeded()
                    }
                    self.didTapToDismissKeyboard = false
                }, completion: nil)
            }
        }
        
    }
    
    fileprivate func setLabelsAlpha(_ value: CGFloat) {
        
        if value == 0 {
            if self.keyboardOffsetDuringEditing < 88 && !NSObject.deviceIsInLandscape {
                return
            }
        }
        
        let finalAlpha = value == 0.0 ? hideLabelsWhenEditing ? value : 1.0 : value
        
        self.headingTitleLabel?.alpha = value
        self.primaryHeaderLabel?.alpha = finalAlpha
        self.secondaryHeaderLabel?.alpha = finalAlpha
        self.brandImageView?.alpha = NSObject.deviceIsInLandscape ? value : 1.0
    }
    
}

extension BJOTPViewController: BJMenuActionDelegate {
    public func canPerform(_ action: Selector) -> Bool {
        if NSObject.deviceIsMacCatalyst {
            guard UIPasteboard.general.hasStrings else { return false }
            guard let copiedString = UIPasteboard.general.string else { return false }
            return copiedString.count == numberOfOtpCharacters
        } else {
            guard let copiedString = Self.clipboardContent else { return false }
            return copiedString.count == numberOfOtpCharacters
        }
    }
}


////////////////////////////////////////////////////////////////
//MARK:-
//MARK: Helper Methods
//MARK:-
////////////////////////////////////////////////////////////////

extension BJOTPViewController {
    
    /**
     * Responsible for checking if a new text (with same no. of allowed characters) has been copied to clipboard or not, and then prompting (via alert) the user to paste it, or auto-paste it based on the below attributes:
     *
     * * `shouldPromptUserToPasteCopiedStringFromClipboard`
     * * `shouldAutomaticallyPasteCopiedStringFromClipboard`
     *
     * - Author: Badhan Ganesh
     */
    fileprivate func checkClipboardAndPromptUserToPasteContent() {
        if UIPasteboard.general.hasStrings {
            let clipboardString = UIPasteboard.general.string
            
            if clipboardString?.count == numberOfOtpCharacters && clipboardString != Self.clipboardContent {
                Self.clipboardContent = clipboardString
                guard shouldAutomaticallyPasteCopiedStringFromClipboard == false else {
                    self.stringToPaste = clipboardString!
                    return
                }
                if shouldPromptUserToPasteCopiedStringFromClipboard {
                    if hapticsEnabled { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                    self.showSimpleAlertWithTitle("Do you want to paste the text from clipboard and proceed?", firstButtonTitle: "No", secondButtonTitle: "Yes", secondButtonAction:  { (secondButtonAction) in
                        self.stringToPaste = clipboardString!
                    })
                }
            } else {
                Self.clipboardContent = clipboardString
            }
        }
    }
    
    /**
     * Use this method to inform the delegate that a valid OTP has been entered.
     *
     * This method can be useful if you want to prepend or appennd anything in success scenarios.
     *
     * - Author: Badhan Ganesh
     */
    private func informDelegate(_ otp: String, from viewController: BJOTPViewController) {
        self.delegate?.authenticate(otp, from: viewController)
    }
    
    private func askUserConsentBeforeDismissingModal() {
        if hapticsEnabled { UINotificationFeedbackGenerator().notificationOccurred(.error) }
        self.showSimpleAlertWithTitle("Are you sure you want to close?", message: nil, firstButtonTitle: "No", secondButtonTitle: "Yes", isSecondButtonDestructive: true, firstButtonAction: nil) { (action) in
            self.dismiss(animated: true)
        }
    }
    
    private func removeListeners() {
        #if swift(>=5.0)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        #elseif swift(<5.0)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        #endif
    }
}

extension BJOTPViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.askUserConsentBeforeDismissingModal()
    }
}

@available(iOS 13.0, *)
extension BJOTPViewController: UISceneDelegate {
    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        #if targetEnvironment(macCatalyst)
            let windowScene = scene as! UIWindowScene
            
            windowScene.sizeRestrictions?.minimumSize = .init(width: 800, height: 600)
            windowScene.sizeRestrictions?.maximumSize = windowScene.sizeRestrictions?.minimumSize ?? .init(width: 1024, height: 768)
        #endif
    }
}
