//
//  MockPhotoDataSource.swift
//  DemoTests
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

@testable import Demo
import Foundation
import XCTest
import Mockit
import RxSwift
import UnsplasherSDK

class MockPhotoDataSource: PhotoDataSourceProtocol, Mock {
    
    let callHandler: CallHandler
    
    init(testCase: XCTestCase) {
        self.callHandler = CallHandlerImpl(withTestCase: testCase)
    }
    
    func instanceType() -> MockPhotoDataSource {
        return self
    }
    
    func getPhotoCollections() -> Single<[PhotoCollection]> {
        return self.callHandler.accept(Single<[PhotoCollection]>.never(), ofFunction: #function, atFile: #file, inLine: #line, withArgs: nil) as! Single<[PhotoCollection]>
    }
    
    func getPhotosUrls(collectionId: UInt32, page: Int) -> Single<[Photo]> {
        return self.callHandler.accept(Single<[Photo]>.never(), ofFunction: #function, atFile: #file, inLine: #line, withArgs: nil) as! Single<[Photo]>
    }
    
}
