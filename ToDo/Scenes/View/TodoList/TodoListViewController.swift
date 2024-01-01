import UIKit

class TodoListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let barButtonItem = RightBarButtonItem(with: "Add")
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, TodoItem>? = nil
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
        
        reloadData()
        setupUI()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .todo, object: nil)
    }
}

//MARK: - Public functions

extension TodoListViewController {
    
    // Go to the detail page for creating a new task
    func makeCreateTodoViewController(todo: TodoItem?, isEditable: Bool) {
        viewModel.makeCreateTodoViewController(todo: todo, isEditable: isEditable)
    }
}

// MARK: Private functions

private extension TodoListViewController {
    
    func setupUI() {
        setBarButton()
        deleteTaskHandler()
        addSubtaskHandler()
        editTaskHandler()
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<TodoListViewCell, TodoItem> { (cell, indexPath, node) in
            cell.todoLabel.text = node.name
            cell.todo = node
            cell.buttonCheckbox.setImage(UIImage(systemName: node.isCompleted ? "checkmark.square.fill" : "square"), for: .normal)
            cell.buttonCheckbox.tag = node.id.hashValue
            cell.delegate = self
            cell.accessories = node.children.isEmpty ? [] : [.outlineDisclosure()]
        }
        dataSource = UICollectionViewDiffableDataSource<Int, TodoItem>(collectionView: contentView.collectionView) {
            (collectionView, indexPath, node) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: node)
        }
    }
    
    func createSnapshot() {
        var snapshot = NSDiffableDataSourceSectionSnapshot<TodoItem>()
        addChildren(of: viewModel.fetchTasks(), to: nil, in: &snapshot)
        apply(to: &snapshot)
    }
    
    func apply(to snapshot: inout NSDiffableDataSourceSectionSnapshot<TodoItem>) {
        snapshot.collapse(snapshot.items)
        dataSource?.apply(snapshot, to: snapshot.items.count, animatingDifferences: true)
    }
    
    func addChildren(of nodes: [TodoItem], to parent: TodoItem?, in snapshot: inout NSDiffableDataSourceSectionSnapshot<TodoItem>) {
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
    
    func deleteTaskHandler() {
        contentView.deleteHandler = { [weak self] indexPath in
            guard let self, let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }
            self.viewModel.deleteTask(item: item)
            
            guard var snapshot = dataSource?.snapshot() else { return }
            snapshot.deleteItems([item])
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func addSubtaskHandler() {
        contentView.addHandler = { [weak self] indexPath in
            guard let self, let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }
            self.makeCreateTodoViewController(todo: item, isEditable: false)
        }
    }
    
    func editTaskHandler() {
        contentView.editHandler = { [weak self] indexPath in
            guard let self, let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }
            self.makeCreateTodoViewController(todo: item, isEditable: true)
        }
    }
    
    func setBarButton() {
        barButtonItem.tapAction = { [weak self] in
            self?.makeCreateTodoViewController(todo: nil, isEditable: false) // create root task because of parent id is nil
        }
    }
    
    func reloadData() {
        configureDataSource()
        createSnapshot()
    }
}

// MARK: - Delegates

extension TodoListViewController: TodoListViewCellDelegate {
    
    func didCheckbox(todo: TodoItem) {
        
        guard var snapshot = dataSource?.snapshot() else { return }
        guard let snapShotNode = snapshot.itemIdentifiers.first(where: { $0.id == todo.id }) else { return }
        viewModel.toggleCompleted(todo: snapShotNode)
        snapshot.reloadItems([snapShotNode])
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Notification Handling

private extension TodoListViewController {
    
    // TODO: Do not use nsnotification center - Ugly method
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(todoUpdate(notification:)), name: .todo, object: nil)
    }

    @objc dynamic func todoUpdate(notification: Notification) {
        if let todo = notification.userInfo?["value"] as? TodoItem {
            
            guard var snapshot = dataSource?.snapshot() else { return }
            guard let snapShotNode = snapshot.itemIdentifiers.first(where: { $0.id == todo.id }) else { return }
            snapShotNode.isCompleted = todo.isCompleted
            snapshot.reloadItems([snapShotNode])
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
}
