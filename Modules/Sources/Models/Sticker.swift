import Foundation
import SQLiteData

@Table
public struct Sticker: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var chartID: Chart.ID
    public var imageName = ""
    // Intentionally not a SQL foreign key: stickers must keep a single foreign
    // key (chartID) for CloudKit sharing to include them in a shared chart.
    public var batchID: StickerBatch.ID?

    public init(
        id: UUID,
        chartID: Chart.ID,
        imageName: String = "",
        batchID: StickerBatch.ID? = nil
    ) {
        self.id = id
        self.chartID = chartID
        self.imageName = imageName
        self.batchID = batchID
    }
}

extension Sticker.Draft {
    public init(
        chartID: Chart.ID,
        imageName: String = "",
        batchID: StickerBatch.ID? = nil
    ) {
        self.id = nil
        self.chartID = chartID
        self.imageName = imageName
        self.batchID = batchID
    }
}
