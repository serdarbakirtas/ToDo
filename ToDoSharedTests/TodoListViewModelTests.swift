import XCTest
@testable import ToDo

class TodoListViewModelTests: XCTestCase {
    
    // Mock UserDefaultsContainerProtocol for testing
    class MockUserDefaultsContainer: UserDefaultsContainerProtocol {
        
        var storedTodos: [TodoItem] = []
        
        func set<T: Codable>(_ value: T, for key: EntityType) {
            if let todos = value as? [TodoItem] {
                storedTodos = todos
            }
        }
        
        func set(todo: TodoItem, for key: EntityType) {
            storedTodos.append(todo)
        }
        
        func fetchAll(key: EntityType) -> [TodoItem] {
            return storedTodos
        }
        
        func delete(key: EntityType, item: TodoItem) {
            storedTodos.removeAll { $0.id == item.id }
        }
        
        func update(key: EntityType, item: TodoItem) {
            guard let index = storedTodos.firstIndex(where: { $0.id == item.id }) else {
                return
            }
            storedTodos[index] = item
        }
    }

    var viewModel: TodoListViewModel!
    var mockUserDefaultsContainer: MockUserDefaultsContainer!

    override func setUp() {
        super.setUp()
        mockUserDefaultsContainer = MockUserDefaultsContainer()
        viewModel = TodoListViewModel(subchildArray: [], userDefaultsContainer: mockUserDefaultsContainer)
    }

    override func tearDown() {
        viewModel = nil
        mockUserDefaultsContainer = nil
        super.tearDown()
    }

    func testFetchTasks() {
        // Given
        let todo1 = TodoItem(id: "1", title: "Task 1", isCompleted: false)
        let todo2 = TodoItem(id: "2", title: "Task 2", isCompleted: true)
        mockUserDefaultsContainer.storedTodos = [todo1, todo2]

        // When
        let fetchedTodos = viewModel.fetchTasks()

        // Then
        XCTAssertEqual(fetchedTodos, [todo1, todo2])
    }

    func testDeleteTask() {
        // Given
        let todo1 = TodoItem(id: "1", title: "Task 1", isCompleted: false)
        mockUserDefaultsContainer.storedTodos = [todo1]

        // When
        viewModel.deleteTask(item: todo1)

        // Then
        XCTAssertTrue(mockUserDefaultsContainer.storedTodos.isEmpty)
    }

    func testUpdateTask() {
        // Given
        let todo1 = TodoItem(id: "1", title: "Task 1", isCompleted: false)
        mockUserDefaultsContainer.storedTodos = [todo1]

        // When
        viewModel.updateTask(item: todo1)

        // Then
        XCTAssertEqual(mockUserDefaultsContainer.storedTodos, [todo1])
    }

    func testToggleCompleted() {
        // Given
        let todo1 = TodoItem(id: "1", title: "Task 1", isCompleted: false)
        let todo2 = TodoItem(id: "2", title: "Task 2", isCompleted: true)
        let todo3 = TodoItem(id: "3", title: "Task 3", isCompleted: false, parentId: "1")
        todo1.children = [todo3]
        mockUserDefaultsContainer.storedTodos = [todo1, todo2]

        // When
        viewModel.toggleCompleted(todo: todo3)

        // Then
        // Verify that the completion status is toggled for the given todo
        XCTAssertTrue(todo3.isCompleted)
        // Verify that parent items are updated accordingly
        // Assume that the parent item (todo1) should be completed since all children are completed
        XCTAssertTrue(todo1.isCompleted)
    }

}
