//
//  PhotoCollectionViewControllerTester.swift
//  DemoTests
//
//  Created by Mathieu Vandeginste on 06/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

@testable import Demo
import Foundation
import XCTest
import RxSwift
import RxTest
import Mockit
import UnsplasherSDK

class PhotoCollectionViewControllerTester: XCTestCase {
    
    // MARK: Variables
    var vc: PhotoCollectionViewController!
    var mockViewModel: MockPhotoViewModel!
    
    // MARK: Constants
    let photo = try! JSONDecoder().decode(Photo.self, from: "{\"id\":\"nicePic\"}".data(using: .utf8)!)
    
    // MARK: Computed properties
    var photos: [Photo]  { Array(repeating: photo, count: 7) }
    var photoCollection: PhotoCollection { PhotoCollection(id: 69, title: "Beautiful pics", description: "Ain't wonderful?", photos: self.photos, numberOfPhotos: 30) }
    
    // MARK: - Constructor
    func testInit() {
        XCTAssertNotNil(self.vc)
    }
    
    // MARK: - Screen loading
    func testViewDidLoad() {
        XCTAssertEqual(self.vc.navigationItem.title, self.photoCollection.title)
    }
    
    func testDisplayMorePhotos() {
        // Test
        self.mockViewModel.events.accept(EventPhotos(photos, collectionId: 69))
        
        // Assert
        XCTAssertEqual(self.vc.collectionView.numberOfItems(inSection: 0), 15) // 7 + 7 added + 1 for loadMore button
    }
    
    // MARK: -
    override func setUp() {
        super.setUp()
        self.mockViewModel = MockPhotoViewModel(testCase: self)
        self.vc = PhotoCollectionViewController.instantiate(photoCollection: self.photoCollection, vm: self.mockViewModel)
        self.vc.loadView()
        self.vc.viewDidLoad()
    }
    
    override func tearDown() {
        super.tearDown()
        self.vc = nil
        self.mockViewModel = nil
    }
}
