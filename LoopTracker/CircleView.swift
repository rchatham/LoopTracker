//
//  CircleView.swift
//  LoopTracker
//
//  Created by Reid Chatham on 12/8/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit


internal class CircleView : UIView {
    
    var color = UIColor.white {
        didSet {
            circleView.backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private var circleView: UIView!
    
    func setup() {
        
        let radius = min(frame.size.width/2, frame.size.height/2)
        let view = UIView(frame: CGRect(x: frame.size.width/2-radius, y: frame.size.height/2-radius, width: radius*2, height: radius*2))
        view.backgroundColor = color
        view.layer.cornerRadius = radius
        view.clipsToBounds = true
        self.addSubview(view)
        circleView = view
    }
}
