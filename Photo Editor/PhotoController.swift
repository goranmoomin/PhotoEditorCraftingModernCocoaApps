/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The PhotoController manages the Photo object. All changes are pushed through the controller, allowing one or more subscribers to be alerted to changes.
*/


import Cocoa

class PhotoController: NSObject {
    
    private let subscribers = NSHashTable<AnyObject>.weakObjects()
    
    private(set) var photo: Photo
    
    init(photo: Photo) {
        self.photo = photo
    }
    
    // MARK: - Subscription
    
    func addSubscriber(_ subscriber: PhotoSubscriber) {
        subscribers.add(subscriber)
    }
    
    func removeSubscriber(_ subscriber: PhotoSubscriber) {
        subscribers.remove(subscriber)
    }
    
    private func forEachSubscriber(_ work: (PhotoSubscriber) -> Void) {
        for object in subscribers.objectEnumerator() {
            guard let subscriber = object as? PhotoSubscriber else { continue }
            work(subscriber)
        }
    }
    
    // MARK: - Actions
    
    func setPhotoImage(_ photoImage: NSImage?) {
        let oldImage = photo.image
        photo.image = photoImage
        forEachSubscriber { $0.photo(photo, didChangeImage: photo.image, from: oldImage) }
    }
    
    func setPhotoTitle(_ title: String) {
        photo.title = title
        forEachSubscriber { $0.photo(photo, didChangeTitle: title) }
    }   
    
}

protocol PhotoSubscriber: class {
    func photo(_ photo: Photo, didChangeImage image: NSImage?, from oldImage: NSImage?)
    func photo(_ photo: Photo, didChangeTitle title: String)
}

// Optionally provide a default empty implementation to make it "optional". Having it not be optional enforces you to implement the protocol, which can be desired in some cases.
/*
 extension PhotoSubscriber {
 func photo(_ photo: Photo, didChangeImage image: NSImage?, from oldImage: NSImage?) {
 }
 
 func photo(_ photo: Photo, didChangeTitle title: String) {
 }
 }
 */

// Any given view controller can implement the PhotoControllerConsumer to get assigned the current PhotoController
protocol PhotoControllerConsumer {
    var photoController: PhotoController? { get set }
}
