import Foundation
import SQLiteData

@Table
public struct Sticker: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var chartID: Chart.ID
    public var imageName = ""

    public init(id: UUID, chartID: Chart.ID, imageName: String = "") {
        self.id = id
        self.chartID = chartID
        self.imageName = imageName
    }
}
