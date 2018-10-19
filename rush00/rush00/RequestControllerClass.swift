//
//  RequestControllerClass.swift
//  rush00
//
//  Created by Danil Vdovenko on 10/7/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

protocol RequestControllerDelegate: class {
    func authentificationAccess()
    func receivedTopics(topics: [Topic])
    func receivedMessages(messages: [TopicMessage])
    func receivedError(error: Error)
}

class RequestController {
    
    static let shared = RequestController()
    
    var locationGranted: Bool?
    
    private init(){}
    
    func requestForLocation(){
        locationGranted = true
        print("Location granted")
    }
    
    weak var delegate : RequestControllerDelegate?
    let theAPIUrl = "https://api.intra.42.fr/"
    let theCallbackUrl = "Rush00%3A%2F%2Funit.factory.swift.rush00"
    let clientID = "13e60c2dfd633e04a3e381d54dd475006f5141949f6d94f042986d8b2a08f060"
    let clientSecret = "27a13f00102d749c72c1df636b1d7c9d93fdf85d836f0105003e938549b55865"
    
    var rootViewController: UIViewController?
    var token: String!
    var authSession: SFAuthenticationSession?
    var login: String!
    var id: Int!

    
    func authentificationUsingIntra() {
        let authURL = theAPIUrl + "oauth/authorize?client_id=\(clientID)&redirect_uri=\(theCallbackUrl)&response_type=code"
        self.authSession = SFAuthenticationSession(url: URL(string: authURL)!, callbackURLScheme: theCallbackUrl, completionHandler: { (callBack: URL?, error: Error?) in
            guard error == nil, let successURL = callBack else { return }
            guard let code = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.filter({$0.name == "code"}).first else { return }
            self.manageWorkerLoginViewController(toAdd: true)
            self.authorizateRequest(withCode: code)
        })
        print("Starting SFAuthenticationSession...")
        self.authSession?.start()
    }
    
    func authorizateRequest(withCode aCode: URLQueryItem) {
        let url = URL(string: theAPIUrl + "oauth/token")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.httpBody = "grant_type=authorization_code&client_id=\(clientID)&client_secret=\(clientSecret)&\(aCode)&redirect_uri=\(theCallbackUrl)".data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                self.manageWorkerLoginViewController(toAdd: false)
            } else if let data = data {
                do {
                    let dic = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    print(dic)
                    guard let token = dic["access_token"] as? String else { return }
                    self.token = token
                    print("Access token: \(token)")
                    self.getMyLogin()
                    self.manageWorkerLoginViewController(toAdd: false)
                    DispatchQueue.main.async {
                        self.delegate?.authentificationAccess()
                    }
                }
                catch (let error) {
                    print(error)
                    self.manageWorkerLoginViewController(toAdd: false)
                }
            }
        }
        task.resume()
    }
    
    func getTopics() {
        DispatchQueue.main.async {
                 UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let url = URL(string: theAPIUrl + "v2/topics.json")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                self.delegate?.receivedError(error: error)
            } else if let data = data {
                do {
                    let array = try JSONSerialization.jsonObject(with: data, options: []) as? Array<Dictionary<String, Any>>
                    var topics = [Topic]()
                
                    for dict in array! {
                        
                        let id = dict["id"] as! Int
                        let name = dict["name"] as! String
                        let date = dict["created_at"] as! String

                        let author = dict["author"] as? Dictionary<String, Any>
                        let login = author!["login"] as! String
                        
                        let message = dict["message"] as? Dictionary<String, Any>
                        let content = message!["content"] as? Dictionary<String, Any>
                        let text = content!["markdown"] as! String
                        
                        topics.append(Topic(login: login, name: name, text: text, date: date, id: id))
                    }
                    self.delegate?.receivedTopics(topics: topics)
                }
                catch (let error) {
                    self.delegate?.receivedError(error: error)
                }
            }
        }
        task.resume()
    }
    
    func getTopicInfo(withID id: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let url = URL(string: theAPIUrl + "v2/topics/\(id)/messages.json")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                self.delegate?.receivedError(error: error)
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } else if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: []) as? Array<Dictionary<String, Any>>
                    
                    var messages: [TopicMessage] = []
                    
                    for message in dict! {
                        print(message)
                        let date = message["created_at"] as! String
                        let authorDict = message["author"] as? Dictionary<String, Any>
                        let author = authorDict!["login"] as! String
                        let text = message["content"] as! String
                        let id = message["id"] as! Int
                        let isRoot = message["is_root"] as! Bool
                        messages.append(TopicMessage(author: author, text: text, date: date, id: id, root: isRoot))
                    }
                    
                    self.delegate?.receivedMessages(messages: messages)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                }
                catch (let error) {
                    self.delegate?.receivedError(error: error)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
        }
        task.resume()
    }
    
    func sendMessage(withText text: String, withTopicID topicID: Int) {
        let url = URL(string: theAPIUrl + "v2/topics/\(topicID)/messages.json")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpBody = "message[messageable_id]=\(topicID)&message[content]=\(text)&message[author_id]=\(self.id)&message[messageable_type]=Topic".data(using: String.Encoding.utf8)
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } else if let data = data {
                do {
                    let dic = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    print(dic)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
                catch (let error) {
                    print(error)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
        }
        task.resume()
    }
    
    func sendTopic(withTitle topic: String, andWithText text: String) {
        let url = URL(string: theAPIUrl + "v2/topics.json")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpBody = "topic[cursus_ids]=[1]&topic[author_id]=\(self.id)&topic[kind]=normal&topic[kind]=normal&topic[tag_ids]=[9]&topic[language_id]=1&topic[messages_attributes][content]=\(text)&topic[messages_attributes][author_id]=\(self.id)&topic[messages_attributes][messageable_id]=1&topic[messages_attributes][messageable_type]=Topic&topic[survey_attributes][name]=\(topic)&topic[survey_attributes][survey_answers_attributes][name]=\(topic)".data(using: String.Encoding.utf8)
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } else if let data = data {
                do {
                    let dic = try JSONSerialization.jsonObject(with: data, options: [])
                    print(dic)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
                catch (let error) {
                    print(error)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
        }
        task.resume()
    }
    
    func getMyLogin() {
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let url = URL(string: theAPIUrl + "v2/me")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        _ = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                self.delegate?.receivedError(error: error)
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } else if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String,Any>

                    
                    self.login = dict!["login"] as! String
                    self.id  = dict!["id"] as! Int
                    
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                }
                catch (let error) {
                    self.delegate?.receivedError(error: error)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
            }.resume()
    }
    
    func deleteMyTopic(id: Int, completion: @escaping (_: Bool) -> Void) {
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let url = URL(string: theAPIUrl + "v2/topics/" + "\(id)")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        _ = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                completion(false)
                self.delegate?.receivedError(error: error)
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } else if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: [])
    
                    completion(true)
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                }
                catch (let error) {
                    completion(false)
                    self.delegate?.receivedError(error: error)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
            }.resume()
    }
    
}

extension RequestController {
    
    func manageWorkerLoginViewController(toAdd add: Bool) {
        guard let loginViewController = rootViewController as? LoginViewController else { return }
        if add == true {
            loginViewController.busyProcesses += 1
        } else {
            loginViewController.busyProcesses -= 1
        }
    }
    
}

extension RequestControllerDelegate {
    
    func receivedMessages(messages: [TopicMessage]) {
        
    }
    
}
