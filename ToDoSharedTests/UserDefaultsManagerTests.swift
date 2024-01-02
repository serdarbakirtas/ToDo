import XCTest
@testable import ToDo

class UserDefaultsManagerTests: XCTestCase {

    class MockTodoTreeManager: TodoTreeManagerProtocol {
        func delete(_ root: [ToDo.TodoItem], _ key: ToDo.TodoItem) -> [ToDo.TodoItem] {
            var modifiedRoot = root
            modifiedRoot.removeAll { $0.id == key.id }
            return modifiedRoot
        }

        func update(_ root: [ToDo.TodoItem], _ key: ToDo.TodoItem) -> [ToDo.TodoItem] {
            var modifiedRoot = root
            if let index = modifiedRoot.firstIndex(where: { $0.id == key.id }) {
                modifiedRoot[index] = key
            }
            return modifiedRoot
        }
    }

    var userDefaultsManager: UserDefaultsManager!
    var mockTodoTreeManager: MockTodoTreeManager!

    override func setUp() {
        super.setUp()
        mockTodoTreeManager = MockTodoTreeManager()
        userDefaultsManager = UserDefaultsManager(todoTreeManager: mockTodoTreeManager)
    }

    override func tearDown() {
        userDefaultsManager = nil
        mockTodoTreeManager = nil
        super.tearDown()
    }

    func testDeleteTodo() {
        // Given
        let todoItem = TodoItem(id: "1", title: "Test Todo", isCompleted: false)
        let entityType = EntityType.todoItems
        userDefaultsManager.set(todo: todoItem, for: entityType)

        // When
        userDefaultsManager.delete(key: entityType, item: todoItem)

        // Then
        let savedTodos = userDefaultsManager.fetchAll(key: entityType)
        XCTAssertFalse(savedTodos.contains { $0.id == todoItem.id })
    }
    
    func testUpdate() {
        // Given
        let todoToUpdate = TodoItem(id: "1", title: "Test1 Todo", isCompleted: false)
        let initialTodos = [TodoItem(id: "2", title: "Test2 Todo", isCompleted: false)]

        // When
        userDefaultsManager.set(initialTodos, for: .todoItems)
        userDefaultsManager.update(key: .todoItems, item: todoToUpdate)

        // Then
        let updatedTodos = userDefaultsManager.fetchAll(key: .todoItems)
        
        XCTAssertEqual(updatedTodos.count, initialTodos.count)
        XCTAssertEqual(updatedTodos.first?.name, "Test2 Todo")
        XCTAssertFalse(updatedTodos.first?.isCompleted ?? true)
    }
}
