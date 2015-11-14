//
//  PlayButton.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/13/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import Foundation
import Cocoa

class PlayButton: NSButton {
    var isPlaying: Bool = false {
        didSet {
            update()
        }
    }
    
    private func update() {
        if isPlaying {
            title = "Pause"
        } else {
            title = "Play"
        }
    }
}