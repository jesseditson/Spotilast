//
//  TrackWebView.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/13/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import Foundation
import WebKit

protocol TrackWebViewDelegate {
    func trackLoaded(info: NSDictionary)
    func trackError(error: String)
}

class TrackWebView: JSWebView {
    
    var delegate: TrackWebViewDelegate?
    
    override init() {
        super.init()
        messages = [
            "trackInfo",
            "error"
        ]
    }
    
    override func load(containerView: NSView?) {
        super.load(containerView)
    }
    
    func loadTrack(url: String) {
        // load the last.fm track view
        loadURL(NSURL(string: url)!)
    }
    
    override func handleMessage(name: String, text: String?, body: NSDictionary?) {
        switch name {
        case "trackInfo":
            self.delegate?.trackLoaded(body!)
        case "error":
            self.delegate?.trackError(text!)
        default:
            super.handleMessage(name, text: text, body: body)
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation) {
        webView.evaluateJavaScript("getTrackInfo()") { (msg, err) -> Void in
            print("loaded track info")
        }
    }
}