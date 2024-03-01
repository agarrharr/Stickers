import ComposableArchitecture
import SwiftUI

import AppFeature
import ChartFeature
import Models
import StickersFeature

@main
struct StickersApp: App {
    let person1 = Person(name: "Blob")
    let person2 = Person(name: "Son")
    let person3 = Person(name: "Daughter")
    
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State(
                    people: [person1, person2, person3],
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
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .large),
                                        Sticker(size: .medium),
                                        Sticker(size: .small),
                                        Sticker(size: .small),
                                        Sticker(size: .small),
                                    ]
                                ),
                                person: person1
                            )
                        ),
                        ChartFeature.State(
                            chart: Chart(
                                name: "Chores",
                                reward: Reward(name: "Batting cages"),
                                stickers: StickersFeature.State(
                                    stickers: [
                                        Sticker(size: .large)
                                    ]
                                ),
                                person: person2
                            )
                        ),
                        ChartFeature.State(
                            chart: Chart(
                                name: "Homework",
                                reward: Reward(name: "TV"),
                                stickers: StickersFeature.State(
                                    stickers: [
                                        Sticker(size: .small),
                                        Sticker(size: .small),
                                        Sticker(size: .small),
                                        Sticker(size: .small),
                                    ]
                                ),
                                person: person2
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
