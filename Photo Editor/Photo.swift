/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A basic model class representation that contains the actual image data and some meta data about the image.
*/

import Cocoa

class Photo : NSObject, NSCoding {
    
    var title = ""
    var image: NSImage?

    /// Initialize a Photo object with no title and no image
    override init() {
    }
    
    /// Initialize a Photo object with a particular title and image
    init(title: String, image: NSImage) {
        self.title = title
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        precondition(coder.allowsKeyedCoding, "Non-keyed coding is not supported")
        
        if let title = coder.decodeObject(forKey: "PhotoTitle") as? String {
            self.title = title
        }
        
        self.image = coder.decodeObject(forKey: "PhotoImage") as? NSImage
    }
    
    func encode(with coder: NSCoder) {
        precondition(coder.allowsKeyedCoding, "Non-keyed coding is not supported")
        
        coder.encode(title, forKey: "PhotoTitle")
        coder.encode(image, forKey: "PhotoImage")
    }
}
