//
//  ShapeClass.swift
//  day06
//
//  Created by Danil Vdovenko on 10/9/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import Foundation
import UIKit

class Shape: UIView, UIGestureRecognizerDelegate {
    
    var delegate: MoveControllerDelegate?
    let isSquare: Bool
    let color: UIColor
    var saveBounds: CGRect!
    
    init(withCoordinateX aCoordinateX: CGFloat, withCoordinateY aCoordinateY: CGFloat, isSquare aSquare: Bool, withColor aColor: UIColor) {
        
        self.isSquare = aSquare
        self.color = aColor
        let theRect = CGRect(x: aCoordinateX, y: aCoordinateY, width: 100, height: 100)
        self.saveBounds = theRect
        super.init(frame: theRect)
        self.backgroundColor = aColor
        if self.isSquare == false {
            self.layer.cornerRadius = min(bounds.size.width, bounds.size.height) / 2.0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchShapeBegan(withTouches: touches, andEvent: event, andShape: self)
    }
    
}
