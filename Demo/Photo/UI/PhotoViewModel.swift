//
//  PhotoCollectionsViewModel.swift
//  Unsplash
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import Foundation
import RxSwift
import UnsplasherSDK

// MARK: Custom events

class EventError: Event {}

class EventPhotoCollections: Event {
    var photoCollections: [PhotoCollection]
    
    init(_ photoCollections: [PhotoCollection]) {
        self.photoCollections = photoCollections
    }
}

class EventPhotos: Event {
    var photos: [Photo]
    var collectionId: UInt32
    
    init(_ photos: [Photo], collectionId: UInt32) {
        self.photos = photos
        self.collectionId = collectionId
    }
}

// MARK: -
protocol PhotoViewModelProtocol: RxViewModelProtocol {
    
    func loadPhotoCollections()
    func addMoreDisplayedPhotos(collection: PhotoCollection)
}

// MARK: -
class PhotoViewModel: RxViewModel, PhotoViewModelProtocol {
    
    private let photoRepository: PhotoRepositoryProtocol!
    
    // MARK: Constructors
    required init(photoRepository: PhotoRepositoryProtocol) {
        self.photoRepository = photoRepository
    }
    
    // MARK: Public methods
    func loadPhotoCollections() {
        self.launch {
            self.photoRepository.getPhotoCollections().subscribe(onSuccess: { photoCollections in
                self.events.accept(EventPhotoCollections(photoCollections))
            }) { error in
                print(error.localizedDescription)
                self.events.accept(EventError())
            }
        }
    }
    
    func addMoreDisplayedPhotos(collection: PhotoCollection) {
        self.launch {
            self.photoRepository.getPhotosUrls(for: collection).subscribe(onSuccess: { photos in
                self.events.accept(EventPhotos(photos, collectionId: collection.id))
            })
        }
    }
}
