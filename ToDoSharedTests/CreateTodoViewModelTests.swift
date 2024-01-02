import XCTest
@testable import ToDo

class CreateTodoViewModelTests: XCTestCase {

    class MockUserDefaultsContainer: UserDefaultsContainerProtocol {
        var storedTodos: [TodoItem] = []

        func set<T>(_ value: T, for key: EntityType) where T: Decodable, T: Encodable {
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

    var viewModel: CreateTodoViewModel!
    var mockUserDefaultsContainer: MockUserDefaultsContainer!

    override func setUp() {
        super.setUp()
        mockUserDefaultsContainer = MockUserDefaultsContainer()
        viewModel = CreateTodoViewModel(userDefaultsContainer: mockUserDefaultsContainer, todo: nil)
    }

    override func tearDown() {
        viewModel = nil
        mockUserDefaultsContainer = nil
        super.tearDown()
    }

    func testUpdateTodo() {
        // Given
        let todoToUpdate = TodoItem(id: "1", title: "Task1", isCompleted: false)
        let initialTodos = [todoToUpdate]
        mockUserDefaultsContainer.storedTodos = initialTodos

        // When
        viewModel.todo = todoToUpdate
        viewModel.update(name: "UpdatedTask")

        // Then
        let updatedTodos = mockUserDefaultsContainer.fetchAll(key: .todoItems)
        XCTAssertEqual(updatedTodos.count, 1)
        XCTAssertEqual(updatedTodos[0].name, "UpdatedTask")
    }

    func testReadAndSaveTodo() {
        // Given
        let todo1 = TodoItem(id: "1", title: "Task 1", isCompleted: false)
        let todo2 = TodoItem(id: "2", title: "Task 2", isCompleted: true)
        mockUserDefaultsContainer.storedTodos = [todo1, todo2]

        // When
        viewModel.readAndSaveTodo(name: "New Task")

        // Then
        let savedTodos = mockUserDefaultsContainer.fetchAll(key: .todoItems)
        XCTAssertEqual(savedTodos.count, 3)
        XCTAssertTrue(savedTodos.contains { $0.name == "New Task" })
    }
}
