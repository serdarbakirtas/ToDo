import XCTest
@testable import ToDo

class AppCoordinatorTests: XCTestCase {

    class MockNavigationController: UINavigationController {
        var pushedViewController: UIViewController?
        var poppedViewController: UIViewController?

        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            pushedViewController = viewController
            super.pushViewController(viewController, animated: animated)
        }

        override func popViewController(animated: Bool) -> UIViewController? {
            poppedViewController = super.popViewController(animated: animated)
            return poppedViewController
        }
    }

    var appCoordinator: AppCoordinator!
    var mockNavigationController: MockNavigationController!

    override func setUp() {
        super.setUp()
        mockNavigationController = MockNavigationController()
        appCoordinator = AppCoordinator(navigationController: mockNavigationController)
    }

    override func tearDown() {
        appCoordinator = nil
        mockNavigationController = nil
        super.tearDown()
    }

    func testStart() {
        // When
        appCoordinator.start()

        // Then
        XCTAssertTrue(mockNavigationController.pushedViewController is TodoListViewController)
        XCTAssertNotNil((mockNavigationController.pushedViewController as? TodoListViewController)?.viewModel)
        XCTAssertNotNil((mockNavigationController.pushedViewController as? TodoListViewController)?.viewModel.appCoordinator)
    }

    func testMakeTodoListViewController() {
        // When
        appCoordinator.makeTodoListViewController()

        // Then
        XCTAssertTrue(mockNavigationController.pushedViewController is TodoListViewController)
        XCTAssertNotNil((mockNavigationController.pushedViewController as? TodoListViewController)?.viewModel)
        XCTAssertNotNil((mockNavigationController.pushedViewController as? TodoListViewController)?.viewModel.appCoordinator)
    }

    func testMakeCreateTodoViewController() {
        // Given
        let todo = TodoItem(id: "1", title: "Test Todo", isCompleted: false)
        let isEditable = true

        // When
        appCoordinator.makeCreateTodoViewController(todo: todo, isEditable: isEditable)

        // Then
        XCTAssertTrue(mockNavigationController.pushedViewController is CreateTodoViewController)
        XCTAssertNotNil((mockNavigationController.pushedViewController as? CreateTodoViewController)?.viewModel)
        XCTAssertNotNil((mockNavigationController.pushedViewController as? CreateTodoViewController)?.viewModel.appCoordinator)
    }
}
