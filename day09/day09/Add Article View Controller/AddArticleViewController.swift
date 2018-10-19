//
//  AddArticleViewController.swift
//  day09
//
//  Created by Danil Vdovenko on 10/13/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit
import dvdovenk2018

class AddArticleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var articleTextField: UITextField!
    @IBOutlet weak var articleTextView: UITextView!
    @IBOutlet weak var articleImageView: UIImageView!
    
    let theImagePicker = UIImagePickerController()
    
    var article: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let theLanguage = Locale.preferredLanguages.first else {
            return
        }
        if theLanguage == "uk-US" {
            title = "Запис"
        } else if theLanguage == "ru-US" {
            title = "Запись"
        } else {
            title = "Article"
        }
        
        articleTextField.layer.borderColor = UIColor.darkGray.cgColor
        articleTextField.layer.borderWidth = 1.5
        articleTextField.layer.cornerRadius = 7.0
        articleTextView.layer.borderColor = UIColor.darkGray.cgColor
        articleTextView.layer.borderWidth = 1.5
        articleTextView.layer.cornerRadius = 7.0
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(addArticle))
        
        guard let theArticle = article else { return }
        articleTextField.text = theArticle.title
        guard let theContent = theArticle.content else { return }
        articleTextView.text = theContent
        guard let theImageData = theArticle.image else { return }
        articleImageView.image = UIImage(data: theImageData as Data)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            theImagePicker.delegate = self
            theImagePicker.sourceType = .camera;
            theImagePicker.allowsEditing = false
            self.present(theImagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            theImagePicker.delegate = self
            theImagePicker.sourceType = .savedPhotosAlbum;
            theImagePicker.allowsEditing = false
            self.present(theImagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func addArticle() {
        view.endEditing(true)
        guard let theTitle = articleTextField.text else {
            showAlertView(title: "Error", message: "Empty title")
            return
        }
        guard theTitle.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            showAlertView(title: "Error", message: "Empty title")
            return
        }
        let theContent = articleTextView.text
        guard theContent?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            showAlertView(title: "Error", message: "Empty content")
            return
        }
        guard let theImage = articleImageView.image else {
            showAlertView(title: "Error", message: "Empty image")
            return
        }
        guard let thePNGImage = UIImagePNGRepresentation(theImage) else {
            showAlertView(title: "Error", message: "Problem with image, sorry")
            return
        }
        if let theArticle = article {
            theArticle.content = theContent
            theArticle.title = theTitle
            theArticle.image = thePNGImage as NSData
            theArticle.modificationDate = NSDate()
            ArticleManagerController.shared.save()
        } else {
            let theArticle = ArticleManagerController.shared.newArticle()
            theArticle.title = theTitle
            theArticle.image = thePNGImage as NSData
            theArticle.content = theContent
            theArticle.language = Locale.preferredLanguages.first!
            theArticle.creationDate = NSDate()
            theArticle.modificationDate = NSDate()
            ArticleManagerController.shared.save()
        }
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let theImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            articleImageView.image = theImage
        }
        theImagePicker.dismiss(animated: true, completion: nil)
    }

}
