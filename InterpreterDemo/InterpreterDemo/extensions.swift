//
//  extensions.swift
//  Mechanic - Interpreter
//
//  Created by Reza Shirazian on 2016-04-24.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

extension String {
    struct MyNumberFormatter {
        static let instance = NumberFormatter()
    }
    
    var doubleValue: Double? {
        return MyNumberFormatter.instance.number(from: self)?.doubleValue
    }

    var integerValue: Int? {
        return MyNumberFormatter.instance.number(from: self)?.intValue
    }

    func contains(find: String) -> Bool {
        return self.range(of: find) != nil
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
