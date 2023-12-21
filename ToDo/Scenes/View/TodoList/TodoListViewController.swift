import UIKit

class TodoListViewController: UIViewController {

    // UI
    private lazy var contentView = TodoListView()
   
    // Properties
    let barButtonItem = RightBarButtonItem(with: "Add")

    // View model
    let viewModel = TodoListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        barButtonItem.tapAction = {
            self.makeCreateTodoViewController()
        }
        
        view = contentView
    }
    
    func makeCreateTodoViewController() {
        
        viewModel.makeCheckoutViewController()
    }
}
