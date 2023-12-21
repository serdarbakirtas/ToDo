import Foundation

class TodoListViewModel {
    
    // Coordinator
    weak var appCoordinator : AppCoordinator?
    
    func makeCheckoutViewController(){
        appCoordinator?.makeCreateTodoViewController()
    }
}

