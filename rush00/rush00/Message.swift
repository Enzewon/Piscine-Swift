//
//  Message.swift
//  rush00
//
//  Created by Danil Vdovenko on 10/7/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import Foundation

struct TopicMessage : CustomStringConvertible {
    var description: String {
        return "Author: \(self.author), Text: \(self.text), Date: \(date)"
    }
    var author:  String
    var text:    String
    var date:    String
    var id:      Int
    var root:    Bool
}
