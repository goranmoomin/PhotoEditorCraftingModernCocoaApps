/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The CanvasClipView subclasses NSClipView to demonstrate how to center the contents inside the clip view.
 */

import Cocoa

class CanvasClipView: NSClipView {
    
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        
        // Be polite and ask the superclass's opinion first.
        var constrainedBounds = super.constrainBoundsRect(proposedBounds)
        
        if let document = documentView {
            let documentFrame = document.frame
            
            // If either document dimension is too small, then offset the clip bounds to  
            if proposedBounds.width > documentFrame.width {
                constrainedBounds.origin.x = -(proposedBounds.width - documentFrame.width) / 2.0
                constrainedBounds.origin.x -= (contentInsets.left - contentInsets.right) / 2.0
            }
            
            if proposedBounds.height > documentFrame.height {
                constrainedBounds.origin.y = -(proposedBounds.height - documentFrame.height) / 2.0
                constrainedBounds.origin.y -= (contentInsets.top - contentInsets.bottom) / (isFlipped ? 2.0 : -2.0)
            }
        }
        
        return constrainedBounds
    }
    
}
