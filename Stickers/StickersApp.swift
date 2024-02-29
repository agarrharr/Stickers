import AppFeature
import ChartFeature
import ComposableArchitecture
import Models
import StickersFeature
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
                            chart: Chart(
                                name: "Chores",
                                reward: Reward(name: "Fishing rod"),
                                stickers: StickersFeature.State(
                                    stickers: [
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .medium),
                                        Sticker(size: .small),
                                        Sticker(size: .small),
                                        Sticker(size: .small),
                                    ]
                                )
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
