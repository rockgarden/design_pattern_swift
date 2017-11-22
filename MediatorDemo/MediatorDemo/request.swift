//
//  request.swift
//  Mechanic - Mediator
//

import Foundation

class Request {
    var message: String
    var parts: [Part]?
    var mechanic: Mechanic

    init(message: String, mechanic: Mechanic, parts: [Part]?) {
        self.message = message
        self.parts = parts
        self.mechanic = mechanic
    }

    convenience init(message: String, mechanic: Mechanic) {
        self.init(message: message, mechanic: mechanic, parts: nil)
    }
}
