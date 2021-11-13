import UIKit
import BJOTPViewController

class ViewController: UIViewController {
    
    var otpScreen: BJOTPViewController?
    
    let options: [[String: String]] = [
        
        [ "primaryLabel" : "Two-Factor Authentication",
          "secondaryLabel" : "A message with a verification code has been sent to your devices. Enter the code to continue.",
          "brandImage": "applelogo",
          "titleLabel": "App Store Connect",
          "buttonTitle" : "SIGN IN WITH APPLE"],
        
        [ "primaryLabel" : "Enter One Time Code",
          "secondaryLabel" : "A message with a verification code has been sent to your devices. Enter the code to continue.",
          "brandImage": "logo.playstation",
          "titleLabel": "PlayStation Studios",
          "buttonTitle" : "LOGIN SECURELY"],
        
        [ "primaryLabel" : "We have sent you a code",
          "secondaryLabel" : "A message with a verification code has been sent to your devices. Enter the code to continue.",
          "brandImage": "logo.xbox",
          "titleLabel": "Xbox Game Pass",
          "buttonTitle" : "GO TO XBOX GAME PASS"],
        
        [ "primaryLabel" : "One Time Password",
          "secondaryLabel" : "A message with a verification code has been sent to your devices. Enter the code to continue.",
          "brandImage": "",
          "titleLabel": "Verification Needed",
          "buttonTitle" : "VERIFY OTP"],
        
    ]
    
    
    @IBAction func onModalButtonTap(_ sender: UIButton) {
        
        let option = options.randomElement()!
        let imageName: String = option["brandImage"]!
        let titleLabel: String = option["titleLabel"]!
        let primaryLabel: String = option["primaryLabel"]!
        let secondaryLabel: String = option["secondaryLabel"]!
        let buttonTitle: String = option["buttonTitle"]!
        
        //Initialize viewcontroller
        self.otpScreen = BJOTPViewController(withHeading: titleLabel,
                                            withNumberOfCharacters: 6,
                                            delegate: self)
        
        //Set titles
        otpScreen?.openKeyboadDuringStartup = true
        otpScreen?.accentColor = .systemBlue
        otpScreen?.primaryHeaderTitle = primaryLabel
        otpScreen?.secondaryHeaderTitle = secondaryLabel
        otpScreen?.footerTitle = "Didn't get verification code?"
        otpScreen?.shouldFooterBehaveAsButton = true
        otpScreen?.authenticateButtonTitle = buttonTitle
        if #available(iOS 13.0, *) {
            otpScreen?.brandImage = .init(systemName: imageName)?.withTintColor(UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black).withRenderingMode(.alwaysOriginal)
        }
        
        //Present view controller
        present(otpScreen!, animated: true)
        
    }
    
    @IBAction func onPushButtonTap(_ sender: UIButton) {
        
        let option = options.randomElement()!
        let imageName: String = option["brandImage"]!
        let titleLabel: String = option["titleLabel"]!
        let primaryLabel: String = option["primaryLabel"]!
        let secondaryLabel: String = option["secondaryLabel"]!
        let buttonTitle: String = option["buttonTitle"]!
        
        //Initialize viewcontroller
        self.otpScreen = BJOTPViewController(withHeading: titleLabel,
                                            withNumberOfCharacters: 6,
                                            delegate: self)
        
        //Set titles
        otpScreen?.openKeyboadDuringStartup = true
        otpScreen?.accentColor = .systemBlue
        otpScreen?.primaryHeaderTitle = primaryLabel
        otpScreen?.secondaryHeaderTitle = secondaryLabel
        otpScreen?.footerTitle = "Didn't get verification code?"
        otpScreen?.shouldFooterBehaveAsButton = true
        otpScreen?.authenticateButtonTitle = buttonTitle
        
        if #available(iOS 13.0, *) {
            otpScreen?.brandImage = .init(systemName: imageName)?.withTintColor(UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black).withRenderingMode(.alwaysOriginal)
        }
        
        //Push view controller
        navigationController?.pushViewController(otpScreen!, animated: true)
        
    }
    
}

/**
 * Make your view controller conform to `BJOTPViewControllerDelegate` protocol.
 *
 * These delegate methods are key to handling the entered otp string
 * and other events in the view controller.
 */
extension ViewController: BJOTPViewControllerDelegate {
    
    func didClose(_ viewController: BJOTPViewController) {
        //self.showSimpleAlertWithTitle("OTP Screen Closed", firstButtonTitle: "OK")
        self.otpScreen = nil
    }
    
    func authenticate(_ otp: String, from viewController: BJOTPViewController) {
        //viewController.showSimpleAlertWithTitle("Entered One Time Code is", message: otp, firstButtonTitle: "OK")
    }
    
    func didTap(footer button: UIButton, from viewController: BJOTPViewController) {
        //viewController.showSimpleAlertWithTitle("Footer button tapped", message: "You could call an API to resend the one time code.", firstButtonTitle: "OK")
    }
    
}

