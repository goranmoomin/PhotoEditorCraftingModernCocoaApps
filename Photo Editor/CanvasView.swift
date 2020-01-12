/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The CanvasView is a basic NSView subclass that demonstrates using updateLayer/wantsUpdateLayer by adding a drop shadow and a simple white fill color.
 */

import Cocoa

class CanvasView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    private func commonSetup() {
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        let shadow = NSShadow()
        shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.66)
        shadow.shadowBlurRadius = 4.0
        shadow.shadowOffset = NSSize(width: 0.0, height: 2.0)
        self.shadow = shadow
    }

    // Make the origin be the top left
    override var isFlipped: Bool {
        return true
    }
    
    override var isOpaque: Bool {
        return true
    }
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func updateLayer() {
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
}
