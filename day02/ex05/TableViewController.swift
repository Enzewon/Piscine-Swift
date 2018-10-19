//
//  TableViewController.swift
//  ex05
//
//  Created by Danil Vdovenko on 10/3/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var persons: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.persons.append(Person(withName: "Viktor Tsoi", andDescription: "Killed by bus", andDate: "1992-12-02 19:26"))
        self.persons.append(Person(withName: "Jack Sparrow", andDescription: "Poisoned", andDate: "1852-05-30 13:32"))
        self.persons.append(Person(withName: "John Snow", andDescription: "Stabbed by daggers", andDate: "1232-04-22 18:44"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.persons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? TableViewCell else { return UITableViewCell() }
        
        cell.personDate.text = self.persons[indexPath.row].date
        cell.personDescription.text = self.persons[indexPath.row].description
        cell.personName.text = self.persons[indexPath.row].name
        
        return cell
    }
    
    @objc func addButtonTapped() {
        performSegue(withIdentifier: "goToAnotherVC", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DeathAddViewController {
            let vc = segue.destination as? DeathAddViewController
            vc?.mainViewController = self
        }
    }

}
