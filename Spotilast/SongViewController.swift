//
//  ViewController.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/12/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import Cocoa

protocol SongViewControllerDelegate {
    // not playing
    func songViewDidSelectLibrary()
    func songViewDidSelectMix()
    func songViewDidSelectRecommended()
    // failed
    func songViewRetry()
    // playing
    func songViewDidSkip()
    func songViewDidTogglePlay()
    func songViewDidToggleLove()
}

class SongViewController: NSViewController, HoverableViewDelegate {
    
    var delegate: SongViewControllerDelegate?
    
    // MARK: Settable, UI-controlling vars
    var hovered = false { didSet { redraw() } }
    var isLoading: Bool = true { didSet { redraw() } }
    var isLoved: Bool = false { didSet { redraw() } }
    var isPlaying: Bool = false { didSet { redraw() } }
    var trackTitle: String = "Track Name" { didSet { redraw() } }
    var trackImageURL: NSURL? { didSet { redraw() } }
    var artistName: String = "Artist Name" { didSet { redraw() } }
    var artistImageURL: NSURL? { didSet { redraw() } }
    var artistInfo: String = "Artist Info" { didSet { redraw() } }
    var provider: String? { didSet { redraw() } }
    var status: String? { didSet { redraw() } }
    var listenStats: String = "Listen Stats" { didSet { redraw() } }
    
    // MARK: Actions
    @IBAction func chooseLibrary(_: AnyObject) {
        delegate?.songViewDidSelectLibrary()
    }
    @IBAction func chooseMix(_: AnyObject) {
        delegate?.songViewDidSelectMix()
    }
    @IBAction func chooseRecommended(_: AnyObject) {
        delegate?.songViewDidSelectRecommended()
    }
    @IBAction func skip(_: AnyObject) {
        delegate?.songViewDidSkip()
    }
    @IBAction func togglePlay(_: AnyObject) {
        delegate?.songViewDidTogglePlay()
    }
    @IBAction func toggleLove(_: AnyObject) {
        delegate?.songViewDidToggleLove()
    }
    @IBAction func showInfo(_: AnyObject) {
        // TODO: show song info
    }
    @IBAction func retry(_: AnyObject) {
        delegate?.songViewRetry()
    }
    
    // MARK: Outlets
    @IBOutlet var loadingView: NSView!
    @IBOutlet var chooseRadioView: NSView!
    @IBOutlet var controlsView: NSView!
    @IBOutlet var playingView: NSView!
    @IBOutlet var playButton: PlayButton!
    @IBOutlet var loveButton: LoveButton!
    @IBOutlet var trackNameLabel: NSTextField!
    @IBOutlet var albumArtView: ArtView!
    @IBOutlet var artistNameLabel: NSTextField!
    @IBOutlet var infoTextLabel: NSTextView!
    @IBOutlet var loadingStatusTextLabel: NSTextField!
    @IBOutlet var loadingSpinner: NSProgressIndicator!
    @IBOutlet var retryButton: NSButton!
    @IBOutlet var listenStatsLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let hoverView = view as? HoverableView {
            hoverView.delegate = self
        }
        
        infoTextLabel.textContainerInset = NSSize(width: 12, height: 12)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        redraw()
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func redraw() {
        var loading = isLoading
        var showRetry = false
        if (status?.lowercaseString.rangeOfString("connecting")) != nil {
            loading = true
        }
        if (status?.lowercaseString.rangeOfString("failed") != nil) {
            loading = true
            showRetry = true
        }
        retryButton.hidden = !showRetry
        loadingSpinner.hidden = showRetry
        loadingView.hidden = !loading
        if loading {
            if status != nil {
                loadingStatusTextLabel.stringValue = status!
            }
            chooseRadioView.hidden = true
            playingView.hidden = true
            albumArtView.hidden = true
            return
        }
        let radioPlaying = provider != nil && provider != "unknown"
        chooseRadioView.hidden = radioPlaying
        albumArtView.hidden = !radioPlaying
        
        if radioPlaying && hovered {
            playingView.hidden = false
            albumArtView.blurred = true
            listenStatsLabel.stringValue = listenStats
            playButton.isPlaying = isPlaying
            loveButton.isLoved = isLoved
            trackNameLabel.stringValue = trackTitle
            albumArtView.url = trackImageURL
            artistNameLabel.stringValue = artistName
            infoTextLabel.string = artistInfo
        } else if radioPlaying {
            playingView.hidden = true
            albumArtView.blurred = false
        }
    }
    
    // MARK: HoverableViewDelegate
    
    func mouseEntered() {
        hovered = true
    }
    
    func mouseExited() {
        hovered = false
    }
}

