/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The ImageSizeViewController has two text fields to set the image width and height. The text fields are bound in IB to the dynamic properties of the same name.
 */

import Cocoa

class ImageSizeViewController: NSViewController {
    
    @IBOutlet weak var widthField: NSTextField!
    @IBOutlet weak var heightField: NSTextField!
    @IBOutlet weak var constrainCheckbox: NSButton!
    
    @objc dynamic var width: CGFloat = 0 // for bindings
    @objc dynamic var height: CGFloat = 0  // for bindings
    
    var completionHandler: ((NSSize, NSApplication.ModalResponse) -> Void)?
    
    private var ratio: CGFloat = 1
    
    var imageSize: NSSize {
        get {
            return NSSize(width: width, height: height)
        }
        set {
            (width, height) = (newValue.width, newValue.height)
            ratio = (height > 0) ? width / height : 1.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didEditField(_ sender: NSTextField!) {
        guard constrainCheckbox.state == .on else { return }

        switch sender {
            case widthField:
                height = width / ratio
            
            case heightField:
                width = height * ratio
            
            default:
                break
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject!) {
        dismiss(sender)
        completionHandler?(NSZeroSize, NSApplication.ModalResponse.cancel)
    }
    
    @IBAction func ok(_ sender: AnyObject!) {
        dismiss(sender)
        completionHandler?(imageSize, NSApplication.ModalResponse.OK)
    }
    
}
