import Foundation
import UIKit

protocol TodoListViewModelProtocol {
    func fetchTask() -> [TodoItem]
    func deleteTask(item: TodoItem)
    func updateTask(item: TodoItem)
    func makeCreateTodoViewController(todo: TodoItem?, isEditable: Bool)
    
    var appCoordinator : AppCoordinator? { get set }
    var userDefaultsContainer: UserDefaultsContainerProtocol { get set }
}

class TodoListViewModel: TodoListViewModelProtocol {
    
    // Coordinator
    weak var appCoordinator : AppCoordinator?
    
    var subchildArray: [TodoItem]
    var userDefaultsContainer: UserDefaultsContainerProtocol
    
    init(
        appCoordinator: AppCoordinator? = nil,
        subchildArray: [TodoItem],
        userDefaultsContainer: UserDefaultsContainerProtocol
    ) {
        self.appCoordinator = appCoordinator
        self.subchildArray = subchildArray
        self.userDefaultsContainer = userDefaultsContainer
    }
}

// MARK: - Public functions

extension TodoListViewModel {
    
    func fetchTask() -> [TodoItem] {
        return userDefaultsContainer.fetchAll(key: .todoItems)
    }
    
    func deleteTask(item: TodoItem) {
        userDefaultsContainer.delete(key: .todoItems, item: item)
    }
    
    func updateTask(item: TodoItem) {
        userDefaultsContainer.update(key: .todoItems, item: item)
    }
    
    func makeCreateTodoViewController(todo: TodoItem?, isEditable: Bool) {
        appCoordinator?.makeCreateTodoViewController(todo: todo, isEditable: isEditable)
    }
}
