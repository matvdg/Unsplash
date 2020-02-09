//
//  PhotoViewController.swift
//  Demo
//
//  Created by Mathieu Vandeginste on 07/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import UIKit
import UnsplasherSDK

class PhotoViewController: UIViewController {
    
    // MARK: Public property
    var photo: Photo?

    // MARK: Private property
    private var imageScrollView: UIScrollImageView!
    
    // MARK: Static methods
    internal static func instantiate(photo: Photo) -> PhotoViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoViewController") as! PhotoViewController
        vc.photo = photo
        return vc
    }
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        guard let url = self.photo?.urls?.full else { return }
        self.imageScrollView = UIScrollImageView(frame: self.view.frame, image: #imageLiteral(resourceName: "placeholder"))
        self.imageScrollView.showsVerticalScrollIndicator = false
        self.imageScrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.imageScrollView)
        self.imageScrollView.imageView.af_setImage(withURL: url)
        self.title = self.photo?.description
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePhoto))
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.imageScrollView.reset(size: size)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            self.navigationController?.isNavigationBarHidden = true
        } else {
            print("Portrait")
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    // MARK: Private methods
    @objc private func savePhoto() {
        guard let image = self.imageScrollView.imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "ERROR_TITLE".localized, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "IMG_SAVED_TITLE".localized, message: "IMG_SAVED_MSG".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
}
