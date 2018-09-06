//
//  ImageCache.swift
//  Example
//
//  Created by Qiscus on 06/09/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation
import UIKit

class ImageCache  {
    static var shared : ImageCache = ImageCache()
    
    let cache = NSCache<NSString, UIImage>()
    
    
}


