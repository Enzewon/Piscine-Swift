//
//  ViewController.swift
//  day09
//
//  Created by Danil Vdovenko on 10/12/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loginAction()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        loginAction()
    }
    
    func loginAction() {
        let theContext = LAContext()
        
        if theContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            theContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "You have to be authenticated to use this Diary", reply: { [weak self] (aSuccess, anError) in
                if aSuccess == true {
                    DispatchQueue.main.async {
                        let theDestinationViewController = TableViewController()
                        self?.show(theDestinationViewController, sender: self)
                    }
                } else {
                    self?.showAlertView(title: "Error", message: "Authentification Error")
                }
            })
        } else if theContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            theContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "You have to be authenticated to use this Diary", reply: { [weak self] (aSuccess, anError) in
                if aSuccess == true {
                    DispatchQueue.main.async {
                        let theDestinationViewController = TableViewController()
                        self?.show(theDestinationViewController, sender: self)
                    }
                } else {
                    self?.showAlertView(title: "Error", message: "Authentification Error")
                }
            })
        }
    }

}

extension UIViewController {
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

