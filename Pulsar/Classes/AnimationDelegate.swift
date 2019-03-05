//
//  AnimationDelegate.swift
//  Pulsar
//
//  Created by Vincent Esche on 3/5/19.
//  Copyright © 2019 Regexident. All rights reserved.
//

import QuartzCore

internal class AnimationDelegate: NSObject {
    let pulseLayer: PulseLayer
    let startBlock: Pulse.StartClosure? = nil
    let stopBlock: Pulse.StopClosure? = nil
    
    init(pulseLayer: PulseLayer) {
        self.pulseLayer = pulseLayer
    }
}

extension AnimationDelegate: CAAnimationDelegate {
    func animationDidStart(_ animation: CAAnimation) {
        if let startBlock = self.startBlock {
            startBlock(animation.duration)
        }
    }
    
    func animationDidStop(_ animation: CAAnimation, finished: Bool) {
        guard var pulseLayers = self.pulseLayer.superlayer?.pulseLayers else {
            return
        }
        if let index = pulseLayers.index(of: self.pulseLayer) {
            pulseLayers.remove(at: index)
            self.pulseLayer.removeFromSuperlayer()
            if let stopBlock = self.stopBlock {
                stopBlock(finished)
            }
        }
    }
}
