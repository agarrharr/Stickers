import Foundation
import IdentifiedCollections

public enum StickerSize {
    case small
    case medium
    case large
}

public struct Sticker: Equatable, Identifiable {
    public var id: UUID
    public var size: StickerSize
    
    public init(id: UUID, size: StickerSize) {
        self.id = id
        self.size = size
    }
}

public struct Reward: Equatable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct Chart: Equatable, Identifiable {
    public var id: UUID
    public var name: String
    public var reward: Reward
    
    public init(id: UUID, name: String, reward: Reward) {
        self.id = id
        self.name = name
        self.reward = reward
    }
}

public struct Person: Equatable, Identifiable {
    public var id: UUID
    public var charts: IdentifiedArrayOf<Chart>
    
    public init(id: UUID, charts: IdentifiedArrayOf<Chart>) {
        self.id = id
        self.charts = charts
    }
}
