import Foundation

class Todo: HashableClass, Codable {
    var name: String
    var parentId: String? // each sub-task has parent id, root task has no parent id.
    var isCompleted: Bool
    var uuid: String?
    var childrens: [Todo]
    
    init(name: String, parentId: String?, isCompleted: Bool, uuid: String, children: [Todo]) {
        self.name = name
        self.parentId = parentId
        self.isCompleted = isCompleted
        self.uuid = uuid
        self.childrens = children
    }
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
