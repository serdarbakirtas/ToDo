import UIKit

class TodoListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let barButtonItem = RightBarButtonItem(with: "Add")
    private let userDefaultsContainer: UserDefaultsContainerProtocol
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, Todo>? = nil
    private lazy var contentView = TodoListView()
    var viewModel: TodoListViewModelProtocol
    
    // MARK: - Initializers
    
    init(
        viewModel: TodoListViewModelProtocol,
        userDefaultsContainer: UserDefaultsContainerProtocol
    ) {
        self.viewModel = viewModel
        self.userDefaultsContainer = userDefaultsContainer
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
        editTaskHandler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSourceAndSnapshot()
    }
}

//MARK: - Public functions

extension TodoListViewController {
    
    // Go to the detail page for creating a new task
    func makeCreateTodoViewController(todo: Todo?, isEditable: Bool) {
        viewModel.makeCreateTodoViewController(todo: todo, isEditable: isEditable)
    }
}

// MARK: Private functions

private extension TodoListViewController {
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<TodoListViewCell, Todo> { (cell, indexPath, node) in
            cell.todoLabel.text = node.name
            cell.todo = node
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
        var snapshot = NSDiffableDataSourceSectionSnapshot<Todo>()
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
    
    func updateDataSourceAndSnapshot() {
        configureDataSource()
        createSnapshot()
    }
    
    func findAndUpdateCheckBoxes(todo: Todo, isComplete: Bool) {
        let todos = userDefaultsContainer.fetchAll(key: .todoItems)
        searchForItemsToUpdate(root: todos, key: todo, isComplete: isComplete)
    }
    
    func searchForItemsToUpdate(root: [Todo], key: Todo, isComplete: Bool) {
        
        guard var snapshot = dataSource?.snapshot() else { return }
        guard let snapshotNode = snapshot.itemIdentifiers.first(where: { $0.uuid == key.uuid }) else { return }
        snapshotNode.isCompleted = isComplete
        snapshot.reloadItems([snapshotNode])
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        for children in key.childrens {
            children.isCompleted = snapshotNode.isCompleted
            searchForItemsToUpdate(root: children.childrens, key: children, isComplete: snapshotNode.isCompleted)
        }
    }
}

// MARK: - Delegates

extension TodoListViewController: TodoListViewCellDelegate {
    
    func didCheckbox(todo: Todo, tag: Int) {
        todo.isCompleted.toggle()
        findAndUpdateCheckBoxes(todo: todo, isComplete: todo.isCompleted)
    }
}
