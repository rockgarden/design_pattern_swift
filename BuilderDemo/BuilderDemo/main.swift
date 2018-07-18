//
//  main.swift
//  Mechanic - Builder
//
//  Created by Reza Shirazian on 2016-04-30.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation


var quoteBuilder = QuoteBuilder()

quoteBuilder.isValid

quoteBuilder.setCustomer(customer: Customer(name: "Reza Shirazian",
                                  address: "N Rengstorff Ave Mountain View",
                                  email: "reza@example.com"))
quoteBuilder.addService(service: DataProvider.instance.getService(name: "Brake Inspection")!)
quoteBuilder.addService(service: DataProvider.instance.getService(name: "Battery Inspection")!)
quoteBuilder.addService(service: DataProvider.instance.getService(name: "Oil Change")!)
quoteBuilder.setCar(car: "Honda")
quoteBuilder.setMechanic()

var quote = quoteBuilder.result()

quoteBuilder.setCustomer(customer: Customer(name: "Sarah Khosravani",
                                  address: "S Rengstorff Mountain View",
                                  email: "sarah@example.com"))

quoteBuilder.addService(service: DataProvider.instance.getService(name: "Brake Pad Replacement")!)
quoteBuilder.setMechanic(mechanic: DataProvider.instance.getMechanic(name: "Mike Fulton")!)
quoteBuilder.isValid
quoteBuilder.setMechanic(mechanic:  DataProvider.instance.getMechanic(name: "Steve Brimington")!)
quoteBuilder.isValid
quoteBuilder.setMechanic()
quoteBuilder.isValid
quoteBuilder.addService(service: DataProvider.instance.getService(name: "Timing Belt Replacement")!)
quoteBuilder.isValid
quoteBuilder.setMechanic()

quote = quoteBuilder.result()
