//
//  TableViewController.swift
//  day09
//
//  Created by Danil Vdovenko on 10/12/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit
import dvdovenk2018

class TableViewController: UITableViewController {
    
    var theArticles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let theLanguage = Locale.preferredLanguages.first else {
            return
        }
        if theLanguage == "uk-US" {
            title = "Мій щоденник"
        } else if theLanguage == "ru-US" {
            title = "Мой дневник"
        } else {
            title = "My Diary"
        }
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addArticle))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let theLanguage = Locale.preferredLanguages.first else {
            return
        }
        theArticles = ArticleManagerController.shared.getArticles(withLang: theLanguage)
        tableView.reloadData()
    }
    
    @IBAction func addArticle() {
        let theDestinationViewController = AddArticleViewController()
        show(theDestinationViewController, sender: self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theArticles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "diaryCell") as! TableViewCell?
        
        if (cell == nil) {
            tableView.register(UINib.init(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "diaryCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "diaryCell") as! TableViewCell?
        }
        
        let theDateFormatter = DateFormatter()
        theDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        cell?.contentLabel.text = theArticles[indexPath.row].content
        cell?.dateCreatedLabel.text = theDateFormatter.string(from: theArticles[indexPath.row].creationDate! as Date)
        cell?.dateModifiedLabel.text = theDateFormatter.string(from: theArticles[indexPath.row].modificationDate! as Date)
        cell?.cellImageView.image = UIImage(data: theArticles[indexPath.row].image! as Data)
        cell?.titleLabel.text = theArticles[indexPath.row].title

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theDestinationViewController = AddArticleViewController()
        theDestinationViewController.article = theArticles[indexPath.row]
        show(theDestinationViewController, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let theArticle = theArticles[indexPath.row]
            DispatchQueue.main.async {
                ArticleManagerController.shared.removeArticle(anArticle: theArticle)
                ArticleManagerController.shared.save()
            }
            theArticles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
