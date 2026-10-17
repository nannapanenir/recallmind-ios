import Foundation

struct User: Identifiable, Hashable, Sendable {
    let id: UUID
    let email: String?
}
