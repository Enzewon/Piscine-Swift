//
//  ViewController.swift
//  rush00
//
//  Created by Danil Vdovenko on 10/6/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, RequestControllerDelegate {
    
    @IBOutlet weak var containerView: UIView!
    
    var busyProcesses: Int = 0 {
        didSet {
            if oldValue == 0 {
                DispatchQueue.main.async { [weak self] in
                    self?.startActivityIndicator()
                }
            }
        }
        willSet {
            if newValue == 0 {
                DispatchQueue.main.async { [weak self] in
                    self?.stopActivityIndicator()
                }
            }
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.black
        indicator.layer.cornerRadius = 20.0
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(activityIndicator)
        activityIndicator.center = containerView.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        RequestController.shared.requestForLocation()
        RequestController.shared.rootViewController = self
        RequestController.shared.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func authenticateUser(_ sender: Any) {
        RequestController.shared.authentificationUsingIntra()
        RequestController.shared.rootViewController = self
    }
    
    func receivedTopics(topics: [Topic]) {
        
    }
    
    func receivedError(error: Error) {
        self.showAlertView(title: "Error", message: error.localizedDescription)
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    //MARK: - RequestControllerDelegate
    
    func authentificationAccess() {
        let vc = TopicsViewController(nibName: "TopicsViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}

extension UIViewController {
    
    func showAlertView(title: String, message: String) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController {
    
    func startActivityIndicator() {
        containerView.alpha = 0.8
        activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func stopActivityIndicator() {
        containerView.alpha = 0
        activityIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

