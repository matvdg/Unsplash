//
//  PhotoCollection.swift
//  Demo
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import Foundation
import UnsplasherSDK

struct PhotoCollection: Equatable {
    
    static func == (lhs: PhotoCollection, rhs: PhotoCollection) -> Bool { lhs.id == rhs.id }
    
    var id: UInt32
    var title: String
    var description: String?
    var photos: [Photo]
    var numberOfPhotos: Int
    var numberOfDisplayedPhotos: Int {
        return self.photos.count
    }
    
    mutating func addPhotos(_ photos: [Photo]) {
        self.photos = photos
    }
}
    

