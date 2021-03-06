//
//  Add.swift
//  Mechanic - Interpreter
//
//  Created by Reza Shirazian on 2016-04-24.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

class Add: Expression {

    var leftOperand: Expression
    var rightOperand: Expression

    init(leftOperand: Expression, rightOperand: Expression) {
        self.leftOperand = leftOperand
        self.rightOperand = rightOperand
    }

    func interpret(_ variables: [String : Expression]) -> Double {
        return leftOperand.interpret(variables) + rightOperand.interpret(variables)
    }
}
