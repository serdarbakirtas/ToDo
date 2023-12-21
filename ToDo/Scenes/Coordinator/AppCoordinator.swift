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
        makeViewController()
    }
    
    func makeViewController(){

        let viewController = ViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}
