import Foundation
import SQLiteData

@Table
public struct StickerBatch: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var chartID: Chart.ID
    public var note: String?
    public var createdAt: Date

    public init(
        id: UUID,
        chartID: Chart.ID,
        note: String? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.chartID = chartID
        self.note = note
        self.createdAt = createdAt
    }
}

extension StickerBatch.Draft {
    public init(
        chartID: Chart.ID,
        note: String? = nil,
        createdAt: Date
    ) {
        self.id = nil
        self.chartID = chartID
        self.note = note
        self.createdAt = createdAt
    }
}
