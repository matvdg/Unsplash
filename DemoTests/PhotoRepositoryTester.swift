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

class PhotoRepositoryTester: XCTestCase {
    
    let disposableBag = DisposeBag()
    let scheduler = TestScheduler(initialClock: 0)
    let fakeError = NSError(domain: "fake error", code: 69, userInfo: nil)
    
    // MARK: Variables
    var mockPhotoDataSource: MockPhotoDataSource!
    var repository: PhotoRepository!
    
    var spyCompletable: TestableObserver<Swift.Never>!
    var spyPhotoCollections: TestableObserver<[PhotoCollection]>!
    
    // MARK: - Constructor
    func testInit() {
        XCTAssertNotNil(self.repository)
    }
    
    // MARK: - getOdometer
    func testGetPhotoCollections() {
        
        // Prepare and stub
        let photoCollection: PhotoCollection = (title: "Collection", size: 7, id: 787)
        let photoCollections = Array(repeating: photoCollection, count: 10)
        let _ = self.mockPhotoDataSource
            .when()
            .call(withReturnValue: self.mockPhotoDataSource.getPhotoCollections())
            .thenReturn(Single<[PhotoCollection]>.just(photoCollections))
        
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
        XCTAssertEqual(collections.first!.title, "Collection")
    }
    
    func testGetPhotoCollectionsWhenError() {
        
        // Prepare and stub
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
        
        let events = self.spyPhotoCollections.events
        XCTAssertEqual(events.count, 1)
        let error = events.first!.value.error! as NSError
        XCTAssertEqual(error.code, 69)
    }
        
    // MARK: -  Lifecycle methods
    override func setUp() {
        self.mockPhotoDataSource = MockPhotoDataSource(testCase: self)
        self.spyCompletable = self.scheduler.createObserver(Swift.Never.self)
        self.spyPhotoCollections = self.scheduler.createObserver([PhotoCollection].self)
        self.repository = PhotoRepository(photoDataSource: self.mockPhotoDataSource)
    }
    
    override func tearDown() {
        self.spyPhotoCollections = nil
        self.spyCompletable = nil
        self.mockPhotoDataSource = nil
        self.repository = nil
    }
}
