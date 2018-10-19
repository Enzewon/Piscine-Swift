//
//  TopicsViewController.swift
//  day04
//
//  Created by Mykola Ponomarov on 10/7/18.
//  Copyright © 2018 Nikolas Ponomarov. All rights reserved.
//

import UIKit

class TopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RequestControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var arrTopics: [Topic] = []
    var myLogin: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        RequestController.shared.delegate = self
        RequestController.shared.getTopics()
        
        myLogin = RequestController.shared.login
        
        self.title = "Topics"
        
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addPressed))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        //self.navigationItem.setHidesBackButton(true, animated:true);

        let leftButtonItem = UIBarButtonItem.init(title: "LogOut", style: .plain, target: self, action: #selector(logOutPressed))
        self.navigationItem.setLeftBarButton(leftButtonItem, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - RequestControllerDelegate
    
    func receivedError(error: Error) {
        print(error.localizedDescription)
        self.showAlertView(title: "Error", message: (error.localizedDescription))
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func receivedTopics(topics: [Topic]) {
        arrTopics = topics
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
    
    func authentificationAccess() {
        
    }
    
    //MARK: - Action
    
    @IBAction func addPressed(_ sender: Any) {
        
        let vc = AddTopicViewController(nibName: "AddTopicViewController", bundle: nil)
        
        //vc.delegate = self
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func logOutPressed(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
        RequestController.shared.token = nil
    }
    
    //MARK: - Table View Delegate, Datasourse
    
     func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {

        var arr = [UITableViewRowAction]()
        
        if self.myLogin == arrTopics[editActionsForRowAt.row].login {
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
                print("Edit button tapped")
            }
            edit.backgroundColor = .orange
            
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                
                RequestController.shared.deleteMyTopic(id: self.arrTopics[editActionsForRowAt.row].id, completion: {
                    (done) in
                    
                    if done {
                        self.arrTopics.remove(at: editActionsForRowAt.row)
                        self.tableView.reloadData()
                    }
                })
                
            }
            
            delete.backgroundColor = .red
            
            arr.append(delete)
            arr.append(edit)
        }
        
        return arr
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = TopicMessagesVC(nibName: "TopicMessagesVC", bundle: nil)
        vc.topic = self.arrTopics[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Custom Cell") as! CustomTableViewCell?
        
        if (cell == nil) {
            tableView.register(UINib.init(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "Custom Cell")
            cell = tableView.dequeueReusableCell(withIdentifier: "Custom Cell") as! CustomTableViewCell?
        }
        
        cell?.nameLbl.text = arrTopics[indexPath.row].login
        cell?.dateLbl.text = arrTopics[indexPath.row].date
        cell?.descriprionLbl.text = arrTopics[indexPath.row].name
        
        return cell!
    }
    

}
