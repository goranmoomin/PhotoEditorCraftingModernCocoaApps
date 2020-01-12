/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The CanvasScrollView exists just as a starting example of how to manually do drag and drop.
*/

import Cocoa

class CanvasScrollView: NSScrollView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    private func commonSetup() {
        registerForDraggedTypes([.URL, .fileContents])
    }
    
    // MARK: - Dragging destination support
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        sender.draggingFormation = .stack // This is one possible representation for Drag Flocking
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        sender?.draggingFormation = .default
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        sender.animatesToDestination = true
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // We perform no actual action here, but this is where you'd act upon a drag operation
        return true
    }
    
}
