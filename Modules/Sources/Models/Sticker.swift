import Dependencies
import Foundation

public struct Sticker: Identifiable, Equatable, Sendable, Codable {
    public var id: UUID
    public var imageName: String

    public init(id: UUID, imageName: String) {
        self.id = id
        self.imageName = imageName
    }

    public init(imageName: String) {
        @Dependency(\.uuid) var uuid
        self.init(id: uuid(), imageName: imageName)
    }
}
