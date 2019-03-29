//
//  ViewController.swift
//  Calculator
//
//  Created by Erin Vincent on 3/21/19.
//  Copyright © 2019 Erin Vincent. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var values = ["0"]
    var focusedValueIndex = 0
    var operation = ""
    var onFirstDigit = true
    
    @IBOutlet weak var displayedValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        clearValues()
    }
    
    func clearValues() {
        values = ["0"]
        focusedValueIndex = 0
        operation = ""
        displayedValue.text = "0"
    }
    
    func saveOperation(value: String) {
        focusedValueIndex += 1
        values.append(value)
        operation = value
    }
    
    func performOperation(operation: String, value1: String, value2: String) -> String {
        
        let firstDouble:Double? = Double(value1)
        let secondDouble:Double? = Double(value2)
        
        var result:Decimal = 0.0
        
        if let firstDouble = firstDouble, let secondDouble = secondDouble {
            let firstDecimal:Decimal? = Decimal(firstDouble)
            let secondDecimal:Decimal? = Decimal(secondDouble)
            if let first = firstDecimal, let second = secondDecimal {
                
                switch(operation) {
                case "/":
                    result = (first / second)
                case "x":
                    result = (first * second)
                case "+":
                    result = (first + second)
                case "-":
                    result = (first - second)
                default:
                    return "Error"
                }
            }
        }
        print("Result: \(result)")
        return NSDecimalNumber(decimal: result).stringValue
    
    }
    
    func reduceToTotal(valuesToReduce: [String]) -> String {
        //Start with the first value
        print("values to reduce: \(valuesToReduce)")
        var total = valuesToReduce[0]
        let indexOfLastValue = valuesToReduce.count - 1
        for (index, value) in valuesToReduce.enumerated() {
            if (index < indexOfLastValue) {
                 let nextValue = valuesToReduce[index + 1]
                if (index % 2 != 0) {
                    //Look only at operation symbols
                    total = performOperation(operation: value, value1: total, value2: nextValue)
                }
            }
        }
        return total
    }
    
    
    func calculate() -> String {
        
        var addSubtractArray : [String] = []
        var multiplyDivideArray : [String] = []
        var multiplyingOrDividing = false
        let indexOfLastValue = values.count - 1
        
        for (index, value) in values.enumerated() {
            //Handle the first value. This will always be a number.
            if (index == 0) {
                if (values.count == 1) {
                    return values[0]
                }
                 let nextValue = values[index + 1]
                print("Calculating first number")
                if (nextValue == "x" || nextValue == "/") {
                    //This is the first value and it is being multiplied or divided
                    multiplyingOrDividing = true
                    multiplyDivideArray.append(value)
                } else {
                    //This is the first value and it is not being multiplied or divided
                    addSubtractArray.append(value)
                }
            } else if (index != 0 && index < indexOfLastValue) {
                print("index \(index) of \(indexOfLastValue)")
                 let nextValue = values[index + 1]
                let previousValue = values[index - 1]
                print("calculating subsequent number")
                //Handle subsequent values.
                //Check whether value is number or operation
                if (index % 2 == 0) {
                    print("Looking at number")
                    //Is number
                    if (nextValue == "x" || nextValue == "/") {
                        print("multiplying or dividing \(value)")
                        //Current value is part of a multiply or divide operation
                        multiplyingOrDividing = true
                        multiplyDivideArray.append(value)
                    } else {
                        if (previousValue == "x" || previousValue == "/") {
                            print("multiplying or dividing \(value)")
                            //Value should be mulitplied or divided by previous number
                            multiplyDivideArray.append(value)
                        } else {
                            print("adding or subtracting")
                              //Not multiplying or dividing
                            //If there are values in multiplyDivideArray then calculate them
                            if (multiplyDivideArray.count > 0) {
                                print("compute multiply/divide first")
                                print("Multiply divide array: \(multiplyDivideArray)")
                                let multiplyDivideTotal = reduceToTotal(valuesToReduce: multiplyDivideArray)
                                print("Multuply divide total \(multiplyDivideTotal)")
                                //Add total to addSubtractArray
                                addSubtractArray.append(multiplyDivideTotal)
                                print("multiplied total added: \(addSubtractArray)")
                                //Stop multiyply or dividing
                                multiplyingOrDividing = false
                                //Reset multiplyDivideArray
                                multiplyDivideArray = []
                            }
                            //Add current value to addSubtractArray
                            addSubtractArray.append(value)
                        }
                    }
                } else {
                    print("looking at operation")
                    //Is operation
                    if (value == "x" || value == "/") {
                        print("adding \(value) to multiply/divide")
                        multiplyDivideArray.append(value)
                    } else {
                        print("adding \(value) to add/subtract")
                        if (multiplyingOrDividing) {
                            print("Multiply divide array: \(multiplyDivideArray)")
                            let multiplyDivideTotal = reduceToTotal(valuesToReduce: multiplyDivideArray)
                            print("Multuply divide total \(multiplyDivideTotal)")
                            //Add total to addSubtractArray
                            addSubtractArray.append(multiplyDivideTotal)
                            print("multiplied total added: \(addSubtractArray)")
                            //Stop multiyply or dividing
                            multiplyingOrDividing = false
                            //Reset multiplyDivideArray
                            multiplyDivideArray = []
                        }
                      
                        addSubtractArray.append(value)
                    }
                }
            } else if (index == indexOfLastValue) {
                print("This is the last value \(value)")
                if (multiplyingOrDividing) {
                    print("multiply or divide last")
                    multiplyDivideArray.append(value)
                    print("Multiply divide array: \(multiplyDivideArray)")
                    let multiplyDivideTotal = reduceToTotal(valuesToReduce: multiplyDivideArray)
                    print("Multuply divide total \(multiplyDivideTotal)")
                    //Add total to addSubtractArray if there are other values that need to be added or subtracted
                    addSubtractArray.append(multiplyDivideTotal)
                    print("multiplied total added: \(addSubtractArray)")
                    //Stop multiyply or dividing
                    multiplyingOrDividing = false
                    //Reset multiplyDivideArray
                    multiplyDivideArray = []
                } else {
                     addSubtractArray.append(value)
                }
            }
        }
        
        
        print("Add or subtract: \(addSubtractArray)")
        let total = reduceToTotal(valuesToReduce: addSubtractArray)
        print("Total: \(total)")
        //Reset values with total as first value
        values = [total]
        focusedValueIndex = 0
        onFirstDigit = true
        return total
    }
    
    func switchCurrentValueSign() {
        values = ["0"]
        focusedValueIndex = 0
        operation = ""
        
        if var value = displayedValue.text {
            if value == "0" {
                values[focusedValueIndex] = "-"
                onFirstDigit = false
                print("changed to negative \(values[focusedValueIndex])")
            } else if value.starts(with: "-") {
                //If already negative, remove negative sign
                value.removeFirst()
                values[focusedValueIndex] = value
                 print("changed to positive \(values[focusedValueIndex])")
            } else {
                let hasIndex = values.indices.contains(focusedValueIndex)
                if hasIndex {
                    values[focusedValueIndex] = "-" + value
                } else {
                    values.append("-")
                }
                 print("changed to negative \(values[focusedValueIndex])")
            }
        }
    
        displayedValue.text = values[focusedValueIndex]
    }
    
    func convertToPercentage() {
        values = ["0"]
        focusedValueIndex = 0
        operation = ""
        
        if let value = displayedValue.text {
            if let valueDouble = Double(value) {
                let percentage = valueDouble / 100.00
                values[focusedValueIndex] = String(percentage)
                displayedValue.text = values[focusedValueIndex]
            }
        }
    }
    
    @IBAction func clearButtonPress(_ sender: Any) {
        clearValues()
    }
    
    @IBAction func addToValue(_ sender: UIButton) {
        if let buttonValue = sender.currentTitle {
            
            //The current value has at least one digit
            let hasIndex = values.indices.contains(focusedValueIndex)
            if hasIndex {
                print("concat \(buttonValue) to current value \(values[focusedValueIndex])")
                if (onFirstDigit) {
                    //First digit
                    values[focusedValueIndex] = buttonValue
                    onFirstDigit = false
                } else {
                    //Subsequent digit
                    values[focusedValueIndex] += buttonValue
                    print("now \(values[focusedValueIndex])")
                }
                
            } else {
               
                //This is the first digit of a new value
                values.append(buttonValue)
                 print("first digit of NEW value \(buttonValue)")
            }
            displayedValue.text = values[focusedValueIndex]
            print("values \(values)")
            
        }
    }
    
    @IBAction func opreationButtonPress(_ sender: UIButton) {
        if let buttonValue = sender.currentTitle {
            saveOperation(value: buttonValue)
        }
        focusedValueIndex += 1
    }
    
    @IBAction func equals(_ sender: Any) {
        displayedValue.text = calculate()
    }
    
    @IBAction func switchSign(_ sender: Any) {
        switchCurrentValueSign()
    }
    
    @IBAction func percent(_ sender: Any) {
        convertToPercentage()
    }
    
}

