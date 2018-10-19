//
//  Tweet.swift
//  day04
//
//  Created by Danil Vdovenko on 10/5/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import Foundation
import UIKit

struct Tweet: CustomStringConvertible {
    var description: String {
        return "(name: \(name), text: \(text), date: \(date))"
    }
    let name: String
    let text: String
    let date: String
}
