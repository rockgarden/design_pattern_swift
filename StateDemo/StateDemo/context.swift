//
//  context.swift
//  Mechanic - State
//
//  Created by Reza Shirazian on 2016-04-19.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

class Context {
    
    /// 状态
    private var state: State = SubmittedState()
    
    func getMessageToCustomer() -> String {
        return state.getMessageToCustomer(context: self)
    }
    
    func getPrice() -> Double? {
        return state.getPrice(context: self)
    }
    
    func getReceipt() -> Receipt? {
        return state.getReceipt(context: self)
    }
    
    func changeStateToReady(price: Double) {
        state = ReadyState(price: price)
    }
    
    func changeStateToPending() {
        state = PendingState()
    }
    
    func changeStateToBooked(price: Double, mechanic: Mechanic) {
        state = BookedState(price: price, mechanic: mechanic)
    }
    
    func changeStateToCompleted(price: Double, mechanic: Mechanic, receipt: Receipt) {
        state = CompletedState(price: price, mechanic: mechanic, receipt: receipt)
    }
    
}
