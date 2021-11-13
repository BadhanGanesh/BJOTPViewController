import UIKit
import BJOTPViewController

class ViewController: UIViewController {
    
    var otpScreen: BJOTPViewController?

    @IBAction func onModalButtonTap(_ sender: UIButton) {
        
        let imageName: String = "logo.xbox"
        let titleLabel: String = "Microsoft 2FA Login"
        let primaryLabel: String = "Enter One Time Code"
        let secondaryLabel: String = "A message with a verification code has been sent to your devices. Enter the code to continue."
        let buttonTitle: String = "LOGIN SECURELY"
        
        //Initialize viewcontroller
        self.otpScreen = BJOTPViewController(withHeading: titleLabel,
                                            withNumberOfCharacters: 6,
                                            delegate: self)
        
        //Set titles
        otpScreen?.openKeyboadDuringStartup = true
        otpScreen?.accentColor = .systemRed
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
        
        let imageName: String = "logo.xbox"
        let titleLabel: String = "Microsoft 2FA Login"
        let primaryLabel: String = "Enter One Time Code"
        let secondaryLabel: String = "A message with a verification code has been sent to your devices. Enter the code to continue."
        let buttonTitle: String = "LOGIN SECURELY"
        
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
        ///option-click on the method name above to see more details about it.
        self.otpScreen = nil
    }
    
    func authenticate(_ otp: String, from viewController: BJOTPViewController) {
        ///option-click on the method name above to see more details about it.
    }
    
    func didTap(footer button: UIButton, from viewController: BJOTPViewController) {
        ///option-click on the method name above to see more details about it.
    }
    
}

