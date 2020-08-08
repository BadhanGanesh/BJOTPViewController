//
//  UIViewControllerExtensions.swift
//  swiftextensions
//  Created by Badhan Ganesh on 12/10/18.
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

extension UIViewController {
    
    /**
     * Shows a simple alert on the view controller
     *
     * - Parameter title: The title string (appears at the top of the alert with bold letters).
     * - Parameter message: The message string (appears below the title).
     *
     * - Author: Badhan Ganesh
     */
    @objc func showSimpleAlertWithTitle(_ title: String? = nil, message: String? = nil,
                                        firstButtonTitle: String? = nil,
                                        secondButtonTitle: String? = nil,
                                        isSecondButtonDestructive: Bool = false,
                                        firstButtonAction: ((UIAlertAction) -> Void)? = nil,
                                        secondButtonAction: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        if let ft = firstButtonTitle {
            let firstAction = UIAlertAction.init(title: ft, style: .default, handler: firstButtonAction)
            alert.addAction(firstAction)
        }
        
        if let st = secondButtonTitle {
            let secondAction = UIAlertAction.init(title: st, style: isSecondButtonDestructive ? .destructive : .default, handler: secondButtonAction)
            alert.addAction(secondAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    var navBarHeight: CGFloat {
        get {
            return (self.navigationController?.navigationBar.bounds.height ?? 40)
        }
    }
    
}
