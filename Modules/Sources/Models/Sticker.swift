import Foundation
import SQLiteData

@Table
public struct Sticker: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var chartID: Chart.ID
    public var imageName = ""
    public var createdAt: Date = Date()

    public init(id: UUID, chartID: Chart.ID, imageName: String = "", createdAt: Date = Date()) {
        self.id = id
        self.chartID = chartID
        self.imageName = imageName
        self.createdAt = createdAt
    }
}
