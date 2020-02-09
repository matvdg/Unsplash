//
//  PhotoRepository.swift
//  Demo
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import Foundation
import RxSwift
import UnsplasherSDK

protocol PhotoRepositoryProtocol {
    func getPhotoCollections() -> Single<[PhotoCollection]>
    func getPhotosUrls(for collection: PhotoCollection) -> Single<[Photo]>
}

class PhotoRepository: RxRepository, PhotoRepositoryProtocol {
    
    // MARK: Private constants
    private let photoDataSource: PhotoDataSourceProtocol
    
    // MARK: Constructor
    init(photoDataSource: PhotoDataSourceProtocol) {
        self.photoDataSource = photoDataSource
    }
    
    // MARK: Public methods
    func getPhotoCollections() -> Single<[PhotoCollection]> {
        return self.photoDataSource.getPhotoCollections().flatMap { collections -> Single<[PhotoCollection]> in
            Single.zip(
                collections.map({ collection -> Single<PhotoCollection> in
                self.photoDataSource
                    .getPhotosUrls(collectionId: collection.id, page: 1)
                    .map { photos -> PhotoCollection in
                        var collection = collection
                        collection.photos = photos
                        return collection
                }
            }))
        }
    }
    
    func getPhotosUrls(for collection: PhotoCollection) -> Single<[Photo]> {
        let page = collection.numberOfDisplayedPhotos / numberOfPhotosPerCollection + 1
        return self.photoDataSource.getPhotosUrls(collectionId: collection.id, page: page)
    }
    
}
