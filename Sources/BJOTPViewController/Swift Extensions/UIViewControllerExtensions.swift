//
//  UIViewControllerExtensions.swift
//  swiftextensions
//  Created by Badhan Ganesh on 12/10/18.
//
// Copyright © 2022 Badhan Ganesh


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
        
        if let vc = self.presentedViewController {
            vc.present(alert, animated: true, completion: nil)
        } else {
            self.present(alert, animated: true, completion: nil)
        }
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
