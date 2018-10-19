//
//  ViewController.swift
//  day04
//
//  Created by Danil Vdovenko on 10/5/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let COSTUMER_KEY = ""
    let COSTUMER_SECRET = ""
    let apiURL = "https://api.twitter.com/"
    
    var apiControllerClass: APIController?
    
    var tweetsData: [Tweet] = []
    
    @IBOutlet weak var containerView: UIView!
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.black
        indicator.layer.cornerRadius = 20.0
        return indicator
    }()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
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
    
    var token: String = "" {
        willSet {
            if newValue != "" {
                self.apiControllerClass = APIController(withToken: newValue, andAPITwitterDelegate: self)
                self.apiControllerClass?.getAPITwitterRequest(withText: "school 42")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.backgroundColor = UIColor.gray
        containerView.alpha = 0.8
        containerView.addSubview(activityIndicator)
        activityIndicator.center = containerView.center
        busyProcesses += 1
        getToken()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell", for: indexPath) as! TableViewCell
        
        if tweetsData.count > 0 {
            cell.tweetNameLabel.text = tweetsData[indexPath.row].name
            cell.tweetTextLabel.text = tweetsData[indexPath.row].text
            cell.tweetDateLabel.text = tweetsData[indexPath.row].date
        }
        
        return cell
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let theAPIController = self.apiControllerClass else {
            showAlert(withMessage: "Some problems with API Controller, try again")
            return false
        }
        guard let theTrimmedText = textField.text else {
            showAlert(withMessage: "Invalid text")
            return false
        }
        guard theTrimmedText.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            showAlert(withMessage: "Empty text, type something!")
            return false
        }
        view.endEditing(true)
        busyProcesses += 1
        theAPIController.getAPITwitterRequest(withText: theTrimmedText)
        return true
    }
    
}

extension ViewController {
    
    func showAlert(withMessage message: String) {
        if busyProcesses != 0 {
            busyProcesses -= 1
        }
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
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

extension ViewController: APITwitterDelegate {
    
    func processAllTweets(tweetsArray aTweets: [Tweet]) {
        tweetsData = aTweets
        busyProcesses -= 1
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func showError(withError anError: Error) {
        showAlert(withMessage: anError.localizedDescription)
    }

}

extension ViewController {
    
    func getToken() {
        let theBearer = ((COSTUMER_KEY + ":" + COSTUMER_SECRET).data(using: String.Encoding.utf8))!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        guard let theUnwrappedURL = URL(string: apiURL + "oauth2/token") else { return }
        var theRequest = URLRequest(url: theUnwrappedURL as URL)
        theRequest.httpMethod = "POST"
        theRequest.setValue("Basic " + theBearer, forHTTPHeaderField: "Authorization")
        theRequest.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        theRequest.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
        let theTask = URLSession.shared.dataTask(with: theRequest) {
            (data, response, error) in
            if let error = error {
                self.showAlert(withMessage: error.localizedDescription)
            } else if let data = data {
                do {
                    let dic = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    guard let theToken = dic["access_token"] as? String else { return }
                    self.token = theToken
                }
                catch (let error) {
                    self.showAlert(withMessage: error.localizedDescription)
                }
            }
        }
        theTask.resume()
    }
    
}
