import Foundation
import UIKit

class CreateTodoViewController: UIViewController {
    
    // UI
    private lazy var contentView = CreateTodoView()
    
    // Properties
    let barButtonItem = RightBarButtonItem(with: "Save")
    
    // View model
    var viewModel: CreateTodoViewModelProtocol = CreateTodoViewModel(userDefaultsContainer: UserDefaultsContainer())
    var userDefaultsContainer: UserDefaultsContainerProtocol = UserDefaultsContainer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = barButtonItem

        barButtonItem.isEnabled = false
        barButtonItem.updateTitleColor(false)
        contentView.textFieldEditing = { [weak self] editing in
            self?.barButtonItem.isEnabled = editing
            self?.barButtonItem.updateTitleColor(editing)
        }
        
        barButtonItem.tapAction = { [weak self] in
            guard let self, let name = self.contentView.taskInputField.text else { return }
            userDefaultsContainer.save(entity: .todoItems, todos: viewModel.readAndSaveTodo(name: name))
            self.viewModel.popViewController()
        }
        
        view = contentView
    }
}
