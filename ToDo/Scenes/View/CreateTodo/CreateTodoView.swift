import Foundation
import UIKit

class CreateTodoView: UIView {
    
    var textFieldEditing: ((Bool) -> Void)?
    
    lazy var taskInputField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Task name"
        textfield.textColor = .black
        textfield.textAlignment = .left
        textfield.font = UIFont.systemFont(ofSize: 20)
        textfield.adjustsFontSizeToFitWidth = true
        textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textfield
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private methods

private extension CreateTodoView {
    
    func addSubviews() {
        addSubview(taskInputField)
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([
            taskInputField.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            taskInputField.rightAnchor.constraint(equalTo: rightAnchor, constant: 8),
            taskInputField.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
        ])
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let emptyField = textField.text?.isEmpty else { return }
        if let action = textFieldEditing {
            action(!emptyField)
        }
    }
}
