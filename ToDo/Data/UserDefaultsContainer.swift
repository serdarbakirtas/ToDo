import UIKit

protocol UserDefaultsContainerProtocol {
    func save(entity: EntityType, todos: [Todo])
    func fetchAll(entity: EntityType) -> [Todo]
    func delete(entity: EntityType, item: Todo)
}

enum EntityType: String {
    case todoItems = "TodoItems"
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
        findTodo(todos: data, todo: item)
    }
}

// MARK: - Private function

private extension UserDefaultsContainer {
    
    func findTodo(todos: [Todo], todo: Todo) {
        var todos = todos
        todos.enumerated().forEach { (index, subTodo) in
            if subTodo.uuid == todo.uuid {
                todos.remove(at: index) // root todo finded
            } else {
                subTodo.childrens.enumerated().forEach { (index, subChild) in
                    if subChild.uuid == todo.uuid {
                        subTodo.childrens.remove(at: index) // child todo finded
                    } else {
                        findTodo(todos: subChild.childrens, todo: todo)
                    }
                }
            }
        }
        save(entity: .todoItems, todos: todos)
    }
}
