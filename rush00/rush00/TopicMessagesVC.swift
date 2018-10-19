//
//  TopicMessagesVC.swift
//  rush00
//
//  Created by Mykola Ponomarov on 10/7/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class TopicMessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, RequestControllerDelegate {
    
    func authentificationAccess() {
        
    }
    
    func receivedTopics(topics: [Topic]) {
        
    }
    
    func receivedMessages(messages: [TopicMessage]) {
        self.messages = messages
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print(self.messages)
    }
    
    func receivedError(error: Error) {
        showAlertView(title: "Error", message: error.localizedDescription)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    var topic: Topic!
    var messages: [TopicMessage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = topic.name
        self.tableView.delegate = self
        self.tableView.dataSource = self
        RequestController.shared.delegate = self
        RequestController.shared.getTopicInfo(withID: topic.id)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addMessage))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func addMessage() {
        let addMessageVC = AddMessageViewController()
        addMessageVC.topicID = self.topic.id
        navigationController?.pushViewController(addMessageVC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "topicMessage") as! TopicMessageTableViewCell?
        
        if cell == nil {
            tableView.register(UINib.init(nibName: "TopicMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "topicMessage")
            cell = tableView.dequeueReusableCell(withIdentifier: "topicMessage") as! TopicMessageTableViewCell?
        }
        if messages[indexPath.row].root {
            cell?.backgroundColor = UIColor.lightGray
        }
        cell?.topicMessageAuthor.text = messages[indexPath.row].author
        cell?.topicMessageDate.text = messages[indexPath.row].date
        cell?.topicMessageText.text = messages[indexPath.row].text
        
        return cell!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
