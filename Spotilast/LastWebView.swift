//
//  LastWebView.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/12/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import Foundation
import WebKit

protocol LastWebViewDelegate {
    func lastWebViewDidLoad()
    func lastShouldShowWebView()
    func lastShouldHideWebView()
    func lastStateUpdated(state: NSDictionary)
    func lastError(error: String)
}

class LastWebView: JSWebView {
    
    var delegate: LastWebViewDelegate?
    var loading: Bool {
        return isLoading
    }
    
    private var isLoading = true
    
    private let lastHomeURL = NSURL(string: "http://last.fm/home")!
    private let lastLoginURL = NSURL(string: "https://secure.last.fm/login")!
    
    override init() {
        super.init()
        messages = [
            "login",
            "state",
            "error"
        ]
    }
    
    // actions:
    private func clickButton(name: String) {
        webView.evaluateJavaScript("clickButton('\(name)')") { (res, err) -> Void in
            if (err != nil) {
                print("error clicking \(name): \(err)")
            }
        }
    }
    func playLibrary() {
        clickButton("libraryRadio")
    }
    func playMix() {
        clickButton("mixRadio")
    }
    func playRecommended() {
        clickButton("recsRadio")
    }
    func togglePlay() {
        clickButton("playButton")
    }
    func previous() {
        clickButton("prevButton")
    }
    func next() {
        clickButton("nextButton")
    }
    func toggleLove() {
        clickButton("loveButton")
    }
    func retryConnection() {
        webView.evaluateJavaScript("retryConnection()") { (res, err) -> Void in
            if (err != nil) {
                print("error retrying connection: \(err)")
            }
        }
    }
    
    override func load(containerView: NSView?) {
        super.load(containerView)
        // load the last.fm view by default
        loadURL(lastHomeURL)
    }
    
    override func handleMessage(name: String, text: String?, body: NSDictionary?) {
        switch name {
        case "login":
            if text == "true" { loggedIn() } else { loggedOut() }
        case "state":
            self.delegate?.lastStateUpdated(body!)
        case "error":
            self.delegate?.lastError(text!)
        default:
            super.handleMessage(name, text: text, body: body)
        }
    }
    
    private func loggedIn() {
        loadURL(lastHomeURL)
        delegate?.lastShouldHideWebView()
    }
    private func loggedOut() {
        loadURL(lastLoginURL)
        delegate?.lastShouldShowWebView()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation) {
        print("Loaded")
        // TODO: log in
        isLoading = false
        delegate?.lastWebViewDidLoad()
    }
}