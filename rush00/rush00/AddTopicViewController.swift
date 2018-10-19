//
//  AddTopicViewController.swift
//  day04
//
//  Created by Mykola Ponomarov on 10/7/18.
//  Copyright © 2018 Nikolas Ponomarov. All rights reserved.
//

import UIKit

class AddTopicViewController: UIViewController, RequestControllerDelegate {
    
    
    @IBOutlet weak var topicTitleTextField: UITextField!
    @IBOutlet weak var topicContentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Topic"
        
        RequestController.shared.delegate = self
        let rightButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(addTopic))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        topicTitleTextField.layer.borderWidth = 2
        topicTitleTextField.layer.borderColor = UIColor.black.cgColor
        topicTitleTextField.layer.cornerRadius = 5.0
        topicContentTextView.layer.borderWidth = 2
        topicContentTextView.layer.borderColor = UIColor.black.cgColor
        topicContentTextView.layer.cornerRadius = 5.0
        
        let tap = UITapGestureRecognizer.init(target:self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tap)
    }

    @objc func viewTapped() {
        self.topicTitleTextField.endEditing(true)
        self.topicContentTextView.endEditing(true)
    }
    
    @IBAction func addTopic(_ sender: Any) {
        guard let text = topicTitleTextField.text else { return }
        if !text.isEmpty && !topicContentTextView.text.isEmpty {
            RequestController.shared.sendTopic(withTitle: text, andWithText: topicContentTextView.text)
        }
    }
    
    func authentificationAccess() {
        
    }
    
    func receivedTopics(topics: [Topic]) {
        
    }
    
    func receivedError(error: Error) {
        showAlertView(title: "Error", message: error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
