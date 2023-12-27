import UIKit

protocol UserDefaultsContainerProtocol {
    func set<T: Codable>(_ value: T, for key: EntityType)
    func fetchAll(key: EntityType) -> [Todo]
    func delete(key: EntityType, item: Todo)
    func update(key: EntityType, item: Todo)
}

enum EntityType: String {
    case todoItems = "TodoItems"
}

struct UserDefaultsManager: UserDefaultsContainerProtocol {
    
    let defaults = UserDefaults.standard
    
    /// Set
    /// - Parameters:
    ///   - value: Generic parameter, can contain any Codable model
    ///   - Key: entity type (string key)
    func set<T: Codable>(_ value: T, for key: EntityType) {
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
    
    /// Fetch
    /// - Parameters:
    ///   - entity: Data model entities
    func fetchAll(key: EntityType) -> [Todo] {
        if let savedData = defaults.object(forKey: key.rawValue) as? Data {
            do {
                let savedContacts = try JSONDecoder().decode([Todo].self, from: savedData)
                return savedContacts
            } catch {}
        }
        return []
    }
    
    /// Delete
    /// - Parameters:
    ///   - key: Data model entities
    ///   - item: Seleted todo item
    func delete(key: EntityType, item: Todo) {
        let data = fetchAll(key: key)
        let todolist = TodoBinaryTree.shared.delete(data, item)
        set(todolist, for: .todoItems)
    }
    
    /// Update
    /// - Parameters:
    ///   - key: Data model entities
    ///   - id: Seleted todo item
    func update(key: EntityType, item: Todo) {
        let data = fetchAll(key: key)
        let todolist = TodoBinaryTree.shared.update(data, item)
        set(todolist, for: .todoItems)
    }
}
