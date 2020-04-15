# BJOTPViewController

![BJOTPViewController Banner](banner.png)

![GitHub release (latest by date)](https://img.shields.io/github/v/release/BadhanGanesh/BJOTPViewController)
![GitHub pull requests](https://img.shields.io/github/issues-pr/BadhanGanesh/BJOTPViewController)
![GitHub issues](https://img.shields.io/github/issues/BadhanGanesh/BJOTPViewController)
![GitHub top language](https://img.shields.io/github/languages/top/BadhanGanesh/BJOTPViewController?color=green)
[![GitHub License](https://img.shields.io/github/license/BadhanGanesh/BJOTPViewController)](https://github.com/BadhanGanesh/BJOTPViewController/blob/master/LICENSE)

[![GitHub License](https://img.shields.io/static/v1?label=Profile&message=StackOverflow&color=orange)](https://stackoverflow.com/users/5912335/badhanganesh?tab=profile)
[![GitHub License](https://img.shields.io/twitter/follow/badhanganesh?style=social)](https://twitter.com/intent/follow?screen_name=badhanganesh)


A very simple and neat-looking view controller that lets you type in OTP's quick and easy.

This is intended to be a drag and drop view controller that gets the work done quickly, in and out, that's it. No fancy customizations, no cluttering the screen with tons of UI elements and crazy colors. You'll be good to go with the default settings.


## Supports

✅ iOS 11.0+

✅ Swift 4.0+

✅ iOS | iPadOS

✅ Portrait | Landscape

✅ macOS (Mac Catalyst)

✅ Light Mode | Dark Mode


## Features

✅ Keyboard handling

✅ Copy-Paste handling

✅ Auto-fill from Messages app

✅ Apple-inspired Clean User Interface

✅ Custom primay / secondary / footer labels

✅ Detection of copied text / code from outside the app


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
    func authenticate(_ otp: String, from viewController: BJOTPViewController) {
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

**Other options**

```swift
/**
 * Setting this to true opens up the keyboard for the very first text field.
 *
 * Default is `false`. Consider the `hideLabelsWhenEditing` property when setting this one to `true`, because when the keyboard is open as soon as the view controller is presented/pushed, if `hideLabelsWhenEditing` is `true`, the labels will be hidden initially as a result, and the user won't even know that the labels exist. It will be a better user experience if the user sees the labels initially since it guides them what to do. Choose wisely.
 *
 * - Author: Badhan Ganesh
 */
@objc public var openKeyboadDuringStartup: Bool = false

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
 * But be careful when setting this to `true` as this might not be the best user experiece all the time. This does not gives the user the control of what code to paste.
 *
 * Some/most users may prefer quick submission and verification of OTP code without any extra clicks or taps. This saves a quite a few milliseconds from them.
 *
 * **Note:** OTP code won't be pasted for the same string copied over and over. Clipboard will be checked when the app comes to foreground, and when the view controller's view finished appearing.
 *
 * - Author: Badhan Ganesh
 */
@objc public var shouldAutomaticallyPasteCopiedStringFromClipboard: Bool = false

```


## Contribution

- Pull Requests are always welcome. Would love to see your inputs.


## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
