//
//  ArtistWebView.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/13/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import Foundation
import WebKit

protocol ArtistWebViewDelegate {
    func artistLoaded(info: NSDictionary)
    func artistError(error: String)
}

class ArtistWebView: JSWebView {
    
    var delegate: ArtistWebViewDelegate?
    
    override init() {
        super.init()
        messages = [
            "artistInfo",
            "error"
        ]
    }
    
    override func load(containerView: NSView?) {
        super.load(containerView)
    }
    
    func loadArtist(url: String) {
        // load the last.fm artist wiki
        loadURL(NSURL(string: "\(url)/+wiki")!)
    }
    
    override func handleMessage(name: String, text: String?, body: NSDictionary?) {
        switch name {
        case "artistInfo":
            self.delegate?.artistLoaded(body!)
        case "error":
            self.delegate?.artistError(text!)
        default:
            super.handleMessage(name, text: text, body: body)
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation) {
        webView.evaluateJavaScript("getArtistInfo()") { (msg, err) -> Void in
            print("loaded artist info")
        }
    }
}