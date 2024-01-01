import Foundation

// MARK: - TodoTreeManagerProtocol

protocol TodoTreeManagerProtocol {
    func delete(_ root: [TodoItem], _ key: TodoItem) -> [TodoItem]
    func update(_ root: [TodoItem], _ key: TodoItem) -> [TodoItem]
}

// MARK: - TodoTreeManager

class TodoTreeManager: TodoTreeManagerProtocol {
    /// Deletes a todo item from the tree
    /// - Parameters:
    ///   - root: Root nodes of the to-do list
    ///   - key: Todo item to delete
    /// - Returns: Updated list of root nodes
    func delete(_ root: [TodoItem], _ key: TodoItem) -> [TodoItem] {
        var updatedRoot = root.filter { $0.id != key.id }
        updatedRoot = updatedRoot.map { node -> TodoItem in
            let newNode = node
            newNode.children = delete(node.children, key)
            return newNode
        }
        return updatedRoot
    }

    /// Adds a todo item to the tree
    /// - Parameters:
    ///   - root: Root nodes of the to-do list
    ///   - key: Todo item to add
    /// - Returns: Updated list of root nodes
    func add(_ root: [TodoItem], _ key: TodoItem) -> [TodoItem] {
        var updatedRoot = root
        var added = false
        updatedRoot = updatedRoot.map { node -> TodoItem in
            let newNode = node
            if newNode.id == key.id {
                newNode.children.append(key)
                added = true
            } else {
                newNode.children = add(node.children, key)
            }
            return newNode
        }
        if !added {
            updatedRoot.append(key)
        }
        return updatedRoot
    }

    /// Updates a todo item in the tree
    /// - Parameters:
    ///   - root: Root nodes of the to-do list
    ///   - key: Todo item to update
    /// - Returns: Updated list of root nodes
    func update(_ root: [TodoItem], _ key: TodoItem) -> [TodoItem] {
        let updatedRoot = root.map { node -> TodoItem in
            var newNode = node
            if newNode.id == key.id {
                newNode = key
            } else {
                newNode.children = update(node.children, key)
            }
            return newNode
        }
        return updatedRoot
    }
}
