import Dependencies
import Foundation

public struct QuickAction: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var amount: Int
    
    public init(name: String = "", amount: Int = 1) {
        @Dependency(\.uuid) var uuid
        self.id = uuid()
        self.name = name
        self.amount = amount
    }
}
