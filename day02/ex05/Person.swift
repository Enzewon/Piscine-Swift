//
//  Person.swift
//  ex05
//
//  Created by Danil Vdovenko on 10/3/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import Foundation

class Person {
    let name: String
    let description: String
    let date: String
    
    init(withName name: String, andDescription description: String, andDate date: String) {
        self.name = name
        self.description = description
        self.date = date
    }
}
