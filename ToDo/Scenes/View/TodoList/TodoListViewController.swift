import UIKit

class TodoListViewController: UIViewController {
    
    // Properties
    private var dataSource: UICollectionViewDiffableDataSource<Int, Todo>! = nil
    
    // UI
    private lazy var contentView = TodoListView()
    private let barButtonItem = RightBarButtonItem(with: "Add")

    // View model
    var viewModel: TodoListViewModelProtocol = TodoListViewModel(subchildArray: [Todo](), userDefaultsContainer: UserDefaultsContainer())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = barButtonItem
        view = contentView
        
        setBarButton()
        deleteTaskHandler()
        addSubtaskHandler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
}

//MARK: - Public methods

extension TodoListViewController {
    
    // Go to the detail page for creating a new task
    func makeCreateTodoViewController(parentId: String?) {
        viewModel.makeCreateTodoViewController(parentId: parentId)
    }
}

// MARK: Private methods

private extension TodoListViewController {
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<TodoListViewCell, Todo> { (cell, indexPath, node) in
            cell.todoLabel.text = node.name
            cell.buttonCheckbox.setImage(UIImage(systemName: node.isCompleted ? "checkmark.square.fill" : "square"), for: .normal)
            // TODO
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
        dataSource.apply(snapshot, to: snapshot.items.count, animatingDifferences: .random())
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
            guard let self, let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
            self.viewModel.deleteTask(item: item)
            self.reloadData()
        }
    }
    
    func addSubtaskHandler() {
        contentView.addSubtaskHandler = { [weak self] indexPath in
            guard let self,
                  let item = self.dataSource.itemIdentifier(for: indexPath),
                  let uuid = item.uuid else { return }
            
            self.makeCreateTodoViewController(parentId: uuid)
        }
    }
    
    func setBarButton() {
        barButtonItem.tapAction = { [weak self] in
            self?.makeCreateTodoViewController(parentId: nil) // create root task if parent id is nil
        }
    }
    
    func reloadData() {
        configureDataSource()
        createSnapshot()
    }
}

// MARK: - Delegates

extension TodoListViewController: TodoListViewCellDelegate {
    func didCheckbox(uuid: Int) {
//        findSelectedTodo(todos: viewModel.todos, uuid: uuid)
    }
    
    // TODO: Ugly code
//    private func findSelectedTodo(todos: [Todo], uuid: Int) {
//        for todo in todos {
//            if todo.id.hashValue == uuid {
//                print(uuid, todo.id.uuidString)
//            } else {
//                for childrens in todo.children {
//                    findSelectedTodo(todos: [children], uuid: uuid)
//                }
//            }
//        }
//    }
}
