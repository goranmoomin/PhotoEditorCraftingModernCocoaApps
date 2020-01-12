/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Encapsulates the CoreImage filters that we expose through the Effects UI
 */

import Cocoa
import CoreImage

enum Effect {
    case blur
    case invert
    case monochrome
    
    var displayName: String {
        switch self {
            case .blur:
                return NSLocalizedString("Blur", comment: "Display name for the blur effect")
            
            case .invert:
                return NSLocalizedString("Invert Colors", comment: "Display name for the invert effect")
            
            case .monochrome:
                return NSLocalizedString("Black & White", comment: "Display name for the monochrome effect")
        }
    }
    
    private var filterName: String {
        switch self {
            case .blur:
                return "CIGaussianBlur"
            
            case .invert:
                return "CIColorInvert"
            
            case .monochrome:
                return "CIPhotoEffectMono"
        }
    }
    
    func createFilter() -> CIFilter {
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        return filter
    }
    
    static var allEffects: [Effect] = [.blur, .invert, .monochrome]
}
