import Dependencies
import Foundation

public struct Sticker: Identifiable, Equatable, Sendable, Codable {
    public var id: UUID
    public var imageName: String
    
    public init(imageName: String) {
        @Dependency(\.uuid) var uuid
        self.id = uuid()
        self.imageName = imageName
    }
}
