//
//  Topic.swift
//  rush00
//
//  Created by Mykola Ponomarov on 10/7/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import Foundation

struct Topic : CustomStringConvertible {
    var description: String {
        return "Login: \(self.login), Name: \(self.name), Text: \(self.text), Date: \(date), Id: \(id)"
    }
    var login:  String
    var name:   String
    var text:   String
    var date:   String
    var id:     Int
}
