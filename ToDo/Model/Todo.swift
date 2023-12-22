import Foundation

struct Todo: Identifiable, Hashable {
    var name: String
    var children: [Todo]
    var id = UUID()
}
