import Foundation
import IdentifiedCollections

public struct Person: Equatable, Identifiable {
    public var id: UUID
    public var name: String
    
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}
