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
}
