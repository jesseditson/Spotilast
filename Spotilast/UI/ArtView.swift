//
//  ArtView.swift
//  Spotilast
//
//  Created by Jesse Ditson on 11/14/15.
//  Copyright © 2015 Prix Fixe Labs. All rights reserved.
//

import Foundation
import Cocoa

class ArtImageView: NSView {
    
    var image: NSImage? {
        didSet {
            setNeedsDisplayInRect(frame)
        }
    }
    
    override var mouseDownCanMoveWindow:Bool {
        get {
            return true
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        image?.drawInRect(frame)
    }
}

class ArtView: NSView {
    
    override var mouseDownCanMoveWindow:Bool {
        return true
    }
    
    private var blurredImage: NSImage?
    private var image: NSImage? {
        didSet {
            imageView.image = image
        }
    }
    private var currentURL: NSURL = NSURL()
    var url: NSURL? {
        didSet {
            if url != currentURL {
                currentURL = url!
                loadImage()
            }
        }
    }
    
    private var isBlurred: Bool = false
    var blurred: Bool = false {
        didSet {
            if isBlurred != blurred {
                isBlurred = blurred
                animateBlur()
            }
        }
    }
    
    @IBInspectable var blurOpacity: CGFloat = 0.6 {
        didSet {
            setNeedsDisplayInRect(frame)
        }
    }
    
    var imageView: ArtImageView!
    override func awakeFromNib() {
        imageView = ArtImageView(frame: frame)
        super.awakeFromNib()
        addSubview(imageView)
    }
    
    private func createBlurredImage(imageData: NSData) {
        let blurSize: CGFloat = 8
        let inputImage = CIImage(data: imageData)
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(blurSize, forKey: kCIInputRadiusKey)
        let outputImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
        
        let imageRect = NSRectFromCGRect(inputImage!.extent)
        let blurredImage = NSImage(size: imageRect.size)
        blurredImage.lockFocus()
        outputImage.drawAtPoint(NSPoint(x: -(blurSize * 2), y: -(blurSize * 2)), fromRect: imageRect, operation: .CompositeSourceOver, fraction: blurOpacity)
        blurredImage.unlockFocus()
        
        self.blurredImage = blurredImage
    }
    
    private func loadImage() {
        if let url = url {
            let session = NSURLSession.sharedSession()
            let request = NSURLRequest(URL: url)
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                if let data = data {
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.image = NSImage(data: data)
                        self.createBlurredImage(data)
                    }
                }
            }
            task.resume()
        }
    }
    private func opacityAnimation(from: CGFloat, to: CGFloat) -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation()
        opacityAnimation.keyPath = "opacity"
        opacityAnimation.fromValue = from
        opacityAnimation.toValue = to
        opacityAnimation.duration = 0.12
        opacityAnimation.delegate = self
        return opacityAnimation
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
    }
    override func animationDidStart(anim: CAAnimation) {
        if blurred {
            imageView.image = blurredImage
        } else {
            imageView.image = image
        }
    }
    
    private func animateBlur() {
        var from = blurredImage
        var to = image
        if blurred {
            from = image
            to = blurredImage
        }
        let anim = CABasicAnimation(keyPath: "contents")
        anim.fromValue = from
        anim.toValue = to
        anim.duration = 0.2
        anim.delegate = self
        imageView.layer?.addAnimation(anim, forKey: "test")
    }
}
