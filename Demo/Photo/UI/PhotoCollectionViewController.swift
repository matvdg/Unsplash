//
//  PhotoCollectionViewController.swift
//  Demo
//
//  Created by Mathieu Vandeginste on 09/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import UIKit
import RxSwift
import AlamofireImage
import Dip
import UnsplasherSDK

class PhotoCollectionViewController: UIViewController {
    
    // MARK: @IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Private property
    private var imageScrollView: UIScrollImageView!
    
    // MARK: Public properties
    var photoCollection: PhotoCollection!
    var viewModel: PhotoViewModelProtocol?
    
    // MARK: Static methods
    internal static func instantiate(photoCollection: PhotoCollection) -> PhotoCollectionViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoCollectionViewController") as! PhotoCollectionViewController
        vc.photoCollection = photoCollection
        return vc
    }
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        self.initUI()
        self.initObservers()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // MARK: - MVVM method
    private func initObservers() {
        self.launch {
            self.viewModel?.events.asObservable().observeOn(MainScheduler.instance).subscribe { rx in
                guard let event = rx.element else { return }
                switch event {
                case let event as EventPhotos:
                    self.displayMorePhotos(event.photos, for: event.collectionId)
                default:
                    return
                }
            }
        }
    }
    
    // MARK: Private methods
    private func initUI() {
        self.collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        self.title = self.photoCollection?.title
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let size: CGFloat = self.view.frame.width / 4
        layout.itemSize = CGSize(width: size, height: size)
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        self.collectionView.setCollectionViewLayout(layout, animated: true)
        self.collectionView.reloadData()
    }
    
    private func displayMorePhotos(_ photos: [Photo], for collectionId: UInt32) {
        self.photoCollection.photos.append(contentsOf: photos)
        self.collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout & UITableViewDataSource delegates
extension PhotoCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.photoCollection.numberOfDisplayedPhotos < self.photoCollection.numberOfPhotos {
            return self.photoCollection.numberOfDisplayedPhotos + 1 // Load more item
        } else {
            return self.photoCollection.numberOfDisplayedPhotos
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = #imageLiteral(resourceName: "placeholder")
        if self.photoCollection.numberOfDisplayedPhotos == self.photoCollection.numberOfPhotos { // No load more button
            if let url = self.photoCollection.photos[indexPath.row].urls?.thumb {
                cell.imageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            }
        } else { // Load more button needed
            if indexPath.row == self.photoCollection.numberOfDisplayedPhotos {
                cell.imageView.image = #imageLiteral(resourceName: "loadMore")
            } else {
                if let url = self.photoCollection.photos[indexPath.row].urls?.thumb {
                    cell.imageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.photoCollection.numberOfDisplayedPhotos == self.photoCollection.numberOfPhotos { // No more button
            self.navigationController?.pushViewController(PhotoViewController.instantiate(photo: self.photoCollection.photos[indexPath.row]), animated: true)
        } else { // Load more button needed
            if indexPath.row == self.photoCollection.numberOfDisplayedPhotos { // Load more button
                self.viewModel?.addMoreDisplayedPhotos(collection: self.photoCollection)
            } else { // No more button
                self.navigationController?.pushViewController(PhotoViewController.instantiate(photo: self.photoCollection.photos[indexPath.row]), animated: true)
            }
        }
    }
}

// MARK: - StoryboardInstantiatable
extension PhotoCollectionViewController: StoryboardInstantiatable {}
