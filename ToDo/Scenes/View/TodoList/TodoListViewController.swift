import UIKit

class TodoListViewController: UIViewController {
    
    // MARK: - Properties
    private var dataSource: UICollectionViewDiffableDataSource<Int, Todo>? = nil
    private var snapshot: NSDiffableDataSourceSectionSnapshot = NSDiffableDataSourceSectionSnapshot<Todo>()
    private let barButtonItem = RightBarButtonItem(with: "Add")
    private lazy var contentView = TodoListView()
    var viewModel: TodoListViewModelProtocol
    
    // MARK: - Initializers
    init(
        viewModel: TodoListViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = barButtonItem
        view = contentView
        
        setBarButton()
        deleteTaskHandler()
        addSubtaskHandler()
        editSubtaskHandler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSourceAndSnapshot()
    }
}

//MARK: - Public functions

extension TodoListViewController {
    
    // Go to the detail page for creating a new task
    func makeCreateTodoViewController(parentId: String?) {
        viewModel.makeCreateTodoViewController(parentId: parentId)
    }
}

// MARK: Private functions

private extension TodoListViewController {
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<TodoListViewCell, Todo> { (cell, indexPath, node) in
            cell.todoLabel.text = node.name
            cell.indexPath = indexPath
            cell.buttonCheckbox.setImage(UIImage(systemName: node.isCompleted ? "checkmark.square.fill" : "square"), for: .normal)
            cell.buttonCheckbox.tag = node.uuid?.hashValue ?? 0
            cell.delegate = self
            cell.accessories = node.childrens.isEmpty ? [] : [.outlineDisclosure()]
        }
        dataSource = UICollectionViewDiffableDataSource<Int, Todo>(collectionView: contentView.collectionView) {
            (collectionView, indexPath, node) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: node)
        }
    }
    
    func createSnapshot() {
        snapshot = NSDiffableDataSourceSectionSnapshot<Todo>()
        addChildren(of: viewModel.fetchTask(), to: nil, in: &snapshot)
        apply(to: &snapshot)
    }
    
    func apply(to snapshot: inout NSDiffableDataSourceSectionSnapshot<Todo>) {
        snapshot.collapse(snapshot.items)
        dataSource?.apply(snapshot, to: snapshot.items.count, animatingDifferences: .random())
    }
    
    func addChildren(of nodes: [Todo], to parent: Todo?, in snapshot: inout NSDiffableDataSourceSectionSnapshot<Todo>) {
        // If parent nil, this is the root Task
        snapshot.append(nodes, to: parent)
        for subChild in nodes {
            snapshot.append(subChild.childrens, to: subChild)
            for children in subChild.childrens {
                // Create sub task, each sub task should has root task and different IDs.
                addChildren(of: children.childrens, to: children, in: &snapshot)
            }
        }
    }
    
    func deleteTaskHandler() {
        contentView.deleteHandler = { [weak self] indexPath in
            guard let self, let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }
            self.viewModel.deleteTask(item: item)
            self.updateDataSourceAndSnapshot()
        }
    }
    
    func addSubtaskHandler() {
        contentView.addHandler = { [weak self] indexPath in
            guard let self,
                  let item = self.dataSource?.itemIdentifier(for: indexPath),
                  let uuid = item.uuid else { return }
            
            self.makeCreateTodoViewController(parentId: uuid)
        }
    }
    
    func editSubtaskHandler() {
        contentView.editHandler = { [weak self] indexPath in
            self?.makeCreateTodoViewController(parentId: nil)
        }
    }
    
    func setBarButton() {
        barButtonItem.tapAction = { [weak self] in
            self?.makeCreateTodoViewController(parentId: nil) // create root task because of parent id is nil
        }
    }
    
    func updateDataSourceAndSnapshot() {
        configureDataSource()
        createSnapshot()
    }
}

// MARK: - Delegates

extension TodoListViewController: TodoListViewCellDelegate {
    
    func didCheckbox(indexPath: IndexPath, tag: Int) {
        
        guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        
        viewModel.updateTask(item: item)
        item.isCompleted.toggle()

        guard var snapshot = dataSource?.snapshot() else { return }
        snapshot.reloadItems([item])
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
