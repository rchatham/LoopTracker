//
//  LoopTracker.swift
//  BeatClock
//
//  Created by Reid Chatham on 10/24/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//


import UIKit

open class LoopTracker: UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    /// Set this to false to make the loop unwind instead of fill
    open var clockwise = true
    
    open var color = UIColor.white.withAlphaComponent(1.0)
    
    /// Sets a custom outer ring radius
    open var ringOuterRadius : CGFloat!
    /// Sets a custom outer ring width
    open var ringWidth : CGFloat!
    /// Sets a custom radius for the beat counter
    open var beatCounterRadius : CGFloat! {
        didSet {
            beatCounter?.frame = CGRect(x: frame.width/2-beatCounterRadius, y: frame.height/2-beatCounterRadius, width: beatCounterRadius*2, height: beatCounterRadius*2)
            beatCounter?.backgroundColor = color
            beatCounter?.alpha = 0.0
            beatCounter?.layer.cornerRadius = beatCounterRadius
            beatCounter?.clipsToBounds = true
        }
    }
    
    /// Gives the length of the current animation
    /// The finishingAnimation() has a trailing animation that is also the same length
    open var duration : Double { return 60/beatInfo.bpm }
    
    /// Call this method to update the animation for the current beat
    open func beatElapsed(_ beatInfo : (beatsPerLoop: Double, bpm: Double, beatCount: Double)) {
        self.beatInfo = beatInfo
        
        animationTimer?.invalidate()
        animationTimer = nil
        
        animateBeatElapsed()
    }
    
    /// DO NOT CALL THIS FUNCTION DIRECTLY!!!
    /// Call beatElapsed instead
    override open func draw(_ rect: CGRect) {
        drawLoopCounter(ringOuterRadius)
    }
    
    // MARK: - Internal
    
    internal func updateBeatForAnimation() {
        
        let endProgress = beatInfo.beatCount / beatInfo.beatsPerLoop
        let numberOfAnimations = duration/Constants.animationChangeTimeStep
        
        if endProgress > (beatInfo.beatsPerLoop-1)/beatInfo.beatsPerLoop {
            alphaReduction += 1.0/CGFloat(numberOfAnimations)
            alphaReduction = min(alphaReduction, 1.0)
        } else if finishingAnimationInProgress == false {
            alphaReduction -= 1.0/CGFloat(numberOfAnimations)
            alphaReduction = max(alphaReduction, 0.0)
        }
        let currentAlpha = 1.0 - alphaReduction
        color = color.withAlphaComponent(currentAlpha)
        
        
        progress += animationProgressStep
        
        if (animationProgressStep > 0 && progress >= endProgress) || (animationProgressStep < 0 && progress <= endProgress) {
            animationTimer?.invalidate()
            animationTimer = nil
            progress = endProgress
        }
        
        setNeedsDisplay()
    }
    
    // MARK: - Fileprivate
    
    fileprivate struct Constants {
        static let animationChangeTimeStep : Double = 0.01
    }
    
    fileprivate var beatInfo : (beatsPerLoop: Double, bpm: Double, beatCount: Double)!
    
    fileprivate var beatCounter : UIView!
    
    fileprivate var animationTimer : Timer!
    
    fileprivate var progress : Double = 0
    fileprivate var animationProgressStep : Double = 0
    
    fileprivate var finishingAnimationInProgress = false
    
    fileprivate var alphaReduction : CGFloat = 0.0
    
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.clear
        
        // Determine initial radii
        // Can be reset using public properties
        let maxRadius = min(frame.width/2, frame.height/2)
        ringOuterRadius = maxRadius
        ringWidth = maxRadius - maxRadius*0.8
        beatCounterRadius = maxRadius*0.7
        
        //Create Beat Counter
        beatCounter = UIView(
            frame: CGRect(
                x: frame.width/2-beatCounterRadius,
                y: frame.height/2-beatCounterRadius,
                width: beatCounterRadius*2,
                height: beatCounterRadius*2
            )
        )
        beatCounter.backgroundColor = color
        beatCounter.alpha = 0.0
        beatCounter.layer.cornerRadius = beatCounterRadius
        beatCounter.clipsToBounds = true
        
        self.addSubview(beatCounter)
    }
    
    fileprivate func animateBeatElapsed() {
        
        if beatInfo == nil {
            fatalError("Beat not set")
        }
        
        if beatInfo.beatCount == beatInfo.beatsPerLoop {
            standardAnimation()
            finishingAnimation()
        } else {
            standardAnimation()
        }
    }
    
    fileprivate func standardAnimation() {
        
        let endProgress = beatInfo.beatCount / beatInfo.beatsPerLoop
        let startProgress = beatInfo.beatCount == 1 ? 0 : progress
        
        animationProgressStep = (endProgress-startProgress) * Constants.animationChangeTimeStep / duration
        
        animationTimer = Timer.scheduledTimer(timeInterval: Constants.animationChangeTimeStep, target: self, selector: #selector(LoopTracker.updateBeatForAnimation), userInfo: nil, repeats: true)
        
        
        UIView.animate(withDuration: duration/2, animations: {
            [unowned self] in
            self.beatCounter.alpha = 1.0 - self.alphaReduction
            }, completion: { [unowned self]
                (success) -> Void in
                
                UIView.animate(withDuration: self.duration/2, animations: {
                    [unowned self] in
                    self.beatCounter.alpha = 0.0
                    })
        }) 
    }
    
    fileprivate func finishingAnimation() {
        
        let resizingView = CircleView(frame: CGRect(x: frame.width/2-ringOuterRadius, y: frame.height/2-ringOuterRadius, width: ringOuterRadius*2, height: ringOuterRadius*2))
        resizingView.backgroundColor = color
        resizingView.alpha = 0.0
        resizingView.layer.cornerRadius = ringOuterRadius
        resizingView.clipsToBounds = true
        
        self.addSubview(resizingView)
        
        resizingView.resizeCircleView(frame: CGRect(origin: beatCounter.frame.origin, size: beatCounter.frame.size), duration: duration)
        
        UIView.animate(withDuration: duration, animations: {
            [unowned self] in
            
            self.finishingAnimationInProgress = true
            
            resizingView.alpha = 1.0
            
            }, completion: { [unowned self]
                (success) -> Void in
                
                resizingView.removeFromSuperview()
                
                var explodingViews = [UIView]()
                
                for _ in 0..<Int(self.beatInfo.beatsPerLoop) {
                    
                    let maxRadius = min(self.frame.width/2, self.frame.height/2)
                    
                    let r = maxRadius*0.05
                    
                    let view = CircleView(frame: CGRect(x: (self.frame.width/2)-r, y: (self.frame.height/2)-r, width: 2*r, height: 2*r))
                    view.color = self.color.withAlphaComponent(1.0)
                    self.addSubview(view)
                    explodingViews.append(view)
                }
                
                UIView.animate(withDuration: self.duration, animations: {
                    [unowned self] in
                    
                    for index in 0..<explodingViews.count {
                        let distanceToExplode = self.ringOuterRadius // + CGFloat(arc4random())%(self.ringWidth)
                        let newX = (CGFloat(cos(2*M_PI*Double(index+1)/Double(explodingViews.count))) * distanceToExplode!) + self.frame.width/2
                        let newY = (CGFloat(sin(2*M_PI*Double(index+1)/Double(explodingViews.count))) * distanceToExplode!) + self.frame.height/2
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
        }) 
    }
    
    fileprivate func drawLoopCounter(_ radius: CGFloat) {
        let innerRadius = radius - ringWidth
        
        let radiansToDraw = CGFloat(2*M_PI * Double(progress))
        
        let loop = UIBezierPath()
        loop.move(to: CGPoint(x: frame.width/2, y: frame.height/2-innerRadius))
        loop.addLine(to: CGPoint(x: frame.width/2, y: frame.height/2-radius))
        loop.addArc(withCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: radius, startAngle: -CGFloat(0.5*M_PI), endAngle: radiansToDraw-CGFloat(0.5*M_PI), clockwise: clockwise)
        
        let p = loop.currentPoint
        let newX = ((p.x - frame.width/2) * innerRadius/radius) + frame.width/2
        let newY = ((p.y - frame.height/2) * innerRadius/radius) + frame.height/2
        
        loop.addLine(to: CGPoint(x: newX, y: newY))
        loop.addArc(withCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: innerRadius, startAngle: radiansToDraw-CGFloat(0.5*M_PI), endAngle: -CGFloat(0.5*M_PI), clockwise: !clockwise)
        loop.close()
        
        color.setFill()
        loop.fill()
    }
}
