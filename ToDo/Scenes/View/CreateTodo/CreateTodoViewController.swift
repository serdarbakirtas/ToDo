import Foundation
import UIKit

class CreateTodoViewController: UIViewController {
    
    // UI
    private lazy var contentView = CreateTodoView()
    
    // Properties
    let barButtonItem = RightBarButtonItem(with: "Save")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        barButtonItem.tapAction = {
//            self.
        }
        
        view = contentView
    }
}
