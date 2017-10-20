//
//  TableViewController.swift
//

/*：
 纯函数式实现UI更新
 纯函数 (Pure Function) 是指一个函数如果有相同的输入，则它产生相同的输出。换言之，也就是一个函数的动作不依赖于外部变量之类的状态，一旦输入给定，那么输出则唯一确定。对于 app 而言，我们总是会和一定的用户输入打交道，也必然会需要按照用户的输入和已知状态来更新 UI 作为“输出”。所以在 app 中，特别是 View Controller 中操作 UI 的部分，我会倾向于将“纯函数”定义为：在确定的输入下，某个函数给出确定的 UI。
 单向数据流：
     新状态 = f(旧状态, 用户行为)
     func reducer(state: State, userAction: Action) -> State
     func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result
 异步状态：
     异步操作对于状态的立即改变 (比如设置 state.loading 并显示一个 Loading Indicator)，我们可以通过向 State 中添加成员来达到。要触发这个异步操作，我们可以为它添加一个新的 Action，相对于普通 Action 仅仅只是改变 state，我们希望它还能有一定“副作用”，也就是在订阅者中能实际触发这个异步操作。这需要我们稍微更新一下 reducer 的定义，除了返回新的 State 以外，我们还希望对异步操作返回一个额外的 Command：
         func reducer(state: State, userAction: Action) -> (State, Command?)
 */

/*:
 无法通过didSet来初始化UI：
 初始状态的 UI 是我们在 Storyboard 或者相应的 viewDidLoad 之类的方法里设定的。这将导致一个问题，那就是我们无法通过设置 state 属性的方式来设置初始 UI。因为 state 的 didSet 不会在 controller 初始化中首次赋值时被调用，因此如果我们在 viewDidLoad 中添加如下语句的话，会因为新的状态和初始相同，而导致 UI 不发生更新。
 在初始 UI 设置正确的情况下，这倒没什么问题。但是如果 UI 状态原本存在不对的话，就将导致接下来的 UI 都是错误的。从更高层次来看，也就是 state 属性对 UI 的控制不仅仅涉及到新的状态，同时也取决于原有的 state 值。这会导致一些额外复杂度，是我们想要避免的。理想状态下，UI 的更新应该只和输入有关，而与当前状态无关。
 */

import UIKit

let inputCellReuseId = "inputCell"
let todoCellResueId = "todoCell"

class TableViewController: UITableViewController {
    
    /// 结构体 - 用于统一处理 UI 相关操作
    struct State: StateType {
        var dataSource = TableViewControllerDataSource(todos: [], owner: nil) // 不传入owner
        var text: String = ""
    }
    
    enum Action: ActionType {
        case updateText(text: String)
        case addToDos(items: [String])
        case removeToDo(index: Int)
        case loadToDos
    }
    
    enum Command: CommandType {
        // 关联了一个方法作为结束时的回调，我们稍后会在这个方法里向 store 发送 .addToDos 的 Action
        case loadToDos(completion: ([String]) -> Void )
        case someOtherCommand
    }
    
    
    /// 函数式 单向数据更新方法
    lazy var reducer: (State, Action) -> (state: State, command: Command?) = {
        [weak self] (state: State, action: Action) in
   
        var state = state
        var command: Command? = nil
        
        switch action {
        case .updateText(let text):
            state.text = text
        case .addToDos(let items):
            state.dataSource = TableViewControllerDataSource(todos: items + state.dataSource.todos, owner: state.dataSource.owner)
        case .removeToDo(let index):
            let oldTodos = state.dataSource.todos
            state.dataSource = TableViewControllerDataSource(todos: Array(oldTodos[..<index] + oldTodos[(index + 1)...]), owner: state.dataSource.owner)
        case .loadToDos:
            command = Command.loadToDos {
                // 发送额外的 .addToDos
                self?.store.dispatch(.addToDos(items: $0))
            }
        }
        return (state, command)
    }
    
    var store: Store<Action, State, Command>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = TableViewControllerDataSource(todos: [], owner: self)
        
        // 1.初始化 Store
        store = Store<Action, State, Command>(reducer: reducer, initialState: State(dataSource: dataSource, text: ""))
        // 2.订阅 store
        store.subscribe { [weak self] state, previousState, command in
            self?.stateDidChanged(state: state, previousState: previousState, command: command)
        }
        // 3.初始化 UI
        stateDidChanged(state: store.state, previousState: nil, command: nil)
        // 4.开始异步加载 ToDos
        store.dispatch(.loadToDos)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /// 函数式 UI更新方法
    /// 它的输出 (UI) 只取决于输入的 state 和 previousState
    /// - Parameters:
    ///   - state: 现状态
    ///   - previousState: 原状态
    ///   - command: 负责触发一些不影响输出的“副作用”，在实践中，除了发送请求这样的异步操作外，View Controller 的转换，弹窗之类的交互都可以通过 Command 来进行。Command 本身不应该影响 State 的转换，它需要通过再次发送 Action 来改变状态，以此才能影响 UI。
    func stateDidChanged(state: State, previousState: State?, command: Command?) {
        
        if let command = command {
            switch command {
            case .loadToDos(let handler):
                ToDoStore.shared.getToDoItems(completionHandler: handler)
            case .someOtherCommand:
                // Placeholder command.
                break
            }
        }
        
        if previousState == nil || previousState!.dataSource.todos != state.dataSource.todos {
            let dataSource = state.dataSource
            tableView.dataSource = dataSource
            tableView.reloadData()
            title = "TODO - (\(dataSource.todos.count))"
        }
        
        if previousState == nil  || previousState!.text != state.text {
            let isItemLengthEnough = state.text.count >= 3
            navigationItem.rightBarButtonItem?.isEnabled = isItemLengthEnough
            
            let inputIndexPath = IndexPath(row: 0, section: TableViewControllerDataSource.Section.input.rawValue)
            let inputCell = tableView.cellForRow(at: inputIndexPath) as? TableViewInputCell
            inputCell?.textField.text = state.text
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == TableViewControllerDataSource.Section.todos.rawValue else { return }
        store.dispatch(.removeToDo(index: indexPath.row))
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        store.dispatch(.addToDos(items: [store.state.text]))
        store.dispatch(.updateText(text: ""))
    }
}

extension TableViewController: TableViewInputCellDelegate {
    /// 代理方法来更新添加按钮
    ///
    /// - Parameters:
    ///   - cell: 输入Cell
    ///   - text: 内容
    func inputChanged(cell: TableViewInputCell, text: String) {
        store.dispatch(.updateText(text: text))
    }
}

