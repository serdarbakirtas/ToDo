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
    var userDefaultsContainer: UserDefaultsContainerProtocol
    
    // Properties
    var todo: TodoItem?
    
    init(
        appCoordinator: AppCoordinator? = nil,
        userDefaultsContainer: UserDefaultsContainerProtocol,
        todo: TodoItem?
    ) {
        self.appCoordinator = appCoordinator
        self.userDefaultsContainer = userDefaultsContainer
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
        userDefaultsContainer.set(TodoTreeManager().update(todos, todo), for: .todoItems)
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
