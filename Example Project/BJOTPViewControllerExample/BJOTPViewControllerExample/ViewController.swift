import UIKit
import BJOTPViewController

class ViewController: UIViewController {
    
    var otpScreen: BJOTPViewController?
    
    @IBAction func onModalButtonTap(_ sender: UIButton) {
        
        //Title
        let heading: String = "Two Factor Authentication"
        
        ///Initialize viewcontroller
        self.otpScreen = BJOTPViewController(withHeading: heading,
                                            withNumberOfCharacters: 6,
                                            delegate: self)
        
        ///Configuration
        configure(otpScreen)
        
        ///Present view controller modally
        present(self.otpScreen!, animated: true)
        
    }
    
    @IBAction func onPushButtonTap(_ sender: UIButton) {
        
        //Title
        let heading: String = "Two Factor Authentication"
        
        ///Initialize viewcontroller
        self.otpScreen = BJOTPViewController(withHeading: heading,
                                             withNumberOfCharacters: 6,
                                             delegate: self)
        
        ///Configuration
        configure(otpScreen)
        
        ///Push view controller
        navigationController?.pushViewController(otpScreen!, animated: true)
        
    }
    
}

/**
 * Making view controller conform to `BJOTPViewControllerDelegate` protocol.
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

extension ViewController {
    func configure(_ otpScreen: BJOTPViewController?) {
        
        guard let otpScreen = otpScreen else { return }
        
        let imageName: String = ["logo.xbox", "logo.playstation"].randomElement()!
        let primaryLabel: String = "Enter One Time Code"
        let secondaryLabel: String = "A message with a verification code has been sent to your devices. Enter the code to continue."
        let buttonTitle: String = "LOGIN SECURELY"
        
        //Set titles and options
        otpScreen.openKeyboadDuringStartup = true
        otpScreen.accentColor = [.systemRed, .systemBlue].randomElement()!
        otpScreen.primaryHeaderTitle = primaryLabel
        otpScreen.secondaryHeaderTitle = secondaryLabel
        otpScreen.footerTitle = "Didn't get verification code?"
        otpScreen.shouldFooterBehaveAsButton = true
        otpScreen.authenticateButtonTitle = buttonTitle
        
        if #available(iOS 13.0, *) {
            otpScreen.brandImage = .init(systemName: imageName)?.withTintColor(UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black).withRenderingMode(.alwaysOriginal)
        }
        
    }
}

