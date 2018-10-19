//
//  ViewController.swift
//  day03
//
//  Created by Danil Vdovenko on 10/5/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

private let reuseIdentifier = "imageCell"

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var counter: Int = 0 {
        didSet {
            if oldValue == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
        willSet {
            if newValue == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    let urls = ["https://www.nasa.gov/sites/default/files/styles/full_width_feature/public/thumbnails/image/dunes_on_pluto_image.jpg", "https://www.nasa.gov/sites/default/files/styles/full_width_feature/public/thumbnails/image/pia22684.jpg", "https://www.nasa.gov/sites/default/files/styles/full_width_feature/public/thumbnails/image/colorized_wright_mons_cropped.png", "https://www.nasa.gov/sites/default/files/styles/full_width_feature/public/thumbnails/image/pia22587.jpg"]
    var imageSave: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.urls.count
    }
    
    func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width - 22
        return CGSize(width: (width / 2) - 8, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let theCell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else { return }
        self.imageSave = theCell.imageView.image
        guard let _ = self.imageSave else {
            self.showAlert(withMessage: "There is no picture!")
            return
        }
        performSegue(withIdentifier: "goToMaxImage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DetailedViewController {
            guard let destVC = segue.destination as? DetailedViewController else { return }
            destVC.image = self.imageSave
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        let theURL = URL(string: self.urls[indexPath.row])!
        
        cell.backgroundColor = UIColor.black
        cell.activityIndicator.color = UIColor.white
        cell.activityIndicator.startAnimating()
        self.counter += 1
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: theURL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.alpha = 0
                        self?.counter -= 1
                    }
                } else {
                    self?.showAlert(withMessage: "Cannot load \(theURL.absoluteString)")
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.alpha = 0
                    self?.counter -= 1
                }
            } else {
                self?.showAlert(withMessage: "Cannot load \(theURL.absoluteString)")
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.alpha = 0
                self?.counter -= 1
            }
        }
        
        return cell
    }
}

