import Foundation

protocol CreateTodoViewModelProtocol {
    func popViewController()
    func readAndSaveTodo(name: String)
    func update(name: String)
    
    var todo: TodoItem? { get set }
    var appCoordinator : AppCoordinator? { get set }
    var userDefaultsContainer : UserDefaultsContainerProtocol { get set }
}

class CreateTodoViewModel: CreateTodoViewModelProtocol {
    
    // Coordinator
    weak var appCoordinator : AppCoordinator?
    
    // Properties
    var todo: TodoItem?
    var userDefaultsContainer: UserDefaultsContainerProtocol
    let todoTreeManager: TodoTreeManager
    
    init(
        appCoordinator: AppCoordinator? = nil,
        userDefaultsContainer: UserDefaultsContainerProtocol,
        todoTreeManager: TodoTreeManager = TodoTreeManager(),
        todo: TodoItem?
    ) {
        self.appCoordinator = appCoordinator
        self.userDefaultsContainer = userDefaultsContainer
        self.todoTreeManager = todoTreeManager
        self.todo = todo
    }
    
    func popViewController() {
        appCoordinator?.makeTodoListViewControllerWithPop()
    }
}

// MARK: Public functions

extension CreateTodoViewModel {
    
    func update(name: String) {
        let todos = userDefaultsContainer.fetchAll(key: .todoItems)
        todo?.name = name
        guard let todo else { return }
        userDefaultsContainer.set(todoTreeManager.update(todos, todo), for: .todoItems)
    }
    
    func readAndSaveTodo(name: String) {
        
        var todos = userDefaultsContainer.fetchAll(key: .todoItems)
        
        if (todo?.id) != nil {
            addChild(todos: todos, name: name)
        } else {
            todos.append(TodoItem(id: UUID().uuidString, title: name, isCompleted: false, parentId: nil))
        }
        userDefaultsContainer.set(todos, for: .todoItems)
    }
}

// MARK: Private functions

private extension CreateTodoViewModel {
    
    func addChild(todos: [TodoItem], name: String) {
        
        if let parentId = todo?.id {
            for node in todos {
                if node.id == parentId {
                    node.addChild(title: name, parentId: parentId)
                } else {
                    addChild(todos: node.children, name: name)
                }
            }
        }
    }
}
