//
//  APITwitterDelegateProtocol.swift
//  day04
//
//  Created by Danil Vdovenko on 10/5/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import Foundation

protocol APITwitterDelegate: class {
    
    func processAllTweets(tweetsArray aTweets: [Tweet])
    func showError(withError anError: Error)

}
