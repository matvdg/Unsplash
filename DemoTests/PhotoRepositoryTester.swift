//
//  PhotoRepositoryTester.swift
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

class PhotoRepositoryTester: XCTestCase {
    
    // MARK: Constants
    let disposableBag = DisposeBag()
    let scheduler = TestScheduler(initialClock: 0)
    let fakeError = NSError(domain: "fake error", code: 69, userInfo: nil)
    let photoCollection = PhotoCollection(id: 69, title: "Beautiful pics", description: "Ain't wonderful?", photos: [], numberOfPhotos: 30)
    let photo = try! JSONDecoder().decode(Photo.self, from: "{\"id\":\"nicePic\"}".data(using: .utf8)!)
    
    // MARK: Computed properties
    var photoCollections: [PhotoCollection] { Array(repeating: self.photoCollection, count: 10) }
    var photos: [Photo] { Array(repeating: photo, count: 7) }
    
    // MARK: Variables
    var mockPhotoDataSource: MockPhotoDataSource!
    var repository: PhotoRepository!
    var spyPhotoCollections: TestableObserver<[PhotoCollection]>!
    var spyPhotos: TestableObserver<[Photo]>!
    
    // MARK: - Constructor
    func testInit() {
        XCTAssertNotNil(self.repository)
    }
    
    // MARK: - getPhotoCollections
    func testGetPhotoCollections() {
        
        // Stub
        let _ = self.mockPhotoDataSource
            .when()
            .call(withReturnValue: self.mockPhotoDataSource.getPhotoCollections())
            .thenReturn(Single<[PhotoCollection]>.just(photoCollections))
        let _ = self.mockPhotoDataSource
            .when()
            .call(withReturnValue: self.mockPhotoDataSource.getPhotosUrls(collectionId: 69, page: 1))
            .thenReturn(Single<[Photo]>.just(photos))
        
        // Test
        self.repository.getPhotoCollections().asObservable().subscribe(self.spyPhotoCollections).disposed(by: self.disposableBag)
        
        // Assert
        let _ = self.mockPhotoDataSource!
            .verify(verificationMode: Once())
            .getPhotoCollections()
        
        let events = self.spyPhotoCollections.events
        XCTAssertEqual(events.count, 2) // because Single is subscribed as Observable
        XCTAssertNotNil(events.first!.value.element)
        let collections = events.first!.value.element!
        XCTAssertEqual(collections.count, 10)
        XCTAssertEqual(collections.first!.title, "Beautiful pics")
        XCTAssertEqual(collections.first!.description, "Ain't wonderful?")
        XCTAssertEqual(collections.first!.numberOfPhotos, 30)
        XCTAssertEqual(collections.first!.numberOfDisplayedPhotos, 7)
    }
    
    func testGetPhotoCollectionsWhenError() {
        
        // Stub
        let _ = self.mockPhotoDataSource
            .when()
            .call(withReturnValue: self.mockPhotoDataSource.getPhotoCollections())
            .thenReturn(Single<[PhotoCollection]>.error(self.fakeError))
        
        // Test
        self.repository.getPhotoCollections().asObservable().subscribe(self.spyPhotoCollections).disposed(by: self.disposableBag)
        
        // Assert
        let _ = self.mockPhotoDataSource!
            .verify(verificationMode: Once())
            .getPhotoCollections()
        let _ = self.mockPhotoDataSource!
        .verify(verificationMode: Never())
        .getPhotosUrls(collectionId: 69, page: 1)
        
        let events = self.spyPhotoCollections.events
        XCTAssertEqual(events.count, 1)
        let error = events.first!.value.error! as NSError
        XCTAssertEqual(error.code, 69)
    }
        
    // MARK: - getPhotoUrls
    func testGetPhotosUrls() {

        // Stub
        let _ = self.mockPhotoDataSource
            .when()
            .call(withReturnValue: self.mockPhotoDataSource.getPhotosUrls(collectionId: 69, page: 1))
            .thenReturn(Single<[Photo]>.just(photos))
        
        // Test
        self.repository.getPhotosUrls(for: photoCollection).asObservable().subscribe(self.spyPhotos).disposed(by: self.disposableBag)
        
        // Assert
        let _ = self.mockPhotoDataSource!
            .verify(verificationMode: Once())
            .getPhotosUrls(collectionId: 69, page: 1)
        
        let events = self.spyPhotos.events
        XCTAssertEqual(events.count, 2) // because Single is subscribed as Observable
        XCTAssertNotNil(events.first!.value.element)
        let photos = events.first!.value.element!
        XCTAssertEqual(photos.count, 7)
        XCTAssertEqual(photos.first!.id, "nicePic")
    }
    
    func testGetPhotosUrlsWhenError() {
        // Stub
        let _ = self.mockPhotoDataSource
            .when()
            .call(withReturnValue: self.mockPhotoDataSource.getPhotosUrls(collectionId: 69, page: 1))
            .thenReturn(Single<[Photo]>.error(self.fakeError))
        
        // Test
        self.repository.getPhotosUrls(for: photoCollection).asObservable().subscribe(self.spyPhotos).disposed(by: self.disposableBag)
        
        // Assert
        let _ = self.mockPhotoDataSource!
            .verify(verificationMode: Once())
            .getPhotosUrls(collectionId: 69, page: 1)
        
        let events = self.spyPhotos.events
        XCTAssertEqual(events.count, 1)
        let error = events.first!.value.error! as NSError
        XCTAssertEqual(error.code, 69)
    }
    
    // MARK: -  Lifecycle methods
    override func setUp() {
        self.mockPhotoDataSource = MockPhotoDataSource(testCase: self)
        self.spyPhotoCollections = self.scheduler.createObserver([PhotoCollection].self)
        self.spyPhotos = self.scheduler.createObserver([Photo].self)
        self.repository = PhotoRepository(photoDataSource: self.mockPhotoDataSource)
    }
    
    override func tearDown() {
        self.spyPhotoCollections = nil
        self.spyPhotos = nil
        self.mockPhotoDataSource = nil
        self.repository = nil
    }
}
