import Foundation

class TodoItem: HashableClass, Codable {
    var id: String
    var name: String
    var isCompleted: Bool
    var children: [TodoItem] = []
    var parentId: String?

    init(id: String, title: String, isCompleted: Bool = false, parentId: String? = nil) {
        self.id = id
        self.name = title
        self.isCompleted = isCompleted
        self.parentId = parentId
    }
    
    static var items = UserDefaultsManager(todoTreeManager: TodoTreeManager()).fetchAll(key: .todoItems)
}

open class HashableClass {
    public init() {}
}

// MARK: - <Hashable>

extension HashableClass: Hashable {

    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self))
    }
}

// MARK: - <Equatable>

extension HashableClass: Equatable {

    public static func ==(lhs: HashableClass, rhs: HashableClass) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

// MARK: - Public methods

extension TodoItem {
    
    func addChild(title: String, parentId: String) {
        let childItem = TodoItem(id: UUID().uuidString, title: title, parentId: parentId)
        children.append(childItem)
    }

    func toggleCompleted() {
        isCompleted.toggle()
        
        UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: self)
        completeChildren(self.children, isCompleted)
        isCompleted ? completeParentIfNeeded() : unselectParentIfNeeded()
    }
}

// MARK: - Private methods

private extension TodoItem {
    
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
            UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: child)
            completeChildren(child.children, isComplete)
        }
    }

    func unselectParentIfNeeded() {
        guard let parentId = parentId else {
            return
        }

        if let parentItem = findItem(withId: parentId, in: UserDefaultsManager(todoTreeManager: TodoTreeManager()).fetchAll(key: .todoItems)) {
            let anySiblingSelected = parentItem.children.contains { $0.isCompleted }

            if !anySiblingSelected {
                parentItem.isCompleted = false
                UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: parentItem)
                parentItem.unselectParentIfNeeded()
            }
        }
    }

    func completeParentIfNeeded() {
        guard let parentId = parentId else {
            return
        }

        if let parentItem = findItem(withId: parentId, in: UserDefaultsManager(todoTreeManager: TodoTreeManager()).fetchAll(key: .todoItems)) {
            let allSiblingsCompleted = parentItem.children.allSatisfy { $0.isCompleted }
            if allSiblingsCompleted {
                parentItem.isCompleted = true
                UserDefaultsManager(todoTreeManager: TodoTreeManager()).update(key: .todoItems, item: parentItem)
                parentItem.completeParentIfNeeded()
            }
        }
    }
}
