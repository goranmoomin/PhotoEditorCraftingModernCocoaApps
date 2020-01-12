/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 WindowDraggableButton is an NSButton subclass that allows the button to behave like a normal button when clicked, but begins a system drag when the user clicks and drags a certain distance inside the button.
 */

import Cocoa

class WindowDraggableButton: NSButton {

    // Allow the window to still be dragged from this button
    override func mouseDown(with mouseDownEvent: NSEvent) {
        let window = self.window!
        let startingPoint = mouseDownEvent.locationInWindow
        
        highlight(true)
        
        // Track events until the mouse is up (in which we interpret as a click), or a drag starts (in which we pass off to the Window Server to perform the drag)
        var shouldCallSuper = false
        
        // trackEvents won't return until after the tracking all ends
        window.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout:NSEvent.foreverDuration, mode: RunLoop.Mode.default) { event, stop in
            guard let event = event else { return }
            switch event.type {
                case .leftMouseUp:
                    // Stop on a mouse up; post it back into the queue and call super so it can handle it
                    shouldCallSuper = true
                    NSApp.postEvent(event, atStart: false)
                    stop.pointee = true
                
                case .leftMouseDragged:
                    // track mouse drags, and if more than a few points are moved we start a drag
                    let currentPoint = event.locationInWindow
                    if (abs(currentPoint.x - startingPoint.x) >= 5 || abs(currentPoint.y - startingPoint.y) >= 5) {
                        self.highlight(false)
                        stop.pointee = true
                        window.performDrag(with: event)
                    }
                
                default:
                    break
            }
        }
                
        if (shouldCallSuper) {
            super.mouseDown(with: mouseDownEvent)
        }
    }
    
}
