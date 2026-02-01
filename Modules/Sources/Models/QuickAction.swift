import Dependencies
import Foundation

public struct QuickAction: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var amount: Int

    public init(id: UUID, name: String = "", amount: Int = 1) {
        self.id = id
        self.name = name
        self.amount = amount
    }

    public init(name: String = "", amount: Int = 1) {
        @Dependency(\.uuid) var uuid
        self.init(id: uuid(), name: name, amount: amount)
    }
}
