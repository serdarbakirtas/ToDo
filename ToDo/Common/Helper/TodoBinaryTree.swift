import Foundation

class TodoBinaryTree {
    
    static let shared = TodoBinaryTree()
    
    /// Delete
    /// - Parameters:
    ///   - root: To-do list from userdefaults
    ///   - key: selected todo item
    func delete(_ root: [Todo], _ key: Todo) -> [Todo] {
        var root = root
        root.enumerated().forEach { (index, node) in
            if node.uuid == key.uuid {
                root.remove(at: index)
            } else {
                node.childrens.enumerated().forEach { (index, children) in
                    if children.uuid == key.uuid {
                        node.childrens.remove(at: index)
                    } else {
                        _ = delete(node.childrens, key)
                    }
                }
            }
        }
        return root
    }
    
    /// Update
    /// - Parameters:
    ///   - root: To-do list from userdefaults
    ///   - key: selected todo item
    func update(_ root: [Todo], _ key: Todo) -> [Todo] {
        var root = root
        root.enumerated().forEach { (index, node) in
            if node.uuid == key.uuid {
                root[index] = key
            } else {
                node.childrens.enumerated().forEach { (index, children) in
                    if children.uuid == key.uuid {
                        node.childrens[index] = key
                    } else {
                        _ = update(node.childrens, key)
                    }
                }
            }
        }
        return root
    }
}
