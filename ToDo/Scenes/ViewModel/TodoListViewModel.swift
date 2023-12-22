import Foundation

class TodoListViewModel {
    
    // Coordinator
    weak var appCoordinator : AppCoordinator?
    var todo: [Todo] = [
        Todo(
            name: "Murat",
            children: [Todo(
                name: "Mehmet",
                children: [Todo(
                    name: "Hasan",
                    children: [Todo(
                        name: "Ada",
                        children: []
                    )]
                )]
            )]
        ),
        Todo(
            name: "Sukran",
            children: [Todo(
                name: "Gizem",
                children: [Todo(
                    name: "Ada",
                    children: []
                )]
            )]
        )
    ]

    func makeCheckoutViewController(){
        appCoordinator?.makeCreateTodoViewController()
    }
}
