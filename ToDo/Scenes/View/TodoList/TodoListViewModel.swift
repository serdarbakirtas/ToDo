import Foundation
import UIKit

protocol TodoListViewModelProtocol {
    func fetchTasks() -> [TodoItem]
    func deleteTask(item: TodoItem)
    func updateTask(item: TodoItem) 
    func makeCreateTodoViewController(todo: TodoItem?, isEditable: Bool)
    func toggleCompleted(todo: TodoItem)
    
    var appCoordinator: AppCoordinator? { get set }
    var userDefaultsContainer: UserDefaultsContainerProtocol { get set }
}

class TodoListViewModel: TodoListViewModelProtocol {
    weak var appCoordinator: AppCoordinator?
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
    func fetchTasks() -> [TodoItem] {
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

// MARK: - Toggle Completion

extension TodoListViewModel {
    func toggleCompleted(todo: TodoItem) {
        todo.isCompleted.toggle()
        
        let todoManager = UserDefaultsManager(todoTreeManager: TodoTreeManager())
        todoManager.update(key: .todoItems, item: todo)
        
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
            postTodoNotification(value: child)
            UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: child)
            completeChildren(child.children, isComplete)
        }
    }
    
    func postTodoNotification(value: TodoItem) {
        NotificationCenter.default.post(name: .todo, object: self, userInfo: ["value": value])
    }
    
    func unselectParentIfNeeded(todo: TodoItem) {
        guard let parentId = todo.parentId, !parentId.isEmpty,
              let parentItem = findItem(withId: parentId, in: fetchTasks()) else {
            return
        }

        let anySiblingSelected = parentItem.children.contains { $0.isCompleted }

        if !anySiblingSelected {
            parentItem.isCompleted = false
            postTodoNotification(value: parentItem)
            UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: parentItem)
            unselectParentIfNeeded(todo: parentItem)
        } else {
            parentItem.isCompleted = parentItem.children.allSatisfy { $0.isCompleted }
            postTodoNotification(value: parentItem)
            UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: parentItem)

            // Propagate unselect action up to the root item
            let rootItem = findRootItem(of: parentItem)
            rootItem.isCompleted = false
            postTodoNotification(value: rootItem)
            UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: rootItem)
        }
    }
    
    // Helper method to find the root item of a given item
    func findRootItem(of item: TodoItem) -> TodoItem {
        var currentItem = item
        while let parentId = currentItem.parentId,
              let parentItem = findItem(withId: parentId, in: fetchTasks()) {
            currentItem = parentItem
        }
        return currentItem
    }

    func completeParentIfNeeded(todo: TodoItem) {
        guard let parentId = todo.parentId, !parentId.isEmpty,
              let parentItem = findItem(withId: parentId, in: fetchTasks()) else {
            return
        }

        let allSiblingsCompleted = parentItem.children.isEmpty || parentItem.children.allSatisfy { $0.isCompleted }
        
        if allSiblingsCompleted {
            parentItem.isCompleted = true
            postTodoNotification(value: parentItem)
            UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: parentItem)
            completeParentIfNeeded(todo: parentItem)
        }
    }
}
