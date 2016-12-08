//
//  LoopTrackerView.swift
//  LoopTracker
//
//  Created by Reid Chatham on 11/20/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//
//
//import UIKit
//
//
//class LoopTrackerView: UIView {
//
//    let color : UIColor = UIColor.white
//    let ringOuterRadius : CGFloat = 0.0
//    let ringWidth : CGFloat = 0.0
//    let clockwise : Bool = true
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setup()
////        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setup() {
//        
//    }
//    
//    
//    
//    var progress: CGFloat!
//    
//    func setProgress(_ progress: CGFloat) {
//        self.progress = progress
//    }
//    
//    override func draw(_ rect: CGRect) {
//        drawLoopCounter(ringOuterRadius)
//    }
//    
//    
//    
//    fileprivate func drawLoopCounter(_ radius: CGFloat) {
//        let innerRadius = radius - ringWidth
//        
//        let radiansToDraw = CGFloat(2*M_PI * Double(progress))
//        
//        let loop = UIBezierPath()
//        loop.move(to: CGPoint(x: frame.width/2, y: frame.height/2-innerRadius))
//        loop.addLine(to: CGPoint(x: frame.width/2, y: frame.height/2-radius))
//        loop.addArc(withCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: radius, startAngle: -CGFloat(0.5*M_PI), endAngle: radiansToDraw-CGFloat(0.5*M_PI), clockwise: clockwise)
//        
//        let p = loop.currentPoint
//        let newX = ((p.x - frame.width/2) * innerRadius/radius) + frame.width/2
//        let newY = ((p.y - frame.height/2) * innerRadius/radius) + frame.height/2
//        
//        loop.addLine(to: CGPoint(x: newX, y: newY))
//        loop.addArc(withCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: innerRadius, startAngle: radiansToDraw-CGFloat(0.5*M_PI), endAngle: -CGFloat(0.5*M_PI), clockwise: !clockwise)
//        loop.close()
//        
//        color.setFill()
//        loop.fill()
//    }
//
//}
