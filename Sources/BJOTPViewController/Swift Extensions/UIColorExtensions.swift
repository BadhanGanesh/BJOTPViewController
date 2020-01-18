//
//  UIColorExtensions.swift
//
//  Created by BadhanGanesh on 12/01/20.
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright © 2018 Badhan Ganesh
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

