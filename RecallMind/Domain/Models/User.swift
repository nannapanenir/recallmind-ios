import Foundation

struct User: Identifiable, Equatable, Sendable {
    let id: UUID
    let email: String?
}
