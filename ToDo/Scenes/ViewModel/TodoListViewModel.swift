import Foundation
import UIKit

protocol TodoListViewModelProtocol {
    func fetchTask() -> [Todo]
    func deleteTask(item: Todo)
    func updateTask(item: Todo)
    func makeCreateTodoViewController(parentId: String?)
    
    var appCoordinator : AppCoordinator? { get set }
}

class TodoListViewModel: TodoListViewModelProtocol {
    
    // Coordinator
    weak var appCoordinator : AppCoordinator?
    
    var subchildArray: [Todo]
    var userDefaultsContainer: UserDefaultsContainerProtocol
    
    init(
        appCoordinator: AppCoordinator? = nil,
        subchildArray: [Todo],
        userDefaultsContainer: UserDefaultsContainerProtocol
    ) {
        self.appCoordinator = appCoordinator
        self.subchildArray = subchildArray
        self.userDefaultsContainer = userDefaultsContainer
    }
}

// MARK: - Public functions

extension TodoListViewModel {
    
    func fetchTask() -> [Todo] {
        return userDefaultsContainer.fetchAll(key: .todoItems)
    }
    
    func deleteTask(item: Todo) {
        userDefaultsContainer.delete(key: .todoItems, item: item)
    }
    
    func updateTask(item: Todo) {
        userDefaultsContainer.update(key: .todoItems, item: item)
    }
    
    func makeCreateTodoViewController(parentId: String?) {
        appCoordinator?.makeCreateTodoViewController(parentId: parentId)
    }
}
