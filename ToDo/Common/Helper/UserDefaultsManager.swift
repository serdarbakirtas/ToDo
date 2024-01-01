import UIKit

// MARK: - UserDefaultsContainerProtocol

protocol UserDefaultsContainerProtocol {
    func set<T: Codable>(_ value: T, for key: EntityType)
    func set(todo: TodoItem, for key: EntityType)
    func fetchAll(key: EntityType) -> [TodoItem]
    func delete(key: EntityType, item: TodoItem)
    func update(key: EntityType, item: TodoItem)
}

// MARK: - EntityType

enum EntityType: String {
    case todoItems = "TodoItems"
}

// MARK: - UserDefaultsManager

struct UserDefaultsManager: UserDefaultsContainerProtocol {
    let defaults = UserDefaults.standard
    let todoTreeManager: TodoTreeManagerProtocol

    init(todoTreeManager: TodoTreeManagerProtocol) {
        self.todoTreeManager = todoTreeManager
    }

    func set(todo: TodoItem, for key: EntityType) {
        let todos = fetchAll(key: .todoItems)
        let updatedTodos = todoTreeManager.update(todos, todo)

        set(updatedTodos, for: key)
    }

    func set(_ value: some Codable, for key: EntityType) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(value)
            set(value: encoded, for: key.rawValue)
        } catch {
            fatalError("Can't encode data: \(error)")
        }
    }
}

// MARK: - Private function

private extension UserDefaultsManager {
    func set(value: Any?, for key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
}

// MARK: Todos related

extension UserDefaultsManager {
    func fetchAll(key: EntityType) -> [TodoItem] {
        if let savedData = defaults.object(forKey: key.rawValue) as? Data {
            do {
                let savedTodos = try JSONDecoder().decode([TodoItem].self, from: savedData)
                return savedTodos
            } catch {
                print("Error decoding data: \(error)")
                return []
            }
        }
        return []
    }

    func delete(key: EntityType, item: TodoItem) {
        let data = fetchAll(key: key)
        let todolist = todoTreeManager.delete(data, item)
        set(todolist, for: key)
    }

    func update(key: EntityType, item: TodoItem) {
        let data = fetchAll(key: key)
        let todolist = todoTreeManager.update(data, item)
        set(todolist, for: key)
    }
}
