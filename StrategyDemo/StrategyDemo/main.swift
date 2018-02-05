//
//  main.swift
//  StrategyDemo
//
//  Created by wangkan mac on 2018/2/5.
//  Copyright © 2018年 wangkan mac. All rights reserved.
//

import Foundation

// Mechanic setup

var joe = Mechanic(mechanicId: 6653, name: "Joe Stevenson")
var mike = Mechanic(mechanicId: 7785, name: "Mike Rove")
var sam = Mechanic(mechanicId: 5421, name: "Sam Warren")
var tom = Mechanic(mechanicId: 99, name: "Tom Tanner")

PartsNStuff.instance.addApprovedMechanic(joe.mechanicId)

var order1 = OrderManager.instance.generateOrderForMechanic(
    mechanic: joe,
    parts: [Part(name: "Brake pads", price: 15.22),
            Part(name: "Brake Fluid", price: 18.99)],
    carType: .Asian)

var order2 = OrderManager.instance.generateOrderForMechanic(
    mechanic: mike,
    parts: [Part(name: "5 qt Synthetic Oil", price: 15.99),
            Part(name: "Standard Filters", price: 8.49)],
    carType: .European)

var order3 =  OrderManager.instance.generateOrderForMechanic(
    mechanic: sam,
    parts: [Part(name: "Engine Coolant", price: 18.99)],
    carType: .Domestic)


_ = OrderManager.instance.fulfillOrder(order1)
_ = OrderManager.instance.fulfillOrder(order2)
_ = OrderManager.instance.fulfillOrder(order3)
