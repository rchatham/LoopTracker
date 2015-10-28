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
    
    
    var pieTimer : NSTimer!
    
    var loopTracker : LoopTracker!
    
    var beatInfo : (beatsPerLoop: Double, bpm: Double, beatCount: Double) {
        return (beatsPerLoop, bpm, beatCount)
    }
    
    var beatsPerLoop = 64.0
    var beatCount = 1.0
    var bpm = 128.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.blackColor()
        
        
        loopTracker = LoopTracker(frame: CGRect(x: view.center.x-100, y: view.center.y-100, width: 200, height: 200))
        view.addSubview(loopTracker)
        pieTimer = NSTimer.scheduledTimerWithTimeInterval( Double(60)/Double(bpm), target: self, selector: Selector("updatePie:"), userInfo: nil, repeats: true)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func updatePie(timer: NSTimer) {
        
        if beatInfo.beatCount < beatInfo.beatsPerLoop {
            ++beatCount
        } else {
            beatCount = 1
        }
        
//        beatsElapsedLabel.text = "\(beatCount)"
        
        loopTracker.beatElapsed(beatInfo)
        
    }

}

