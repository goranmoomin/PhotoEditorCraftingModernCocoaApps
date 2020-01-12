/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The PhotoDocument subclasses NSDocument and does the basic data abstraction.
*/

import Cocoa

class PhotoDocument: NSDocument {

    /*
        This enumerated type is currently needed due to a Bridging problem that exists between the Swift 3 Error protocol and NSError.
        This will be fixed in a future update.
        For more information see: https://github.com/apple/swift-evolution/blob/master/proposals/0112-nserror-bridging.md
    */
    enum CocoaError : Error {
        case fileReadUnknown
    }
    
    var photo: Photo?
    
    override init() {
        super.init()
        hasUndoManager = true
    }
    
    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        addWindowController(windowController)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        guard let photoToArchive = photo else { throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil) }
        return try NSKeyedArchiver.archivedData(withRootObject: photoToArchive, requiringSecureCoding: true)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        switch typeName {
            case "JPEG image", "Portable Network Graphics image":

                guard let image = NSImage(data: data) else { throw CocoaError.fileReadUnknown }
                
                photo = Photo(title: displayName, image: image)
                fileType = "Photo Document"
                fileURL = nil
                
                // Mark that we did a change so we get a callback to autosave
                updateChangeCount(.changeDone)
                
            case "Photo Document":
                guard let unarchivedPhoto = ((try? NSKeyedUnarchiver.unarchivedObject(ofClass: Photo.self, from: data)) as Photo??) else { throw CocoaError.fileReadUnknown }
                photo = unarchivedPhoto
            
            default:
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
    }
}
