//
//  MockPhotoViewModel.swift
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

class MockPhotoViewModel: RxViewModel, PhotoViewModelProtocol, Mock {
    
    let callHandler: CallHandler
    
    init(testCase: XCTestCase) {
        self.callHandler = CallHandlerImpl(withTestCase: testCase)
    }
    
    func instanceType() -> MockPhotoViewModel {
        return self
    }
    
    func loadPhotoCollections() {
        let _ = self.callHandler.accept(nil, ofFunction: #function, atFile: #file, inLine: #line, withArgs: nil)
    }
    
    func addMoreDisplayedPhotos(collection: PhotoCollection) {
        let _ = self.callHandler.accept(nil, ofFunction: #function, atFile: #file, inLine: #line, withArgs: collection)
    }
    
    
}
