//
//  JSWebView.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/13/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import Foundation
import WebKit

class JSWebView: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    private let contentController = WKUserContentController()
    
    private var controlScript: String {
        let scriptFile = NSBundle.mainBundle().pathForResource("control", ofType: "js")!
        let scriptString = try? NSString(contentsOfFile: scriptFile, encoding: NSUTF8StringEncoding)
        return scriptString as! String
    }
    
    var messages: Array<String> = []
    
    func load(containerView: NSView?) {
        // set up our content controller
        let userScript = WKUserScript(source: controlScript, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        for message in messages {
            contentController.addScriptMessageHandler(self, name: message)
        }
        
        // set up our web view
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.plugInsEnabled = true
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        var frame = CGRectMake(0, 0, 1200, 400)
        if containerView != nil {
            frame = (containerView?.frame)!
        }
        
        webView = WKWebView(frame: frame, configuration: config)
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)
        
        containerView?.addSubview(webView)
    }
    
    func loadURL(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func handleMessage(name: String, text: String?, body: NSDictionary?) {
        print("unhandled message: \(name) : \(text ?? body)")
    }
    
    // MARK: WKScriptMessageHandler
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let text = message.body as? String
        let body = message.body as? NSDictionary
        self.handleMessage(message.name, text: text, body: body)
    }
    
    // MARK: WKWebViewNavigationDelegate
    
    //    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
    //        let headerFields = navigationAction.request.allHTTPHeaderFields
    //        print("url: \(navigationAction.request.URL)")
    //        print("HEADERS: \(headerFields) \(headerFields?["Cookie"])")
    //        // always allow navigating to URLs that are not the home URL
    //        if navigationAction.request.URL != lastHomeURL {
    //            return decisionHandler(WKNavigationActionPolicy.Allow)
    //        }
    //
    //        if headerFields?["Cookie"] == nil {
    //            // no cookies, redirect to login
    //            decisionHandler(WKNavigationActionPolicy.Cancel)
    //            loadURL(lastLoginURL)
    //            delegate?.lastShouldShowWebView()
    //        } else {
    //            print(headerFields?["Cookie"])
    //            decisionHandler(WKNavigationActionPolicy.Allow)
    //            delegate?.lastShouldHideWebView()
    //        }
    //    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if object as! NSObject == webView && keyPath == "estimatedProgress" {
            if let progress = change?["new"] as? Float {
                let percent = progress * 100
                print(NSString(format: "Loading... %.2f%%", percent))
                if percent == 100 {
                    // TODO: Done Loading
                } else {
                    // TODO: update loading
                }
            }
        }
    }
}