import Foundation
import UIKit

protocol TodoListViewModelProtocol {
    func fetchTask() -> [TodoItem]
    func deleteTask(item: TodoItem)
    func updateTask(item: TodoItem)
    func makeCreateTodoViewController(todo: TodoItem?, isEditable: Bool)
    func toggleCompleted(todo: TodoItem)
    
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

extension TodoListViewModel {

    func toggleCompleted(todo: TodoItem) {
        todo.isCompleted.toggle()
        
        UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: todo)
        completeChildren(todo.children, todo.isCompleted)
        todo.isCompleted ? completeParentIfNeeded(todo: todo) : unselectParentIfNeeded(todo: todo)
    }
}

// MARK: - Private methods

private extension TodoListViewModel {
    
    func findItem(withId itemId: String, in items: [TodoItem]) -> TodoItem? {
        for item in items {
            if item.id == itemId {
                return item
            }
            if let foundItem = findItem(withId: itemId, in: item.children) {
                return foundItem
            }
        }
        return nil
    }
    
    func completeChildren(_ todo: [TodoItem], _ isComplete: Bool) {
        for child in todo {
            child.isCompleted = isComplete
            NotificationCenter.default.post(name: .todo, object: self, userInfo: ["value": child])
            UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: child)
            completeChildren(child.children, isComplete)
        }
    }

    func unselectParentIfNeeded(todo: TodoItem) {
        guard let parentId = todo.parentId else {
            return
        }

        if let parentItem = findItem(withId: parentId, in: UserDefaultsManager(todoTreeManager: TodoTreeManager()).fetchAll(key: .todoItems)) {
            let anySiblingSelected = parentItem.children.contains { $0.isCompleted }

            if !anySiblingSelected {
                parentItem.isCompleted = false
                
                NotificationCenter.default.post(name: .todo, object: self, userInfo: ["value": parentItem])
                UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: parentItem)
                unselectParentIfNeeded(todo: parentItem)
            }
        }
    }

    func completeParentIfNeeded(todo: TodoItem) {
        guard let parentId = todo.parentId else {
            return
        }

        if let parentItem = findItem(withId: parentId, in: UserDefaultsManager(todoTreeManager: TodoTreeManager()).fetchAll(key: .todoItems)) {
            let allSiblingsCompleted = parentItem.children.allSatisfy { $0.isCompleted }
            if allSiblingsCompleted {
                parentItem.isCompleted = true
                NotificationCenter.default.post(name: .todo, object: self, userInfo: ["value": parentItem])

                UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: parentItem)
                completeParentIfNeeded(todo: parentItem)
            }
        }
    }
}
