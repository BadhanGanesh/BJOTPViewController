//
//  BJOTPAuthenticateButton.swift
//  bjotpviewcontroller
//
// Copyright © 2019 Badhan Ganesh



import UIKit

final class BJOTPAuthenticateButton: UIButton {
    
    var useHaptics: Bool = true
    var animate: Bool = true
    
    init() {
        super.init(frame: .zero)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if animate {
            UIView.animate(withDuration: 0.15) {
                self.transform = .init(scaleX: 0.97, y: 0.98)
                self.alpha = 0.6
            }
        }
        self.generateHaptic()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if animate {
            UIView.animate(withDuration: 0.15) {
                self.transform = .identity
                self.alpha = 1.0
            }
        }
        self.generateHaptic()
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if animate {
            UIView.animate(withDuration: 0.15) {
                self.transform = .identity
                self.alpha = 1.0
            }
        }
        self.generateHaptic()
        super.touchesCancelled(touches, with: event)
    }
    
    private func generateHaptic() {
        if (self.useHaptics) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
}
