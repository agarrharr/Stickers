import Foundation
import IdentifiedCollections

public enum StickerSize {
    case small
    case medium
    case large
}

public struct Sticker: Identifiable {
    public var id: UUID
    public var size: StickerSize
    
    public init(id: UUID, size: StickerSize) {
        self.id = id
        self.size = size
    }
}

public struct Reward {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct Chart: Identifiable {
    public var id: UUID
    public var name: String
    public var reward: Reward
    public var stickers: IdentifiedArrayOf<Sticker>
    
    public init(id: UUID, name: String, reward: Reward, stickers: IdentifiedArrayOf<Sticker>) {
        self.id = id
        self.name = name
        self.reward = reward
        self.stickers = stickers
    }
}

public struct Person: Identifiable {
    public var id: UUID
    public var charts: IdentifiedArrayOf<Chart>
    
    public init(id: UUID, charts: IdentifiedArrayOf<Chart>) {
        self.id = id
        self.charts = charts
    }
}
