//
//  ViewController.swift
//  ex04
//
//  Created by Danil Vdovenko on 10/2/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    var operation: Int = 0
    var firstOperand: Double?
    var secondOperand: Double?
    var operationSubmitted: Bool = false
    
    enum Actions: Int {
        typealias RawValue = Int
        case AC = 11
        case NEG = 12
        case Plus = 13
        case Mult = 14
        case Minus = 15
        case Divide = 16
        case Equal = 17
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func doAnimation(withText aText: String, isNumber aNumber: Bool) {
        var theResultingText = aText
        if (aNumber == true) {
            guard let theNumber = Double(aText) else { return }
            if theNumber > 0.0 && aText.count > 16 {
                let theResultingNumber = theNumber / pow(10.0, Double(aText.count - 1))
                theResultingText = "\(theResultingNumber.clean)e\(aText.count - 1)"
            } else {
                theResultingText = "\(theNumber.clean)"
            }
        }
        self.label.text = theResultingText
        UIView.animate(withDuration: 0.4, animations: {
            self.label.alpha = 0
        })
        UIView.animate(withDuration: 0.4, animations: {
            self.label.alpha = 1
        })
    }
    
    private func saveResult(firstOperand first: Double, secondOperand second: Double, operation: Int) {
        let sum = self.doMath(withOperand: operation, andFirst: first, andSecond: second)
        self.firstOperand = sum
        self.doAnimation(withText: sum.clean, isNumber: true)
    }
    
    private func zeroing() {
        self.label.text = "0"
        self.operation = 0
        self.firstOperand = nil
        self.secondOperand = nil
        self.operationSubmitted = false
    }
    
    private func doMath(withOperand operand: Int, andFirst first: Double, andSecond second: Double) -> Double {
        var sum: Double = 0
        if self.operation == Actions.Plus.rawValue {
            sum = first + second
        } else if self.operation == Actions.Minus.rawValue {
            sum = first - second
        } else if self.operation == Actions.Mult.rawValue {
            sum = first * second
        } else if self.operation == Actions.Divide.rawValue {
            sum = first / second
        }
        return sum
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard var text = self.label.text else { return }
        let tag = sender.tag
        if tag <= 9 {
            self.secondOperand = nil
            if text == "0" || text == "Convert Problem" || self.operationSubmitted == true {
                self.operationSubmitted = false
                self.label.text = "\(tag)"
            } else if text == "-0" {
                self.label.text = "-\(tag)"
            } else {
                if (text[text.startIndex] == "-") {
                    self.label.text = "-\(text)\(tag)"
                } else {
                    self.label.text = "\(text)\(tag)"
                }
            }
        } else {
            switch tag {
            case Actions.AC.rawValue:
                self.zeroing()
            case Actions.NEG.rawValue:
                if (text[text.startIndex] == "-") {
                    let index = text.index(text.startIndex, offsetBy: 1)
                    text = String(text.suffix(from: index))
                } else {
                    text = "-\(text)"
                }
                if self.secondOperand != nil {
                    self.firstOperand = Double(text)
                }
                self.label.text = text
            case Actions.Plus.rawValue, Actions.Minus.rawValue, Actions.Mult.rawValue,
                        Actions.Divide.rawValue, Actions.Equal.rawValue:
                guard let convert = Double(text) else {
                    self.doAnimation(withText: "Convert Problem", isNumber: false)
                    self.zeroing()
                    return
                }
                self.operationSubmitted = true
                guard let first = self.firstOperand else {
                    self.operation = tag
                    self.firstOperand = convert
                    self.doAnimation(withText: convert.clean, isNumber: true)
                    return
                }
                if (convert == 0 && self.operation == Actions.Divide.rawValue) {
                    self.zeroing()
                    self.doAnimation(withText: "Division By Zero", isNumber: false)
                    return
                }
                guard let second = self.secondOperand else {
                    self.saveResult(firstOperand: first, secondOperand: convert, operation: self.operation)
                    self.secondOperand = convert
                    return
                }
                if tag != Actions.Equal.rawValue {
                    self.operation = tag
                } else {
                    self.saveResult(firstOperand: first, secondOperand: second, operation: self.operation)
                }
            default:
                break
            }
        }
    }
    
}

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}


