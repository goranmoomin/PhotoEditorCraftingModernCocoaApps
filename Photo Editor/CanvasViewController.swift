/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 CanvasViewController controls the actual canvas and glues changes from the canvas back to the model object by utilizing the photoController.
 */

import Cocoa

class CanvasViewController: NSViewController, PhotoControllerConsumer {

    @IBOutlet weak var scrollView: NSScrollView!

    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var canvasImageView: CanvasImageView!
    
    @IBOutlet weak var titleTextField: NSTextField!

    private var topTextFieldConstraint: NSLayoutConstraint?
    
    // PhotoSubscriber implementation
    var photoController: PhotoController? {
        didSet {
            if let old = oldValue { old.removeSubscriber(self) }
            if let new = photoController { new.addSubscriber(self) }
            if let photo = photoController?.photo {
                canvasImageView.image = photo.image
                titleTextField.stringValue = photo.title
            } else {
                canvasImageView.image = nil
                titleTextField.stringValue = ""
            }
        }
    }
    
    override func updateViewConstraints() {
        if topTextFieldConstraint == nil {
            // Keep the text field aligned underneath the title/toolbar area via the contentLayoutGuide
            // The titleTextField has a y constraint that is set to be removed at build time in order to not conflict with this constraint.
            if let contentAnchor = (titleTextField.window?.contentLayoutGuide as AnyObject).topAnchor {
                topTextFieldConstraint = titleTextField.topAnchor.constraint(equalTo: contentAnchor, constant: 2)
                topTextFieldConstraint?.isActive = true
            }
        }
        
        super.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasImageView.delegate = self
    }

    
    @IBAction func zoomIn(_ sender: AnyObject!) {
        let currentZoom = scrollView.magnification
        let increment: CGFloat
        if currentZoom < 1.0 {
            increment = 0.1
        } else if currentZoom < 2.0 {
            increment = 0.5
        } else {
            increment = 1.0
        }
        
        var nextZoom = ceil(currentZoom / increment) * increment
        if (abs(nextZoom - currentZoom) < 0.05) {
            nextZoom += increment
        }
        scrollView.animator().magnification = nextZoom
    }
    
    @IBAction func zoomOut(_ sender: AnyObject!) {
        let currentZoom = scrollView.magnification
        let increment: CGFloat
        if currentZoom < 1.0 {
            increment = 0.1
        } else if currentZoom < 2.0 {
            increment = 0.5
        } else {
            increment = 1.0
        }
        
        var nextZoom = floor(currentZoom / increment) * increment
        if (abs(nextZoom - currentZoom) < 0.05) {
            nextZoom -= increment
        }
        scrollView.animator().magnification = nextZoom
    }
    
    @IBAction func zoomImageToActualSize(_ sender: AnyObject!) {
        scrollView.animator().magnification = 1.0
    }
}

extension CanvasViewController: PhotoSubscriber {
    
    func photo(_ photo: Photo, didChangeImage image: NSImage?, from oldImage: NSImage?) {
        canvasImageView.image = image
    }
    
    func photo(_ photo: Photo, didChangeTitle title: String) {
        titleTextField.stringValue = photo.title
    }

}


extension CanvasViewController: CanvasImageViewDelegate {
    
    func canvasImageView(_ canvasImageView: CanvasImageView, didChangeImage image: NSImage?) {
        photoController?.setPhotoImage(image)
    }
    
    func getEditMode(in canvasImageView: CanvasImageView) -> CanvasImageView.EditMode {
        // Translate the WindowController's edit mode to the CanvasImageView's edit mode. This ties the controllers together, but it is much better than having the view access the property
        guard let windowController = view.window?.windowController as? PhotoDocumentWindowController else { return .move }

        switch windowController.editMode {
            case .move, .effects:
                // Effects still allows moving the image
                return .move
            case .draw:
                return .draw
        }
    }

}

