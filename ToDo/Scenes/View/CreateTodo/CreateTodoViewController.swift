import Foundation
import UIKit

class CreateTodoViewController: UIViewController {
    
    // UI
    private lazy var contentView = CreateTodoView()
    
    // Properties
    let barButtonItem = RightBarButtonItem(with: "Save")
    
    // View model
    var viewModel: CreateTodoViewModelProtocol
    let isEditable: Bool
    
    init(
        viewModel: CreateTodoViewModelProtocol,
        isEditable: Bool
    ) {
        self.viewModel = viewModel
        self.isEditable = isEditable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = barButtonItem

        barButtonItem.isEnabled = false
        barButtonItem.updateTitleColor(false)
        contentView.taskInputField.text = isEditable ? viewModel.todo?.name : ""
        
        contentView.textFieldEditing = { [weak self] editing in
            self?.barButtonItem.isEnabled = editing
            self?.barButtonItem.updateTitleColor(editing)
        }
        
        barButtonItem.tapAction = { [weak self] in
            guard let self, let name = self.contentView.taskInputField.text else { return }
            if isEditable {
                self.viewModel.update(name: name)
            } else {
                self.viewModel.readAndSaveTodo(name: name)
            }
            self.viewModel.popViewController()
        }
        
        view = contentView
    }
}
