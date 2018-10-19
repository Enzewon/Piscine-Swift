//
//  AddMessageViewController.swift
//  rush00
//
//  Created by Danil Vdovenko on 10/7/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class AddMessageViewController: UIViewController, RequestControllerDelegate {
    
    @IBOutlet weak var addMessageTextView: UITextView!
    
    var topicID: Int!
    
    func receivedError(error: Error) {
        showAlertView(title: "Error", message: error.localizedDescription)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMessageTextView.layer.borderColor = UIColor.black.cgColor
        addMessageTextView.layer.cornerRadius = 8.0
        addMessageTextView.layer.borderWidth = 2.0
        RequestController.shared.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(sendMessage))
    }

    @IBAction func sendMessage() {
        if !addMessageTextView.text.isEmpty {
            RequestController.shared.sendMessage(withText: addMessageTextView.text, withTopicID: self.topicID)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func authentificationAccess() {
        
    }
    
    func receivedTopics(topics: [Topic]) {
        
    }
    
}
