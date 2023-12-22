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
                        children: [],
                        isCompleted: false
                    )],
                    isCompleted: false
                )],
                isCompleted: false
            )], 
            isCompleted: false
        ),
        Todo(
            name: "Sukran",
            children: [Todo(
                name: "Gizem",
                children: [Todo(
                    name: "Ada",
                    children: [], 
                    isCompleted: false
                )],
                isCompleted: false
            )],
            isCompleted: false
        )
    ]

    func makeCheckoutViewController(){
        appCoordinator?.makeCreateTodoViewController()
    }
}
