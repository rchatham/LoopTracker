//
//  UIKit+Extensions.swift
//  LoopTracker
//
//  Created by Reid Chatham on 12/8/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

internal extension UIView {
    
    func resizeCircleView(frame: CGRect, duration: Double) {
        
        let estimateFrame = frame
        
        UIView.animate(withDuration: duration, animations: {
            [unowned self] in
            self.frame = estimateFrame
        })
        
        let estimateCorner = estimateFrame.size.width/2
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.layer.cornerRadius
        animation.duration = duration
        self.layer.cornerRadius = estimateCorner
        self.layer.add(animation, forKey: "cornerRadius")
    }
}
