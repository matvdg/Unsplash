//
//  PhotosViewControllerTester.swift
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

class PhotosViewControllerTester: XCTestCase {
    
    // MARK: Variables
    var vc: PhotosViewController!
    var mockViewModel: MockPhotoViewModel!
    
    // MARK: Constants
    let photo = try! JSONDecoder().decode(Photo.self, from: "{\"id\":\"nicePic\"}".data(using: .utf8)!)
    
    // MARK: Computed properties
    var photos: [Photo]  { Array(repeating: photo, count: 7) }
    var photoCollection: PhotoCollection { PhotoCollection(id: 69, title: "Beautiful pics", description: "Ain't wonderful?", photos: self.photos, numberOfPhotos: 30) }
    var photoCollections: [PhotoCollection] { Array(repeating: self.photoCollection, count: 10) }
    
    // MARK: - Constructor
    func testInit() {
        XCTAssertNotNil(self.vc)
    }
    
    // MARK: - Screen loading
    func testViewDidLoad() {
        XCTAssertEqual(self.vc.navigationItem.title, "Featured")
        let _ = self.mockViewModel.verify(verificationMode: Once()).loadPhotoCollections()
    }
    
    func testDisplayPhotoCollections() {
        
        // Test
        self.mockViewModel.events.accept(EventPhotoCollections(self.photoCollections))
        
        // Assert
        XCTAssertEqual(self.vc.tableView.numberOfRows(inSection: 0), 10)
        let firstCell = self.vc.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PhotoTableViewCell
        XCTAssertEqual(firstCell.photoCollectionTitleLabel.text, "Beautiful pics ＞")
        XCTAssertEqual(firstCell.photoCollectionDescriptionLabel.text, "Ain't wonderful?")
        XCTAssertEqual(firstCell.paginationLabel.text, "7/30")
        XCTAssertEqual(firstCell.collectionView.numberOfItems(inSection: 0), 8) // 7 + loadMore item
    }
    
    func testDisplayMorePhotos() {
        // Prepare
        self.mockViewModel.events.accept(EventPhotoCollections(self.photoCollections))
        
        // Test
        self.mockViewModel.events.accept(EventPhotos(photos, collectionId: 69))
        
        // Assert
        XCTAssertEqual(self.vc.tableView.numberOfRows(inSection: 0), 10)
        let firstCell = self.vc.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PhotoTableViewCell
        XCTAssertEqual(firstCell.photoCollectionTitleLabel.text, "Beautiful pics ＞")
        XCTAssertEqual(firstCell.photoCollectionDescriptionLabel.text, "Ain't wonderful?")
        XCTAssertEqual(firstCell.paginationLabel.text, "14/30")
        XCTAssertEqual(firstCell.collectionView.numberOfItems(inSection: 0), 15) // 7 + 7 added + loadMore item
    }
    
    // MARK: -
    override func setUp() {
        super.setUp()
        self.mockViewModel = MockPhotoViewModel(testCase: self)
        self.vc = PhotosViewController.instantiate(vm: self.mockViewModel)
        self.vc.loadView()
        self.vc.viewDidLoad()
    }
    
    override func tearDown() {
        super.tearDown()
        self.vc = nil
        self.mockViewModel = nil
    }
}
