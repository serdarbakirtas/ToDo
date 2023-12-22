import Foundation

struct Todo: Identifiable, Hashable {
    var name: String
    var children: [Todo]
    var isCompleted: Bool
    var id = UUID()
}
