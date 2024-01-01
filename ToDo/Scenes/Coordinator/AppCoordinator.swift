import Foundation
import UIKit

protocol AppCoordinatorProtocol {
    var parentCoordinator: AppCoordinatorProtocol? { get set }
    var children: [AppCoordinatorProtocol] { get set }
    var navigationController : UINavigationController { get set }
    
    func start()
}

class AppCoordinator: AppCoordinatorProtocol {

    var parentCoordinator: AppCoordinatorProtocol?
    var children: [AppCoordinatorProtocol] = []
    var navigationController: UINavigationController

    init(navigationController : UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.isTranslucent = false
    }

    func start() {
        makeTodoListViewController()
    }
    
    func makeTodoListViewController(){
        let todoTreeManager = TodoTreeManager()
        let userDefaultsManager = UserDefaultsManager(todoTreeManager: todoTreeManager)
        
        let viewModel = TodoListViewModel(
            subchildArray: [TodoItem](),
            userDefaultsContainer: userDefaultsManager
        )
        
        let todoListViewController = TodoListViewController(viewModel: viewModel)
        todoListViewController.viewModel.appCoordinator = self
        navigationController.pushViewController(todoListViewController, animated: true)
    }
    
    func makeCreateTodoViewController(todo: TodoItem?, isEditable: Bool) {
        let todoTreeManager = TodoTreeManager()
        let userDefaultsManager = UserDefaultsManager(todoTreeManager: todoTreeManager)
        
        let viewModel = CreateTodoViewModel(
            userDefaultsContainer: userDefaultsManager,
            todo: todo
        )
        
        let createTodoViewController = CreateTodoViewController(viewModel: viewModel, isEditable: isEditable)
        createTodoViewController.viewModel.appCoordinator = self
        navigationController.pushViewController(createTodoViewController, animated: true)
    }
    
    func makeTodoListViewControllerWithPop(){
        navigationController.popViewController(animated: true)
    }
}
