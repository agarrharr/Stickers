import Foundation

public struct Sticker: Identifiable, Equatable, Sendable, Codable {
    public var id: UUID
    public var imageName: String
    
    public init(id: UUID = UUID(), imageName: String) {
        self.id = id
        self.imageName = imageName
    }
}
