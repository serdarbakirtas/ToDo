import UIKit

class TodoListViewController: UIViewController {

    // UI
    private lazy var contentView = TodoListView()
    private var dataSource: UICollectionViewDiffableDataSource<Int, Todo>! = nil
    
    // Properties
    let barButtonItem = RightBarButtonItem(with: "Add")

    // View model
    let viewModel = TodoListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = barButtonItem
        setUI()
        
        view = contentView
        
        configureDataSource()
        createSnapshot()
    }
}

//MARK: - Public methods

extension TodoListViewController {
    
    // Go to the detail page for creating a new task
    func makeCreateTodoViewController() {
        viewModel.makeCheckoutViewController()
    }
    
    //MARK: - Data Source
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Todo> { (cell, indexPath, node) in
            var content = cell.defaultContentConfiguration()
            content.text = node.name
            cell.contentConfiguration = content
            
            cell.accessories = node.children.isEmpty ? [] : [.outlineDisclosure()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Todo>(collectionView: contentView.collectionView) { 
            (collectionView, indexPath, node) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: node)
        }
    }
}

// MARK: Private methods

private extension TodoListViewController {
    
    func setUI() {
        barButtonItem.tapAction = { [weak self] in
            self?.makeCreateTodoViewController()
        }
    }
    
    func createSnapshot() {
        var snapshot = NSDiffableDataSourceSectionSnapshot<Todo>()
        addChildren(of: viewModel.todo, to: nil, in: &snapshot)
        apply(to: &snapshot)
    }
    
    func apply(to snapshot: inout NSDiffableDataSourceSectionSnapshot<Todo>) {
        snapshot.collapse(snapshot.items)
        dataSource.apply(snapshot, to: snapshot.items.count, animatingDifferences: .random())
    }
    
    func addChildren(of nodes: [Todo], to parent: Todo?, in snapshot: inout NSDiffableDataSourceSectionSnapshot<Todo>) {
        // If parent nil, this is the root Task
        snapshot.append(nodes, to: parent)
        
        for subChild in nodes {
            snapshot.append(subChild.children, to: subChild)
            for children in subChild.children {
                // Create sub task, each sub task should has root task and different IDs.
                addChildren(of: children.children, to: children, in: &snapshot)
            }
        }
    }
}
