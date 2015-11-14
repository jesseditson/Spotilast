//
//  HoverableView.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/14/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import Foundation
import Cocoa

protocol HoverableViewDelegate {
    func mouseEntered()
    func mouseExited()
}

class HoverableView: NSView {
    
    var trackingRect: NSTrackingRectTag?
    var delegate: HoverableViewDelegate?
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        trackingRect = addTrackingRect(frame, owner: self, userData: nil, assumeInside: false)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        super.mouseEntered(theEvent)
        delegate?.mouseEntered()
    }
    override func mouseExited(theEvent: NSEvent) {
        super.mouseExited(theEvent)
        delegate?.mouseExited()
    }
}