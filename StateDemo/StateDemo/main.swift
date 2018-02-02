//
//  main.swift
//  StateDemo
//
//  Created by 王侃 on 2018/2/1.
//  Copyright © 2018年 王侃. All rights reserved.
//

import Foundation


// John Lee request a quote. A context is created.我们从John Lee提交报价开始。我们从创建我们的上下文开始。我们的上下文的初始状态自动设置为SubmittedQuote。然后我们在我们的上下文中调用我们的getMessageToCustomer函数，该函数返回我们在首次提交报价时发送给客户的消息。
var context = Context()

// Inform the customer
print(context.getMessageToCustomer())

// Quote goes to pending because we are missing some information about the quote
context.changeStateToPending()

// Inform the customer
print(context.getMessageToCustomer())

// Our talented customer service team figures out what's missing and turns the quote into ready.
var price = 66.25
context.changeStateToReady(price: price)

// Inform the customer
print(context.getMessageToCustomer())

// Log the price
print(context.getPrice()!)

// Try to get the receipt for the quote
var attemptedReceipt = context.getReceipt()

// The customer is amazed by our low prices and decides to
// book an appointment with our top mechanic Joe Murphy
var joe = Mechanic(name: "Joe Murphy")
context.changeStateToBooked(price: price, mechanic: joe)

// Inform the customer
print(context.getMessageToCustomer())

// Another successfull appointment. We create a receipt and give it to the customer
var receipt = Receipt(delivered: true, total: price, customerName: "John Lee")
context.changeStateToCompleted(price: price, mechanic: joe, receipt: receipt)

// Inform the customer
print(context.getMessageToCustomer())
