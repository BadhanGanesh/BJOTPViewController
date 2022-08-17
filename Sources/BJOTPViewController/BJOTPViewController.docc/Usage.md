# Usage - BJOTPViewController

## Installation

1. In Xcode project, go to **File** → **Swift Packages** → **Add Package Dependency...**

2. Paste the repo URL: https://github.com/BadhanGanesh/BJOTPViewController.git

3. Follow onscreen instructions for choosing the package options and targets you want to add the dependency to - but make sure you always consider choosing the latest version for the best experience - and click **Finish** when you're done.

## Presentation

Here is how you can quickly present an otp view controller with a heading and maximum number of characters for the otp.

```swift
import BJOTPViewController

// Initialise view controller
let oneTimePasswordVC = BJOTPViewController.init(withHeading: "Two Factor Authentication",
                                      withNumberOfCharacters: 6,
                                                    delegate: self)
// Present it
self.present(oneTimePasswordVC, animated: true, completion: nil)
```

## Example Code

The following snippet can be used as is to create and configire an otp view controller. Point to note is that the below code requires iOS 13.0.

```swift
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


```

## Topics
### All Properties

Click below class for an exhaustive list of all the properties and methods available

- ``BJOTPViewController/BJOTPViewController``

### Protocols

- ``BJOTPViewControllerDelegate``
