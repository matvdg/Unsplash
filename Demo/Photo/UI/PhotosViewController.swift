//
//  PhotosViewController.swift
//  Demo
//
//  Created by Mathieu Vandeginste on 05/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import UIKit
import Dip
import RxSwift
import AlamofireImage
import UnsplasherSDK

class PhotosViewController: UIViewController {

    // MARK: @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Private properties
    private var photoCollections = [PhotoCollection]()
    private var refreshControl = UIRefreshControl()
    
    // MARK: Public properties
    var viewModel: PhotoViewModelProtocol?
    
    // MARK: Static methods
    internal static func instantiate() -> PhotosViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! PhotosViewController
    }
    
    // for unit testing purpose
    internal static func instantiate(vm: PhotoViewModelProtocol) -> PhotosViewController {
        let vc = PhotosViewController.instantiate()
        vc.viewModel = vm
        return vc
    }
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.initObservers()
        self.viewModel?.loadPhotoCollections()
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
                case let event as EventPhotoCollections:
                    self.displayPhotoCollections(event.photoCollections)
                case let event as EventPhotos:
                    self.displayMorePhotos(event.photos, for: event.collectionId)
                case is EventError:
                    self.displayError()
                default:
                    return
                }
            }
        }
    }
    
    // MARK: Private methods
    private func initUI() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.tableView.register(UINib(nibName: "PhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "PhotoTableViewCell")
        self.refreshControl.attributedTitle = NSAttributedString(string: "PULL_TO_REFRESH".localized)
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
    }
    
    private func displayPhotoCollections(_ photoCollections: [PhotoCollection]) {
        self.refreshControl.endRefreshing()
        self.photoCollections = photoCollections
        self.tableView.reloadData()
    }
    
    private func displayMorePhotos(_ photos: [Photo], for collectionId: UInt32) {
        let index = self.photoCollections.firstIndex { $0.id == collectionId }
        guard let row = index, let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? PhotoTableViewCell else { return }
        self.photoCollections[row].photos.append(contentsOf: photos)
        cell.collectionView.reloadData()
        cell.paginationLabel.text = "\(self.photoCollections[row].numberOfDisplayedPhotos)/\(self.photoCollections[row].numberOfPhotos)"
    }
    
    private func displayError() {
        self.refreshControl.endRefreshing()
        let alert = UIAlertController(title: "ERROR_TITLE".localized, message: "ERROR_MSG".localized, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "RETRY".localized, style: .default, handler: { action in
            self.refresh()
        })
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }
    
    @objc private func refresh() {
        self.viewModel?.loadPhotoCollections()
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource delegates
extension PhotosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photoCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
        let collection = self.photoCollections[indexPath.row]
        cell.photoCollectionTitleLabel.text = collection.title + " ＞" // fake disclosure indicator to encourage the user to tap to see the collectionView in fullScreen (PhotoCollectionViewController)
        cell.photoCollectionDescriptionLabel.text = collection.description
        cell.paginationLabel.text = "\(collection.numberOfDisplayedPhotos)/\(collection.numberOfPhotos)"
        cell.collectionView?.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        cell.collectionView?.tag = indexPath.row
        cell.collectionView?.delegate = self
        cell.collectionView?.dataSource = self
        cell.collectionView?.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collection = self.photoCollections[indexPath.row]
        self.navigationController?.pushViewController(PhotoCollectionViewController.instantiate(photoCollection: collection), animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout & UITableViewDataSource delegates
extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let collection =  self.photoCollections[collectionView.tag]
        if collection.numberOfDisplayedPhotos < collection.numberOfPhotos {
            return collection.numberOfDisplayedPhotos + 1 // Load more item
        } else {
            return collection.numberOfDisplayedPhotos
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = #imageLiteral(resourceName: "placeholder")
        let collection =  self.photoCollections[collectionView.tag]
        if collection.numberOfDisplayedPhotos == collection.numberOfPhotos { // No load more button
            if let url = self.photoCollections[collectionView.tag].photos[indexPath.row].urls?.thumb {
                cell.imageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            }
        } else { // Load more button needed
            if indexPath.row == collection.numberOfDisplayedPhotos {
                cell.imageView.image = #imageLiteral(resourceName: "loadMore")
            } else {
                if let url = self.photoCollections[collectionView.tag].photos[indexPath.row].urls?.thumb {
                    cell.imageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGFloat = 150
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collection = self.photoCollections[collectionView.tag]
        if collection.numberOfDisplayedPhotos == collection.numberOfPhotos { // No more button
            self.navigationController?.pushViewController(PhotoViewController.instantiate(photo: collection.photos[indexPath.row]), animated: true)
        } else { // Load more button needed
            if indexPath.row == collection.numberOfDisplayedPhotos { // Load more button
                self.viewModel?.addMoreDisplayedPhotos(collection: collection)
            } else { // No more button
                self.navigationController?.pushViewController(PhotoViewController.instantiate(photo: collection.photos[indexPath.row]), animated: true)
            }
        }
    }
    
}

// MARK: - StoryboardInstantiatable
extension PhotosViewController: StoryboardInstantiatable {}
