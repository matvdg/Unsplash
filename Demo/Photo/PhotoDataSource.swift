//
//  PhotoDataSource.swift
//  Unsplash
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import Foundation
import UnsplasherSDK
import RxSwift

// Avoid too many collections because free API is limited to 50 requests per hour (we do have a load more button in each collectionView for each collection as requested, but I didn't add a load more button in the tableView on purpose to limit this)
let numberOfCollections = 10
let numberOfPhotosPerCollection = 10

protocol PhotoDataSourceProtocol {
    func getPhotoCollections() -> Single<[PhotoCollection]>
    func getPhotosUrls(collectionId: UInt32, page: Int) -> Single<[Photo]>
}

class PhotoDataSource: PhotoDataSourceProtocol {
    
    private let collectionsClient = Unsplash.shared.collections
    
    func getPhotoCollections() -> Single<[PhotoCollection]> {
        return Single.create { observer in
            self.collectionsClient?.collections(list: .featured, page: 1, perPage: numberOfCollections, completion: { result in
                switch result {
                case .success(let collections):
                    let result: [PhotoCollection] = collections.map {
                        let numberOfPhotos = Int($0.totalPhotos ?? 0)
                        return PhotoCollection(id: $0.id, title: $0.title, description: $0.description, photos: [], numberOfPhotos: numberOfPhotos)
                    }
                    observer(.success(result))
                case .failure(let error):
                    observer(.error(error))
                }
            })
            return Disposables.create()
        }
    }
    
    func getPhotosUrls(collectionId: UInt32, page: Int) -> Single<[Photo]> {
        return Single.create { observer in
            self.collectionsClient?.photos(in: collectionId, page: page, perPage: numberOfPhotosPerCollection, completion: { result in
                switch result {
                case .success(let photos):
                    observer(.success(photos))
                case .failure(let error):
                    observer(.error(error))
                }
            })
            return Disposables.create()
        }
    }
}
