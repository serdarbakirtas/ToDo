import Foundation

protocol CreateTodoViewModelProtocol {
    func popViewController()
    func readAndSaveTodo(name: String) -> [Todo]
    
    var parentId: String? { get set }
    var appCoordinator : AppCoordinator? { get set }
}

class CreateTodoViewModel: CreateTodoViewModelProtocol {
    
    // Coordinator
    weak var appCoordinator : AppCoordinator?
    var userDefaultsContainer: UserDefaultsContainerProtocol
    
    // Properties
    var parentId: String?
    
    init(
        appCoordinator: AppCoordinator? = nil,
        userDefaultsContainer: UserDefaultsContainerProtocol,
        parentId: String? = nil
    ) {
        self.appCoordinator = appCoordinator
        self.userDefaultsContainer = userDefaultsContainer
        self.parentId = parentId
    }
    
    func popViewController() {
        appCoordinator?.makeTodoListViewControllerWithPop()
    }
}

// MARK: Public functions

extension CreateTodoViewModel {
    
    func readAndSaveTodo(name: String) -> [Todo] {
        
        var todos = userDefaultsContainer.fetchAll(entity: .todoItems)
        
        if (parentId) != nil {
            addSubTodos(todos: todos, name: name)
        } else {
            todos.append(Todo(name: name, parentId: parentId, isCompleted: false, uuid: UUID().uuidString, children: []))
        }
        return todos
    }
    
    func addSubTodos(todos: [Todo], name: String) {
        
        if let parentId = parentId {
            for node in todos {
                if node.uuid == parentId {
                    node.childrens.append(Todo(name: name, parentId: parentId, isCompleted: false, uuid: UUID().uuidString, children: []))
                } else {
                    addSubTodos(todos: node.childrens, name: name)
                }
            }
        }
    }
}
