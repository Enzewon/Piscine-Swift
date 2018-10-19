//
//  DetailedViewController.swift
//  day03
//
//  Created by Danil Vdovenko on 10/5/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class DetailedViewController: UIViewController {

    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let theUnwrappedImage = self.image else { return }
        self.imageView.image = theUnwrappedImage
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateMinZoomScaleForSize(size)
    }

    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        var minScale = size.width / (imageView.image?.size.width)!
        scrollView.setZoomScale(1.0, animated: true)
        if minScale > 1.0 {
            minScale = 1.0
        }
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
}

extension DetailedViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

