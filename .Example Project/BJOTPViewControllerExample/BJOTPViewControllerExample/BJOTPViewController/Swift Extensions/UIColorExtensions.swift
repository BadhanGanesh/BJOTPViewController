//
//  UIColorExtensions.swift
//
//  Created by BadhanGanesh on 12/01/20.
//
// Copyright © 2018 Badhan Ganesh

import UIKit

extension UIColor {
    
    /**
     * The color of the otp view controller view's background.
     * Supports dark mode when using iOS 13.0 and above.
     *
     * Returns an off-white color in case the OS doesn't support dark mode.
     *
     * - Author: Badhan Ganesh
     */
    static var otpVcBackgroundColor: UIColor {
        get {
            let milkWhiteColor = UIColor.init(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            if #available(iOS 13.0, *) {
                return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                    switch traitCollection.userInterfaceStyle {
                    case .light:
                        return milkWhiteColor
                    case .dark:
                        return .black
                    case .unspecified:
                        return milkWhiteColor
                    @unknown default:
                        return milkWhiteColor
                    }
                }
            } else {
                return milkWhiteColor
            }
        }
    }
}

