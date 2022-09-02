import UIKit
import BJOTPViewController

class ViewController: UIViewController {
    
    var otpScreen: BJOTPViewController?
    var stepper = UIStepper()
    var noOfCharsLabel = UILabel()
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        noOfCharsLabel.text = "Number of characters: " + String(Int(sender.value))
    }
    
    override func viewDidLoad() {
        
        noOfCharsLabel = UILabel(frame: .init(origin: .zero, size: .init(width: 300, height: 30)))
        let stepperView = UIView(frame: .init(origin: .zero, size: .init(width: 90, height: 30)))
        
        stepper.minimumValue = 1
        stepper.maximumValue = 20
        stepper.stepValue = 1
        stepper.value = 6
        stepper.isEnabled = true
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)

        self.view.addSubview(noOfCharsLabel)
        stepperView.addSubview(stepper)
        self.view.addSubview(stepperView)
        
        noOfCharsLabel.text = "Number of characters: " + String(Int(stepper.value))
        noOfCharsLabel.textAlignment = .center
        
        noOfCharsLabel.pinTo(.bottomMiddle, yOffset: -35)
        stepperView.pinTo(.bottomMiddle)
        
        super.viewDidLoad()
    }
    
    @IBAction func onModalButtonTap(_ sender: UIButton) {
        
        //Title
        let heading: String = "Two Factor Authentication"
        
        ///Initialize viewcontroller
        self.otpScreen = BJOTPViewController(withHeading: heading,
                                             withNumberOfCharacters: Int(stepper.value),
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
                                             withNumberOfCharacters: Int(stepper.value),
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
        if #available(iOS 13.0, *) {
            let alert = UIAlertController.init(title: "Verifying...", message: nil, preferredStyle: .alert)
            viewController.present(alert, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alert.dismiss(animated: true) {
                    self.otpScreen?.dismiss(animated: true)
                }
                self.otpScreen?.brandImage = .init(systemName: "lock.open.iphone")?.withTintColor(.label).withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func didTap(footer button: UIButton, from viewController: BJOTPViewController) {
        ///option-click on the method name above to see more details about it.
    }
    
}

extension ViewController {
    func configure(_ otpScreen: BJOTPViewController?) {
        
        guard let otpScreen = otpScreen else { return }
        
        let imageName: String = ["lock.iphone"].randomElement()!
        //let imageName: String = ["logo.xbox", "logo.playstation", "paperplane.circle.fill", "lock.iphone"].randomElement()!
        let primaryLabel: String = "Enter One Time Code"
        let secondaryLabel: String = "A message with a verification code has been sent to your devices. Enter the code to continue."
        let buttonTitle: String = "LOGIN SECURELY"
        
        //Set titles and options
        otpScreen.openKeyboadDuringStartup = true
        otpScreen.accentColor = [.systemBlue].randomElement()!
        otpScreen.primaryHeaderTitle = primaryLabel
        otpScreen.secondaryHeaderTitle = secondaryLabel
        otpScreen.footerTitle = "Didn't get verification code?"
        otpScreen.shouldFooterBehaveAsButton = true
        otpScreen.authenticateButtonTitle = buttonTitle
        otpScreen.secureTextEntry = false
        otpScreen.style = [.AppleDash, .AppleDot, .Standard, .MagicalContrast, .Contrast].randomElement()!
        
        if #available(iOS 13.0, *) {
            otpScreen.brandImage = .init(systemName: imageName)?.withTintColor(.label).withRenderingMode(.alwaysOriginal)
        }
        
    }
}

