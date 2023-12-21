import Foundation
import UIKit

protocol Coordinator {

    var parentCoordinator: Coordinator? { get set }
    var children: [Coordinator] { get set }
    var navigationController : UINavigationController { get set }
    
    func start()
}

class AppCoordinator : Coordinator {

    var parentCoordinator: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    init(navigationController : UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.isTranslucent = false
    }

    func start() {
        makeTodoListViewController()
    }
    
    func makeTodoListViewController(){
        let todoListViewController = TodoListViewController()
        todoListViewController.viewModel.appCoordinator = self
        navigationController.pushViewController(todoListViewController, animated: true)
    }
    
    func makeCreateTodoViewController(){
        let createTodoViewController = CreateTodoViewController()
//        groceryListViewModel.appCoordinator = self
//        createTodoViewController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(createTodoViewController, animated: true)
//        navigationController.present(createTodoViewController, animated: true)
    }
}
