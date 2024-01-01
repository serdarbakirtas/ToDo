import Foundation
import UIKit

class TodoListView: UIView {
    
    var collectionView: UICollectionView! = nil
    
    // Closures
    var deleteHandler: ((IndexPath) -> Void)?
    var addHandler: ((IndexPath) -> Void)?
    var editHandler: ((IndexPath) -> Void)?
    
    init() {
        super.init(frame: .zero)
        
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private functions

private extension TodoListView {
    
    func configureCollectionView() {
        
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil }
            
            let addSubtaskActionHandler: UIContextualAction.Handler = { action, view, completion in
                if let action = self.addHandler {
                    action(indexPath)
                }
                
            }
            
            let deleteActionHandler: UIContextualAction.Handler = { action, view, completion in
                if let action = self.deleteHandler {
                    action(indexPath)
                }
            }
            
            let subtask = UIContextualAction(style: .normal, title: "Add Subtask", handler: addSubtaskActionHandler)
            subtask.backgroundColor = .systemGreen
            let delete = UIContextualAction(style: .normal, title: "Delete", handler: deleteActionHandler)
            delete.backgroundColor = .red
            
            return UISwipeActionsConfiguration(actions: [delete, subtask])
        }
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.tintColor = .black
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

// MARK: - UICollectionViewDelegate

extension TodoListView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let action = editHandler {
            action(indexPath)
        }
    }
}
