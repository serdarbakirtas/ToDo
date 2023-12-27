import Foundation

protocol CreateTodoViewModelProtocol {
    func popViewController()
    func readAndSaveTodo(name: String)
    func update(name: String)
    
    var todo: Todo? { get set }
    var appCoordinator : AppCoordinator? { get set }
    var userDefaultsContainer : UserDefaultsContainerProtocol { get set }
}

class CreateTodoViewModel: CreateTodoViewModelProtocol {
    
    // Coordinator
    weak var appCoordinator : AppCoordinator?
    var userDefaultsContainer: UserDefaultsContainerProtocol
    
    // Properties
    var todo: Todo?
    
    init(
        appCoordinator: AppCoordinator? = nil,
        userDefaultsContainer: UserDefaultsContainerProtocol,
        todo: Todo?
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
        userDefaultsContainer.set(TodoBinaryTree.shared.update(todos, todo), for: .todoItems)
    }
    
    func readAndSaveTodo(name: String) {
        
        var todos = userDefaultsContainer.fetchAll(key: .todoItems)
        
        if (todo?.uuid) != nil {
            addChild(todos: todos, name: name)
        } else {
            todos.append(Todo(name: name, parentId: todo?.uuid, isCompleted: false, uuid: UUID().uuidString, children: []))
        }
        userDefaultsContainer.set(todos, for: .todoItems)
    }
}

// MARK: Private functions

private extension CreateTodoViewModel {
    
    func addChild(todos: [Todo], name: String) {
        
        if let parentId = todo?.uuid {
            for node in todos {
                if node.uuid == parentId {
                    node.childrens.append(Todo(name: name, parentId: parentId, isCompleted: false, uuid: UUID().uuidString, children: []))
                } else {
                    addChild(todos: node.childrens, name: name)
                }
            }
        }
    }
}
