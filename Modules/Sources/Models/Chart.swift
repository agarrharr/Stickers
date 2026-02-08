import Foundation
import SQLiteData

@Table
public struct Chart: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name = ""
    public var color: String = BackgroundColor.yellow.rawValue

    public init(id: UUID, name: String = "", color: String = BackgroundColor.yellow.rawValue) {
        self.id = id
        self.name = name
        self.color = color
    }

    public var backgroundColor: BackgroundColor {
        BackgroundColor(rawValue: color) ?? .yellow
    }
}
