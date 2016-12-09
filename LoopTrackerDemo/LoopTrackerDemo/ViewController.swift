//
//  ViewController.swift
//  LoopTrackerDemo
//
//  Created by Reid Chatham on 10/27/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit
import LoopTracker

class ViewController: UIViewController {
    
    
    var pieTimer : Timer!
    
    var loopTracker : LoopTracker!
//    {
//        didSet {
//            if loopTracker != nil {
//                lastTap = Date()
//                let gesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedLoopTracker(_:)))
//                gesture.numberOfTapsRequired = 1
//                gesture.numberOfTouchesRequired = 1
//                loopTracker.addGestureRecognizer(gesture)
//            }
//        }
//    }
//    
//    var lastTap : Date!
//    
//    func tappedLoopTracker(_ recognizer: UITapGestureRecognizer) {
//        
//        let timeSinceLastTap = Date().timeIntervalSince(lastTap)
//        bpm = 60.0 / timeSinceLastTap
//        beatCount = (beatCount > bpm) ? 0 : beatCount + 1
//        beatsPerLoop = bpm
//        
//        loopTracker.beatElapsed(beatInfo)
//        
//        lastTap = Date()
//    }
    
    var beatInfo : (beatsPerLoop: Double, bpm: Double, beatCount: Double) {
        return (beatsPerLoop, bpm, beatCount)
    }
    
    var beatsPerLoop = 50.0
    var beatCount = 0.0
    var bpm = 128.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.black
        
        loopTracker = LoopTracker(frame: CGRect(x: view.center.x-100, y: view.center.y-100, width: 200, height: 200))
        view.addSubview(loopTracker)
        
        pieTimer = Timer.scheduledTimer(
            timeInterval: 60.0/bpm,
            target: self,
            selector: #selector(ViewController.updatePie(_:)),
            userInfo: nil,
            repeats: true
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func updatePie(_ timer: Timer) {
        
        if beatCount < beatsPerLoop {
            beatCount += 1
        } else {
            beatCount = 0
        }
        
//        beatsElapsedLabel.text = "\(beatCount)"
        
        loopTracker.beatElapsed(beatInfo)
        
    }
    
    
    

}

