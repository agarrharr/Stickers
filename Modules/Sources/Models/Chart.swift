import Foundation
import SQLiteData

@Table
public struct Chart: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name = ""

    public init(id: UUID, name: String = "") {
        self.id = id
        self.name = name
    }
}

extension Chart.Draft {
    public init(name: String = "") {
        self.id = nil
        self.name = name
    }
}
