//
//  EnclosingView.swift
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

class BJOTPStackViewContainerView: UIView {
    
    var newWidth: CGFloat {
        get {
            if deviceIsiPad { return 400 }
            return deviceIsInLandscape ?
                (superview?.bounds.size.height)! / 1.2 :
                (superview?.bounds.size.width)! / 1.2
        }
    }
    
    var newHeight: CGFloat {
        get {
            if deviceIsiPad { return 70 }
            return deviceIsInLandscape ?
                (superview?.bounds.size.width)! / 11.0 :
                (superview?.bounds.size.height)! / 11.0
        }
    }
    
    override func updateConstraints() {
        for constraint in constraints {
            if constraint.identifier == "Width_Constraint" {
                constraint.constant = newWidth
            } else if constraint.identifier == "Height_Constraint" {
                constraint.constant = newHeight
            }
        }
        super.updateConstraints()
    }
    
}
