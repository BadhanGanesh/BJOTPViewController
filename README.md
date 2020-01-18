# BJOTPViewController

![BJOTPViewController Banner](banner.png)

A very simple and neat-looking view controller that lets you type in OTP's quick and easy.

This is intended to be a drag and drop view controller that gets the work done quickly, in and out, that's it. No fancy customizations, no cluttering the screen with tons of UI elements and crazy colors. You'll be good to go with the default settings.

## Supports

✅ iOS 9.0+

✅ Swift 4.0+

✅ iOS | iPadOS

✅ Portrait | Landscape

✅ Light mode | Dark mode


## Installation

1. In Xcode project, go to **File** → **Swift Packages** → **Add Package Dependency...**

2. Paste the repo URL: https://github.com/BadhanGanesh/BJOTPViewController.git

3. Follow onscreen instructions for choosing the package options and targets you want to add the dependency to, and click **Finish** when you're done. 


## Screenshots

![App Screens 1](app_screens_1.png)
-----
![App Screens 2](app_screens_2.png)

## Usage

**Presentation**

```swift
import BJOTPViewController

// Initialise view controller
let oneTimePasswordVC = BJOTPViewController.init(withHeading: "Two Factor Authentication",
                                                 withNumberOfCharacters: 6,
                                                 delegate: self)
// Present it
self.present(oneTimePasswordVC, animated: true, completion: nil)
```

**Delegate**

```swift
//Conform to BJOTPViewControllerDelegate
extension ViewController: BJOTPViewControllerDelegate {
    func authenticate(from viewController: BJOTPViewController) {
        // Make API calls, show loading animation in viewController, do whatever you want.
        // You can dismiss the viewController when you're done.
        // This method will get called only after the validation is successful, i.e.,
        // after the user has filled all the textfields.  
    }
}
```

**Visuals**

```swift
let oneTimePasswordVC = BJOTPViewController(withHeading: "One Time Password",
                                            withNumberOfCharacters: 6,
                                            delegate: self)
                                            
// Button title. Optional. Default is "AUTHENTICATE".
oneTimePasswordVC.authenticateButtonTitle = "VERIFY OTP"

// Sets the overall accent of the view controller. Optional. Default is system blue.
oneTimePasswordVC.accentColor = UIColor.systemRed

// Currently selected text field color. Optional. This takes precedence over the accent color.
oneTimePasswordVC.currentTextFieldColor = UIColor.systemOrange

// Button color. Optional. This takes precedence over the accent color.
oneTimePasswordVC.authenticateButtonColor = UIColor.systemGreen
```

## Upcoming Features

- Auto-completion of One Time Password into text fields from messages app.
- Addition of custom header / footer texts / description titles to the view controller.

## Contribution

- Pull Requests are always welcome. 😇
- Feel free to create issues, if any, and improve the existing codebase.

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
