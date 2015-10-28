//
//  LoopTracker.swift
//  BeatClock
//
//  Created by Reid Chatham on 10/24/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit

public class LoopTracker: UIView {
    
    private var beatInfo : (beatsPerLoop: Double, bpm: Double, beatCount: Double)!
    
    private struct Constants {
        static let AnimationChangeTimeStep : Double = 0.01
    }
    
    public var ringOuterRadius : CGFloat!
    public var ringWidth : CGFloat!
    public var beatCounterRadius : CGFloat! {
        didSet {
            beatCounter?.frame = CGRect(x: frame.width/2-beatCounterRadius, y: frame.height/2-beatCounterRadius, width: beatCounterRadius*2, height: beatCounterRadius*2)
            beatCounter?.backgroundColor = color
            beatCounter?.alpha = 0.0
            beatCounter?.layer.cornerRadius = beatCounterRadius
            beatCounter?.clipsToBounds = true
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    
    private var beatCounter : UIView!
    
    public var color = UIColor.whiteColor().colorWithAlphaComponent(1.0)
    
    
    private func setup() {
        self.backgroundColor = UIColor.clearColor()
        
        //Determine initial radii
        let maxRadius = min(frame.width/2, frame.height/2)
        ringOuterRadius = maxRadius
        ringWidth = maxRadius - maxRadius*0.8
        beatCounterRadius = maxRadius*0.7
        
        //Create Beat Counter
        beatCounter = UIView(frame: CGRect(x: frame.width/2-beatCounterRadius, y: frame.height/2-beatCounterRadius, width: beatCounterRadius*2, height: beatCounterRadius*2))
        beatCounter.backgroundColor = color
        beatCounter.alpha = 0.0
        beatCounter.layer.cornerRadius = beatCounterRadius
        beatCounter.clipsToBounds = true
        self.addSubview(beatCounter)
    }
    
    
    public var clockwise = true
    
    private var animationTimer : NSTimer!
    
    private var startProgress : Double = 0
    private var progress : Double = 0
    private var endProgress : Double = 0
    private var animationProgressStep : Double = 0
    
    public func beatElapsed(beatInfo : (beatsPerLoop: Double, bpm: Double, beatCount: Double)) {
        self.beatInfo = beatInfo
        
        animationTimer?.invalidate()
        animationTimer = nil
        
        animateBeatElapsed()
    }
    
    
    public var duration : Double { return 60/beatInfo.bpm }
    
    private func animateBeatElapsed() {
        
        if beatInfo == nil {
            fatalError("No update method set")
        }
        
        startProgress = progress
        endProgress = beatInfo.beatCount / beatInfo.beatsPerLoop
        if endProgress == 1/beatInfo.beatsPerLoop {
            startProgress = 0
        }
        
        if endProgress == 1 {
            finishingAnimation()
        } else {
            standardAnimation()
        }
        
        
    }
    
    private func standardAnimation() {
        
        animationProgressStep = (endProgress-startProgress) * Constants.AnimationChangeTimeStep / duration
        
        animationTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.AnimationChangeTimeStep, target: self, selector: Selector("updateBeatForAnimation"), userInfo: nil, repeats: true)
        
        
        UIView.animateWithDuration(duration/2, animations: {
            [unowned self] in
            self.beatCounter.alpha = 1.0 - self.alphaReduction
            }) { [unowned self]
                (success) -> Void in
                
                UIView.animateWithDuration(self.duration/2, animations: {
                    [unowned self] in
                    self.beatCounter.alpha = 0.0
                    })
                
        }
    }
    
    private var resizingView : UIView!
    
    private var finishingAnimationInProgress = false
    
    private func finishingAnimation() {
    
        standardAnimation()
        
        resizingView = UIView(frame: CGRect(x: frame.width/2-ringOuterRadius, y: frame.height/2-ringOuterRadius, width: ringOuterRadius*2, height: ringOuterRadius*2))
        resizingView.backgroundColor = color
        resizingView.alpha = 0.0
        resizingView.layer.cornerRadius = ringOuterRadius
        resizingView.clipsToBounds = true
        self.addSubview(resizingView)
        
        resizingView.resizeCircleView(frame: CGRect(origin: beatCounter.frame.origin, size: beatCounter.frame.size), duration: duration)
        
        UIView.animateWithDuration(duration, animations: {
            [unowned self] in
            
            self.finishingAnimationInProgress = true
            
            self.resizingView.alpha = 1.0
            
            }) { [unowned self]
                (success) -> Void in
                
                self.resizingView.removeFromSuperview()
                
                var explodingViews = [UIView]()
                
                for _ in 0..<Int(self.beatInfo.beatsPerLoop) {
                    
                    let maxRadius = min(self.frame.width/2, self.frame.height/2)
                    
                    let r = maxRadius*0.05
                    
                    let view = ExplodingView(frame: CGRect(x: (self.frame.width/2)-r, y: (self.frame.height/2)-r, width: 2*r, height: 2*r))
                    view.color = self.color.colorWithAlphaComponent(1.0)
                    self.addSubview(view)
                    explodingViews.append(view)
                }
                
                UIView.animateWithDuration(self.duration, animations: {
                    [unowned self] in
                    
                    for index in 0..<explodingViews.count {
                        let distanceToExplode = self.ringOuterRadius // + CGFloat(arc4random())%(self.ringWidth)
                        let newX = (CGFloat(cos(2*M_PI*Double(index+1)/Double(explodingViews.count))) * distanceToExplode) + self.frame.width/2
                        let newY = (CGFloat(sin(2*M_PI*Double(index+1)/Double(explodingViews.count))) * distanceToExplode) + self.frame.height/2
                        let newCenter = CGPoint(x: newX, y: newY)
                        explodingViews[index].frame.size.width = 4
                        explodingViews[index].frame.size.height = 4
                        explodingViews[index].center = newCenter
                        explodingViews[index].alpha = 0.0
                    }
                    
                    }, completion: {
                        [unowned self]
                        (success) -> Void in
                        
                        self.finishingAnimationInProgress = false
                        
                        for view in explodingViews {
                            view.removeFromSuperview()
                        }
                })
                
        }
        
    }
    
    private var alphaReduction : CGFloat = 0.0
    
    func updateBeatForAnimation() {
        
        let numberOfAnimations = duration/Constants.AnimationChangeTimeStep

        if endProgress > (beatInfo.beatsPerLoop-1)/beatInfo.beatsPerLoop {
            alphaReduction += 1.0/CGFloat(numberOfAnimations)
            alphaReduction = min(alphaReduction, 1.0)
        } else if finishingAnimationInProgress == false {
            alphaReduction -= 1.0/CGFloat(numberOfAnimations)
            alphaReduction = max(alphaReduction, 0.0)
        }
        let currentAlpha = 1.0 - alphaReduction
        color = color.colorWithAlphaComponent(currentAlpha)
        
        
        progress += animationProgressStep
        
        if (animationProgressStep > 0 && progress >= endProgress) || (animationProgressStep < 0 && progress <= endProgress) {
            animationTimer?.invalidate()
            animationTimer = nil
            progress = endProgress
        }
        
        setNeedsDisplay()
    }
    
    override public func drawRect(rect: CGRect) {
        drawLoopCounter(ringOuterRadius)
    }
    

    private func drawLoopCounter(radius: CGFloat) {
        let innerRadius = radius - ringWidth
        
        let radiansToDraw = CGFloat(2*M_PI * Double(progress))
        
        let loop = UIBezierPath()
        loop.moveToPoint(CGPoint(x: frame.width/2, y: frame.height/2-innerRadius))
        loop.addLineToPoint(CGPoint(x: frame.width/2, y: frame.height/2-radius))
        loop.addArcWithCenter(CGPoint(x: frame.width/2, y: frame.height/2), radius: radius, startAngle: -CGFloat(0.5*M_PI), endAngle: radiansToDraw-CGFloat(0.5*M_PI), clockwise: clockwise)
        
        let p = loop.currentPoint
        let newX = ((p.x - frame.width/2) * innerRadius/radius) + frame.width/2
        let newY = ((p.y - frame.height/2) * innerRadius/radius) + frame.height/2
        
        loop.addLineToPoint(CGPoint(x: newX, y: newY))
        loop.addArcWithCenter(CGPoint(x: frame.width/2, y: frame.height/2), radius: innerRadius, startAngle: radiansToDraw-CGFloat(0.5*M_PI), endAngle: -CGFloat(0.5*M_PI), clockwise: !clockwise)
        
        loop.closePath()
        color.setFill()
        loop.fill()
    }
}

private class ExplodingView : UIView {
    
    var color = UIColor.whiteColor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        let radius = min(frame.size.width/2, frame.size.height/2)
        let view = UIView(frame: CGRect(x: frame.size.width/2-radius, y: frame.size.height/2-radius, width: radius*2, height: radius*2))
        view.backgroundColor = color
        view.layer.cornerRadius = radius
        view.clipsToBounds = true
        self.addSubview(view)
    }
}

private extension UIView {
    
    func resizeCircleView(frame frame: CGRect, duration: Double) {
        
        let estimateFrame = frame
        
        UIView.animateWithDuration(duration) {
            [unowned self] in
            self.frame = estimateFrame
        }
        
        let estimateCorner = estimateFrame.size.width/2
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.layer.cornerRadius
        animation.duration = duration
        self.layer.cornerRadius = estimateCorner
        self.layer.addAnimation(animation, forKey: "cornerRadius")
    }
}
