//
//  Store.swift
//

import Foundation

// 定义协议
protocol ActionType {}
protocol StateType {}
protocol CommandType {}

/// 存储状态和响应 Action
/// 这个 Store 接受一个 reducer 和一个初始状态 initialState 作为输入。它提供了 dispatch 方法，持有该 store 的类型可以通过 dispatch 向其发送 Action，store 将根据 reducer 提供的方式生成新的 state 和必要的 command，然后通知它的订阅者。
class Store<A: ActionType, S: StateType, C: CommandType> {
    let reducer: (_ state: S, _ action: A) -> (S, C?)
    var subscriber: ((_ state: S, _ previousState: S, _ command: C?) -> Void)?
    var state: S
    
    init(reducer: @escaping (S, A) -> (S, C?), initialState: S) {
        self.reducer = reducer
        self.state = initialState
    }
    
    
    /// 订阅者
    ///
    /// - Parameter handler: 闭包
    func subscribe(_ handler: @escaping (S, S, C?) -> Void) {
        self.subscriber = handler
    }
    
    func unsubscribe() {
        self.subscriber = nil
    }
    
    /// 调度者
    /// 操作MODEL和VIEW
    /// - Parameter action: 用户操作
    func dispatch(_ action: A) {
        let previousState = state
        let (nextState, command) = reducer(state, action)
        state = nextState
        subscriber?(state, previousState, command)
    }
}

