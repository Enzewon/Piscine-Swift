//
//  APIControllerClass.swift
//  day04
//
//  Created by Danil Vdovenko on 10/5/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import Foundation
import UIKit

class APIController {
    
    weak var delegate: APITwitterDelegate?
    let apiURL = "https://api.twitter.com/"
    let token: String
    
    init(withToken token: String, andAPITwitterDelegate delegate: APITwitterDelegate) {
        self.token = token
        self.delegate = delegate
    }
    
    func getAPITwitterRequest(withText aText: String) {
        let newText = "\"\(aText)\""
        guard let theEncodedText = newText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return }
        guard let theUnwrappedURL = URL(string: apiURL + "1.1/search/tweets.json?q=\(theEncodedText)&count=100") else { return }
        var theRequest = URLRequest(url: theUnwrappedURL as URL)
        theRequest.httpMethod = "GET"
        theRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let theTask = URLSession.shared.dataTask(with: theRequest) {
            (data, response, error) in
            if let theError = error {
                self.delegate?.showError(withError: theError)
            } else if let theData = data {
                do {
                    let theDictionary = try JSONSerialization.jsonObject(with: theData, options: []) as! [String:Any]
                    guard let theArray = theDictionary["statuses"] as? NSArray else { return }
                    var theTweets: [Tweet] = []
                    for theElement in theArray {
                        guard let theDecodedElement = theElement as? NSDictionary,
                                    let theTweetText = theDecodedElement["text"] as? String,
                                    let theTweetDate = theDecodedElement["created_at"] as? String,
                                    let theUserInfoDecodedElement = theDecodedElement["user"] as? NSDictionary,
                                    let theTweetUser = theUserInfoDecodedElement["name"] as? String else { continue }
                        
                        theTweets.append(Tweet(name: theTweetUser, text: theTweetText,
                                    date: self.formatDate(withString: theTweetDate)))
                    }
                    self.delegate?.processAllTweets(tweetsArray: theTweets)
                }
                catch (let theError) {
                    self.delegate?.showError(withError: theError)
                }
            }
        }
        theTask.resume()
    }
    
    private func formatDate(withString aStringDate: String) -> String {
        let theDateFormatter = DateFormatter()
        theDateFormatter.dateFormat = "E MMM d HH:mm:ss Z yyyy"
        guard let theTemporaryDate = theDateFormatter.date(from: aStringDate) else { return "Unknown" }
        let theNewDateFormatter = DateFormatter()
        theNewDateFormatter.dateFormat = "E d HH:mm:ss"
        theNewDateFormatter.timeZone = TimeZone(abbreviation: "GMT+3")
        return theNewDateFormatter.string(from: theTemporaryDate)
    }
    
}
