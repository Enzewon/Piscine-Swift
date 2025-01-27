//
//  ViewController.swift
//  dvdovenk2018
//
//  Created by Enzewon on 10/12/2018.
//  Copyright (c) 2018 Enzewon. All rights reserved.
//

import UIKit
import dvdovenk2018

class ViewController: UIViewController {
    
    let theArticleManager = ArticleManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theFirstArticle = theArticleManager.newArticle()
        theFirstArticle.title = "Article 1"
        theFirstArticle.content = "Hello world"
        theFirstArticle.creationDate = NSDate()
        theFirstArticle.modificationDate = NSDate()
        theFirstArticle.language = "ua"
        theArticleManager.save()
        
        let theSecondArticle = theArticleManager.newArticle()
        theSecondArticle.title = "Article 2"
        theSecondArticle.content = "Yoyoyoyo cheatera"
        theSecondArticle.creationDate = NSDate()
        theSecondArticle.modificationDate = NSDate()
        theSecondArticle.language = "en"
        theArticleManager.save()
        
        let theArticles = theArticleManager.getAllArticles()
        print(theArticles)
        print(theArticleManager.getArticles(containString: "rld"))
        print(theArticleManager.getArticles(withLang: "en"))
        for article in theArticles {
            theArticleManager.removeArticle(anArticle: article)
        }
        print(theArticleManager.getArticles(withLang: "uk"))
    }
    
}
