//
//  PhotoViewModelTester.swift
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

class PhotoViewModelTester: XCTestCase {
    
    // MARK: Constants
    let disposableBag = DisposeBag()
    let scheduler = TestScheduler(initialClock: 0)
    let fakeError = NSError(domain: "fake error", code: 69, userInfo: nil)
    let photoCollection = PhotoCollection(id: 69, title: "Beautiful pics", description: "Ain't wonderful?", photos: [], numberOfPhotos: 30)
    let photo = try! JSONDecoder().decode(Photo.self, from: "{\"id\":\"nicePic\"}".data(using: .utf8)!)
    
    // MARK: Computed properties
    var photoCollections: [PhotoCollection] { Array(repeating: self.photoCollection, count: 10) }
    var photos: [Photo]  { Array(repeating: photo, count: 7) }
    
    // MARK: Variables
    var viewModel: PhotoViewModel!
    var mockPhotoRepository: MockPhotoRepository!
    var spyEvents: TestableObserver<Demo.Event>!
    
    // MARK: - Constructor
    func testInit() {
        XCTAssertNotNil(self.viewModel)
    }
    

    // MARK: - loadPhotoCollections
    func testLoadPhotoCollections() {
        
        // Stub
        let _ = self.mockPhotoRepository
            .when()
            .call(withReturnValue: self.mockPhotoRepository.getPhotoCollections())
            .thenReturn(Single<[PhotoCollection]>.just(photoCollections))
        
        // Test
        self.viewModel.loadPhotoCollections()
        
        // Assert
        let _ = self.mockPhotoRepository!
            .verify(verificationMode: Once())
            .getPhotoCollections()
        
        let events = self.spyEvents.events
        XCTAssertEqual(events.count, 1)
        XCTAssertNotNil(events.first!.value.element)
        XCTAssertTrue(events.first!.value.element is EventPhotoCollections)
        let event = events.first!.value.element as! EventPhotoCollections
        XCTAssertEqual(event.photoCollections, self.photoCollections)
    }
    
    func testLoadPhotoCollectionsWhenError() {
        
        // Stub
        let _ = self.mockPhotoRepository
            .when()
            .call(withReturnValue: self.mockPhotoRepository.getPhotoCollections())
            .thenReturn(Single<[PhotoCollection]>.error(self.fakeError))
        
        // Test
        self.viewModel.loadPhotoCollections()
        
        // Assert
        let _ = self.mockPhotoRepository!
            .verify(verificationMode: Once())
            .getPhotoCollections()
        
        let events = self.spyEvents.events
        XCTAssertEqual(events.count, 1)
        XCTAssertNotNil(events.first!.value.element)
        XCTAssertTrue(events.first!.value.element is EventError)
    }
        
    // MARK: - addMoreDisplayedPhotos
    func testAddMoreDisplayedPhotos() {

        // Stub
        let _ = self.mockPhotoRepository
            .when()
            .call(withReturnValue: self.mockPhotoRepository.getPhotosUrls(for: self.photoCollection))
            .thenReturn(Single<[Photo]>.just(photos))
        
        // Test
        self.viewModel.addMoreDisplayedPhotos(collection: self.photoCollection)
        
        // Assert
        let _ = self.mockPhotoRepository!
            .verify(verificationMode: Once())
            .getPhotosUrls(for: self.photoCollection)
        
        let events = self.spyEvents.events
        XCTAssertEqual(events.count, 1)
        XCTAssertNotNil(events.first!.value.element)
        XCTAssertTrue(events.first!.value.element is EventPhotos)
        let event = events.first!.value.element as! EventPhotos
        XCTAssertEqual(event.photos.count, self.photos.count)
        XCTAssertEqual(event.collectionId, self.photoCollection.id)
    }
    
    func testAddMoreDisplayedPhotosWhenError() {
        // Stub
        let _ = self.mockPhotoRepository
            .when()
            .call(withReturnValue: self.mockPhotoRepository.getPhotosUrls(for: self.photoCollection))
            .thenReturn(Single<[Photo]>.error(self.fakeError))
        
        // Test
        self.viewModel.addMoreDisplayedPhotos(collection: self.photoCollection)
        
        // Assert
        let _ = self.mockPhotoRepository!
            .verify(verificationMode: Once())
            .getPhotosUrls(for: self.photoCollection)
        
        let events = self.spyEvents.events
        XCTAssertEqual(events.count, 0)
    }
    
    // MARK: -  Lifecycle methods
    override func setUp() {
        self.mockPhotoRepository = MockPhotoRepository(testCase: self)
        self.viewModel = PhotoViewModel(photoRepository: self.mockPhotoRepository)
        self.spyEvents = self.scheduler.createObserver(Demo.Event.self)
        self.viewModel.events.asObservable().skip(1).subscribe(self.spyEvents).disposed(by: self.disposableBag)
    }
    
    override func tearDown() {
        self.viewModel = nil
        self.mockPhotoRepository = nil
        self.spyEvents = nil
    }
}
