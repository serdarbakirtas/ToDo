import Foundation
import UIKit

class RightBarButtonItem: UIBarButtonItem {

    var tapAction: (() -> Void)?

    private let button = UIButton()

    override init() {
        super.init()
        setup()
    }

    init(with name: String?) {
        super.init()
        setup(name: name)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup(name: String? = nil) {

        self.button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.button.setTitle(name, for: .normal)
        self.button.setTitleColor(.black, for: .normal)
        self.button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.customView = button
    }

    @objc func buttonPressed() {
        if let action = tapAction {
            action()
        }
    }
}
