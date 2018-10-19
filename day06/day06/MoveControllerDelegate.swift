//
//  MoveControllerDelegate.swift
//  day06
//
//  Created by Danil Vdovenko on 10/9/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import Foundation
import UIKit

protocol MoveControllerDelegate {
    func touchShapeBegan(withTouches touches: Set<UITouch>, andEvent event: UIEvent?, andShape shape: Shape)
}
