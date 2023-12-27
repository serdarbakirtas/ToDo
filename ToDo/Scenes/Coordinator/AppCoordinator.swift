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
        let viewModel = TodoListViewModel(subchildArray: [Todo](), userDefaultsContainer: UserDefaultsManager())
        let todoListViewController = TodoListViewController(viewModel: viewModel, userDefaultsContainer: UserDefaultsManager())
        todoListViewController.viewModel.appCoordinator = self
        navigationController.pushViewController(todoListViewController, animated: true)
    }
    
    func makeCreateTodoViewController(parentId: String? = nil){
        let createTodoViewController = CreateTodoViewController()
        createTodoViewController.viewModel.appCoordinator = self
        createTodoViewController.viewModel.parentId = parentId
        navigationController.pushViewController(createTodoViewController, animated: true)
    }
    
    func makeTodoListViewControllerWithPop(){
        navigationController.popViewController(animated: true)
    }
}
