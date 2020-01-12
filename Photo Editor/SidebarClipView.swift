/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The SidebarClipView allows a view under the contentInsets to still be clicked on.
 */

import Cocoa

class SidebarClipView: NSClipView {

    weak var accessoryView: NSView?
    
    // NSClipView's hitTest normally is limited to views within the contentInset area. We want to allow the search field (or whatever accessory view) to still be interacted with, and explicitly check for it.
    override func hitTest(_ point: NSPoint) -> NSView? {
        if let accessoryView = accessoryView {
            let localPoint = convert(point, from: superview)
            if accessoryView.frame.contains(localPoint) {
                return accessoryView.hitTest(localPoint)
            }
        }
        
        return super.hitTest(point)
    }
    
}
