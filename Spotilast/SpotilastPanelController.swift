//
//  SpotilastPanelController.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/12/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import AppKit

let optionKeyCode: UInt16 = 58

class SpotilastPanelController : NSWindowController, LastWebViewDelegate, TrackWebViewDelegate, ArtistWebViewDelegate, SongViewControllerDelegate {

    var mouseOver: Bool = false
    override func mouseEntered(theEvent: NSEvent) {
        mouseOver = true
        updateTranslucency()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        mouseOver = false
        updateTranslucency()
    }
    
    var alpha: CGFloat = 0.6 { //default
        didSet {
            updateTranslucency()
        }
    }
    
    func updateTranslucency() {
        currentlyTranslucent = shouldBeTranslucent()
    }
    
    func shouldBeTranslucent() -> Bool {
        /* Implicit Arguments
         * - mouseOver
         * - translucencyPreference
         * - tranlucencyEnalbed
         */
        
        guard translucencyEnabled else { return false }
        
        switch translucencyPreference {
        case .Always:
            return true
        case .MouseOver:
            return mouseOver
        case .MouseOutside:
            return !mouseOver
        }
    }
    
    enum TranslucencyPreference {
        case Always
        case MouseOver
        case MouseOutside
    }
    
    var translucencyPreference: TranslucencyPreference = .Always {
        didSet {
            updateTranslucency()
        }
    }
    
    var translucencyEnabled: Bool = false {
        didSet {
            updateTranslucency()
        }
    }
    
    var currentlyTranslucent: Bool = false {
        didSet {
            if !NSApplication.sharedApplication().active {
//                panel.ignoresMouseEvents = currentlyTranslucent
            }
            if currentlyTranslucent {
                panel.animator().alphaValue = alpha
                panel.opaque = false
            }
            else {
                panel.opaque = true
                panel.animator().alphaValue = 1
            }
        }
    }
    
    
    var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }
    
    var songViewController: SongViewController {
        get {
            return self.window?.contentViewController as! SongViewController
        }
    }
    
    // MARK: Setup
    
    let lastWebViewContainer = NSView()
    let lastWebViewWindow = NSWindow(contentRect: NSMakeRect(0, 0, 1200, 480), styleMask: NSTitledWindowMask, backing: .Buffered, `defer`: false)
    let lastView = LastWebView()
    let trackView = TrackWebView()
    let artistView = ArtistWebView()

    override func windowDidLoad() {
        panel.floatingPanel = true
        
        window?.movableByWindowBackground = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: NSApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willResignActive", name: NSApplicationWillResignActiveNotification, object: nil)
        
        // make this float over fullscreen apps
        panel.collectionBehavior = [.CanJoinAllSpaces, .FullScreenAuxiliary]
        // could also be: [.MoveToActiveSpace, .FullScreenAuxiliary] to not float over fullscreen
        
        lastWebViewWindow.opaque = false
        lastWebViewWindow.movableByWindowBackground = true
        lastWebViewWindow.backgroundColor = NSColor(hue: 0, saturation: 1, brightness: 0, alpha: 0.7)
        lastWebViewWindow.contentView?.addSubview(lastWebViewContainer)
        lastWebViewContainer.frame = lastWebViewWindow.contentView!.bounds
        
        lastShouldHideWebView()
        
        lastView.delegate = self
        lastView.load(lastWebViewContainer)
        
        trackView.delegate = self
        trackView.load(nil)
        artistView.delegate = self
        artistView.load(nil)
        
        songViewController.delegate = self
    }
    
    // MARK: LastWebViewDelegate
    
    func lastWebViewDidLoad() {
        songViewController.isLoading = false
    }
    
    func lastShouldShowWebView() {
        lastWebViewWindow.setIsVisible(true)
        lastWebViewWindow.makeKeyAndOrderFront(nil)
    }
    
    func lastShouldHideWebView() {
        lastWebViewWindow.setIsVisible(false)
        window?.makeKeyAndOrderFront(nil)
    }
    
    var currentArtistURL: String = ""
    var currentTrackURL: String = ""
    
    func lastStateUpdated(state: NSDictionary) {
        if let loved = state["loved"] as? Bool {
            songViewController.isLoved = loved
        }
        if let playing = state["playing"] as? Bool {
            songViewController.isPlaying = playing
        }
        if let provider = state["provider"] as? String {
            songViewController.provider = provider
        }
        if let status = state["status"] as? String {
            songViewController.status = status
        }
        if let trackInfo = state["trackInfo"] as? NSDictionary {
            if let trackTitle = trackInfo["title"] as? String {
                songViewController.trackTitle = trackTitle
            }
            if let artist = trackInfo["artist"] as? String {
                songViewController.artistName = artist
            }
            if let url = trackInfo["url"] as? String {
                if url != currentTrackURL {
                    trackView.loadTrack(url)
                    currentTrackURL = url
                }
            }
            if let artistUrl = trackInfo["artistUrl"] as? String {
                if artistUrl != currentArtistURL {
                    artistView.loadArtist(artistUrl)
                    currentArtistURL = artistUrl
                }
            }
            // TODO: elapsed and remaining keys exist as well
        }
        print("\(state)")
    }
    
    func lastError(error: String) {
        print(error)
    }
    
    // MARK: TrackWebViewDelegate
    func trackLoaded(info: NSDictionary) {
        if let url = info["art"] as? String {
            songViewController.trackImageURL = NSURL(string: url)
        }
        if let listenText = info["listenText"] as? String {
            songViewController.listenStats = listenText
        }
    }
    func trackError(error: String) {
        // TODO:
    }
    
    // MARK: ArtistWebViewDelegate
    func artistLoaded(info: NSDictionary) {
        if let imageURL = info["avatar"] as? String {
            songViewController.artistImageURL = NSURL(string: imageURL)
        }
        if let wiki = info["wiki"] as? String {
            songViewController.artistInfo = wiki
        }
    }
    func artistError(error: String) {
        // TODO:
    }
    
    // MARK: SongViewController
    
    func songViewDidSelectLibrary() {
        lastView.playLibrary()
    }
    func songViewDidSelectMix() {
        lastView.playMix()
    }
    func songViewDidSelectRecommended() {
        lastView.playRecommended()
    }
    func songViewDidSkip() {
        lastView.next()
    }
    func songViewDidToggleLove() {
        lastView.toggleLove()
    }
    func songViewDidTogglePlay() {
        lastView.togglePlay()
    }
    func songViewRetry() {
        lastView.retryConnection()
    }
    
    // MARK: IBActions
    
    @IBAction func showWebView(sender: NSMenuItem) {
        lastShouldShowWebView()
    }
    
    // TODO: adjust or create the below
//    func disabledAllMouseOverPreferences(allMenus: [NSMenuItem]) {
//        // GROSS HARD CODED
//        for x in allMenus.dropFirst(2) {
//            x.state = NSOffState
//        }
//    }
    
    @IBAction func alwaysPreferencePress(sender: NSMenuItem) {
//        disabledAllMouseOverPreferences(sender.menu!.itemArray)
        translucencyPreference = .Always
        sender.state = NSOnState
    }
    @IBAction func overPreferencePress(sender: NSMenuItem) {
//        disabledAllMouseOverPreferences(sender.menu!.itemArray)
        translucencyPreference = .MouseOver
        sender.state = NSOnState
    }
    @IBAction func outsidePreferencePress(sender: NSMenuItem) {
//        disabledAllMouseOverPreferences(sender.menu!.itemArray)
        translucencyPreference = .MouseOutside
        sender.state = NSOnState
    }
    
    @IBAction func translucencyPress(sender: NSMenuItem) {
        if sender.state == NSOnState {
            sender.state = NSOffState
            didDisableTranslucency()
        }
        else {
            sender.state = NSOnState
            didEnableTranslucency()
        }
    }
    
    @IBAction func percentagePress(sender: NSMenuItem) {
        for button in sender.menu!.itemArray{
            (button ).state = NSOffState
        }
        sender.state = NSOnState
        let value = sender.title.substringToIndex(sender.title.endIndex.advancedBy(-1))
        if let alpha = Int(value) {
             didUpdateAlpha(CGFloat(alpha))
        }
    }
    
    // MARK: functionality
    
    func didBecomeActive() {
//        panel.ignoresMouseEvents = false
    }
    
    func willResignActive() {
        if currentlyTranslucent {
//            panel.ignoresMouseEvents = true
        }
    }
    
    func didEnableTranslucency() {
        translucencyEnabled = true
    }
    
    func didDisableTranslucency() {
        translucencyEnabled = false
    }
    
    func didUpdateAlpha(newAlpha: CGFloat) {
        alpha = newAlpha / 100
    }
}