import UIKit

protocol UserDefaultsContainerProtocol {
    func save(entity: EntityType, todos: [Todo])
    func fetchAll(entity: EntityType) -> [Todo]
    func delete(entity: EntityType, item: Todo)
    func update(entity: EntityType, item: Todo)
}

enum EntityType: String {
    case todoItems = "TodoItems"
}

enum ActionType {
    case delete
    case update
}

struct UserDefaultsContainer: UserDefaultsContainerProtocol {
    
    let userDefaults = UserDefaults.standard
    
    /// Save
    /// - Parameters:
    ///   - todo: Task and Subtask model
    func save(entity: EntityType, todos: [Todo]) {
        do {
            let encodedData = try JSONEncoder().encode(todos)
            userDefaults.set(encodedData, forKey: entity.rawValue)
        }  catch {}
    }

    /// Fetch
    /// - Parameters:
    ///   - entity: Data model entities
    func fetchAll(entity: EntityType) -> [Todo] {
        if let savedData = userDefaults.object(forKey: entity.rawValue) as? Data {
            do {
                let savedContacts = try JSONDecoder().decode([Todo].self, from: savedData)
                return savedContacts
            } catch {}
        }
        return []
    }
    
    /// Delete
    /// - Parameters:
    ///   - entity: Data model entities
    ///   - id: the identity of the datan deleted from the todo model
    func delete(entity: EntityType, item: Todo) {
        let data = fetchAll(entity: .todoItems)
        findAndRemoveOrUpdateTodos(todos: data, todo: item, actionType: .delete)
    }
    
    /// Delete
    /// - Parameters:
    ///   - entity: Data model entities
    ///   - id: the identity of the datan deleted from the todo model
    func update(entity: EntityType, item: Todo) {
        let data = fetchAll(entity: .todoItems)
        findAndRemoveOrUpdateTodos(todos: data, todo: item, actionType: .update)
    }
}

// MARK: - Private function

private extension UserDefaultsContainer {
    
    func findAndRemoveOrUpdateTodos(todos: [Todo], todo: Todo, actionType: ActionType) {
        var todos = todos
        todos.enumerated().forEach { (index, subTodo) in
            if subTodo.uuid == todo.uuid {  // root todo finded
                switch actionType {
                case .delete:
                    todos.remove(at: index)
                case .update:
                    todos[index].isCompleted.toggle()
                }
            } else {
                subTodo.childrens.enumerated().forEach { (index, subChild) in
                    if subChild.uuid == todo.uuid {  // child todo finded
                        switch actionType {
                        case .delete:
                            subTodo.childrens.remove(at: index)
                        case .update:
                            subTodo.childrens[index].isCompleted.toggle()
                        }
                        
                    } else {
                        findAndRemoveOrUpdateTodos(todos: subChild.childrens, todo: todo, actionType: actionType)
                    }
                }
            }
        }
        save(entity: .todoItems, todos: todos)
    }
}
