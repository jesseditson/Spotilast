//
//  LoveButton.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/13/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import Foundation
import Cocoa

class LoveButton: NSButton {
    var isLoved: Bool = false {
        didSet {
            update()
        }
    }
    
    private func update() {
        if isLoved {
            title = "Unlove"
        } else {
            title = "Love"
        }
    }
}