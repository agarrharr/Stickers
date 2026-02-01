import Dependencies
import Foundation
import IdentifiedCollections

public struct Chart: Identifiable, Equatable, Sendable, Codable {
    public var id: UUID
    public var name: String
    public var quickActions: IdentifiedArrayOf<QuickAction>
    public var stickers: IdentifiedArrayOf<Sticker>

    public init(id: UUID, name: String, quickActions: IdentifiedArrayOf<QuickAction> = [], stickers: IdentifiedArrayOf<Sticker> = []) {
        self.id = id
        self.name = name
        self.quickActions = quickActions
        self.stickers = stickers
    }

    public init(name: String, quickActions: IdentifiedArrayOf<QuickAction> = [], stickers: IdentifiedArrayOf<Sticker> = []) {
        @Dependency(\.uuid) var uuid
        self.init(id: uuid(), name: name, quickActions: quickActions, stickers: stickers)
    }
}
