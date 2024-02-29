import AppFeature
import ChartFeature
import ComposableArchitecture
import Models
import SwiftUI

@main
struct StickersApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State(
                    people: [],
                    charts: [
                        ChartFeature.State(
                            id: UUID(),
                            chart: Chart(
                                id: UUID(),
                                name: "Chores",
                                reward: Reward(name: "Fishing rod"),
                                stickers: [
                                    Sticker(id: UUID(), size: .large),
                                    Sticker(id: UUID(), size: .large),
                                    Sticker(id: UUID(), size: .large),
                                    Sticker(id: UUID(), size: .medium),
                                    Sticker(id: UUID(), size: .small),
                                    Sticker(id: UUID(), size: .small),
                                    Sticker(id: UUID(), size: .small),
                                ]
                            )
                        )
                    ]
                )) {
                    AppFeature()._printChanges()
                }
            )
        }
    }
}
