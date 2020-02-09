//
//  UIZoomView.swift
//  Unsplash
//
//  Created by Mathieu Vandeginste on 08/02/2020.
//  Copyright © 2020 matapps. All rights reserved.
//

import UIKit

class UIScrollImageView: UIScrollView, UIScrollViewDelegate {

    var imageView: UIImageView!
    var gestureRecognizer: UITapGestureRecognizer!

    convenience init(frame: CGRect, image: UIImage) {
        self.init(frame: frame)
        self.imageView = UIImageView(image: image)
        self.imageView.frame = frame
        self.imageView.contentMode = .scaleAspectFit
        self.contentSize = frame.size
        self.addSubview(self.imageView)
        self.delegate = self
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 3.0
        self.gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        self.gestureRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(self.gestureRecognizer)
    }
    
    func reset(size: CGSize) {
        self.setZoomScale(1, animated: false)
        let newFrame = CGRect(origin: CGPoint.zero, size: size)
        self.frame = newFrame
        self.imageView.frame = newFrame
        self.contentSize = size
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @objc func didDoubleTap() {
        if self.zoomScale == 1 {
            self.zoom(to: self.zoomRectForScale(self.maximumZoomScale, center: self.gestureRecognizer.location(in: self.gestureRecognizer.view)), animated: true)
        } else {
            self.setZoomScale(1, animated: true)
        }
    }
    
    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = self.imageView.frame.size.height / scale
        zoomRect.size.width = self.imageView.frame.size.width / scale
        let newCenter = self.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
}
