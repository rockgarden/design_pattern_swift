//
//  parts_supervisor.swift
//  Mechanic - Strategy
//
//  Created by Reza Shirazian on 2016-04-17.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

class PartsSupervisor {
    static let instance = PartsSupervisor()
    private let privateKey = 5
    
    private init() {}
    
    /// 签署订单API
    func getSupervisorSignatureOnOrder(_ order: Order) -> Int {
        // 取按位异或
        return order.orderId ^ privateKey
    }
}
