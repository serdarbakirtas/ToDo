import Foundation
import UIKit

protocol TodoListViewModelProtocol {
    func fetchTask() -> [Todo]
    func deleteTask(item: Todo)
    func makeCreateTodoViewController(parentId: String?)
    
    var appCoordinator : AppCoordinator? { get set }
}

class TodoListViewModel: TodoListViewModelProtocol {
    
    // Coordinator
    weak var appCoordinator : AppCoordinator?
    
    var subchildArray: [Todo]
    var userDefaultsContainer: UserDefaultsContainerProtocol

    let userDefaults = UserDefaults.standard
    
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

// MARK: - Public methods

extension TodoListViewModel {
    
    func fetchTask() -> [Todo] {
        return userDefaultsContainer.fetchAll(entity: .todoItems)
    }
    
    func deleteTask(item: Todo) {
        userDefaultsContainer.delete(entity: .todoItems, item: item)
    }
    
    func makeCreateTodoViewController(parentId: String?) {
        appCoordinator?.makeCreateTodoViewController(parentId: parentId)
    }
}
