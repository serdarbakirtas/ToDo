import Foundation
import UIKit

class TodoListView: UIView {
    
    var collectionView: UICollectionView! = nil
    
    init() {
        super.init(frame: .zero)
        
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods

private extension TodoListView {
    
    func configureCollectionView() {
        
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.trailingSwipeActionsConfigurationProvider = {/* [weak self] */indexPath in
//            guard let self else { return nil }
            let addSubtaskActionHandler: UIContextualAction.Handler = { action, view, completion in }
            let deleteActionHandler: UIContextualAction.Handler = { action, view, completion in }
            
            let subtask = UIContextualAction(style: .normal, title: "Add Subtask", handler: addSubtaskActionHandler)
            subtask.backgroundColor = .systemGreen
            let delete = UIContextualAction(style: .normal, title: "Delete", handler: deleteActionHandler)
            delete.backgroundColor = .red
            
            return UISwipeActionsConfiguration(actions: [delete, subtask])
        }
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
