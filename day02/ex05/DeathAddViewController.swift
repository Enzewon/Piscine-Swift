//
//  DeathAddViewController.swift
//  ex05
//
//  Created by Danil Vdovenko on 10/3/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class DeathAddViewController: UIViewController {

    @IBOutlet weak var personNameTextField: UITextField!
    @IBOutlet weak var personDatePicker: UIDatePicker!
    @IBOutlet weak var personDescriptionTextView: UITextView!
    
    var mainViewController: TableViewController?
    
    let alertController = UIAlertController(title: "Error", message: "Name is required!", preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertController.addAction(self.defaultAction)
        self.personDatePicker.minimumDate = Date()
        self.personDescriptionTextView.layer.borderColor = UIColor.black.cgColor
        self.personDescriptionTextView.layer.borderWidth = 2.5
        self.personDescriptionTextView.layer.cornerRadius = 12.0
        self.personNameTextField.layer.borderColor = UIColor.black.cgColor
        self.personNameTextField.layer.borderWidth = 2.5
        self.personNameTextField.layer.cornerRadius = 7.0
        self.personDatePicker.setValue(UIColor.white, forKey: "textColor")
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))
    }
    
    @objc func doneButtonPressed() {
        self.view.endEditing(true)
        guard let _ = self.mainViewController else { return }
        guard let name = self.personNameTextField.text else { return }
        guard let description = self.personDescriptionTextView.text else { return }
        if name != "" {
            let date = self.personDatePicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+3")
            let finalDate = dateFormatter.string(from: date)
            mainViewController?.persons.append(Person(withName: name, andDescription: description, andDate: finalDate))
            mainViewController?.tableView.reloadData()
            navigationController?.popToRootViewController(animated: true)
        } else {
            self.present(self.alertController, animated: true, completion: nil)
        }
    }

}
