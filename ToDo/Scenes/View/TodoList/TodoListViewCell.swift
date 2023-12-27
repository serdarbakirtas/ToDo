import Foundation
import UIKit

protocol TodoListViewCellDelegate: AnyObject {
    func didCheckbox(todo: Todo, tag: Int)
}

class TodoListViewCell: UICollectionViewListCell {
    
    lazy var todoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var buttonCheckbox: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didCheckbox), for: .touchUpInside)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    // MARK: - Delegates
    
    weak var delegate: TodoListViewCellDelegate?
    
    // MARK: - Properties
    
    let CONSTANT: CGFloat = 8
    var todo: Todo?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.isSelected = false
        contentView.addSubview(todoLabel)
        contentView.addSubview(buttonCheckbox)
        
        NSLayoutConstraint.activate([
            todoLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            todoLabel.heightAnchor.constraint(equalTo: heightAnchor),
            todoLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            todoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -56), // 56 is coming from accessories
            buttonCheckbox.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonCheckbox.heightAnchor.constraint(equalTo: heightAnchor),
            buttonCheckbox.leftAnchor.constraint(equalTo: todoLabel.rightAnchor, constant: -8),
        ])
    }
}

// MARK: - Actions

extension TodoListViewCell {
    
    @objc func didCheckbox(_ sender: UIButton) {
        guard let todo else { return }
        delegate?.didCheckbox(todo: todo, tag: sender.tag)
    }
}
