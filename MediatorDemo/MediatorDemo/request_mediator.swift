//
//  RequestMediator.swift
//  Mechanic - Mediator
//

import Foundation

class RequestMediator: Mediator {
    private let closeDistance: Float = 50.0
    private var mechanics: [Mechanic] = []

    func addMechanic(_ mechanic: Mechanic) {
        mechanics.append(mechanic)
    }

    func send(_ request: Request) {
        for oneOfTheMechanics in mechanics {
            if oneOfTheMechanics !== request.mechanic &&
                request.mechanic.isCloseTo(oneOfTheMechanics, within: closeDistance) {
                oneOfTheMechanics.receive(request)
            }
        }
    }
}
