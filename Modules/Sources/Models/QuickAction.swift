import Foundation
import SQLiteData

@Table
public struct QuickAction: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var chartID: Chart.ID
    public var name = ""
    public var amount = 1

    public init(id: UUID, chartID: Chart.ID, name: String = "", amount: Int = 1) {
        self.id = id
        self.chartID = chartID
        self.name = name
        self.amount = amount
    }
}
