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
                    people: Shared([person1, person2, person3]),
                    charts: Shared([
                        ChartFeature.State(
                            chart: Chart(
                                name: "Chores",
                                reward: Reward(name: "Fishing rod"),
                                stickers: StickersFeature.State(amount: 128),
                                person: person1
                            )
                        ),
                        ChartFeature.State(
                            chart: Chart(
                                name: "Chores",
                                reward: Reward(name: "Batting cages"),
                                behaviors: [
                                    Behavior(name: "Load dishwasher", amount: 1),
                                    Behavior(name: "Sweep bathroom", amount: 5),
                                    Behavior(name: "Put away clothes", amount: 2)
                                ],
                                stickers: StickersFeature.State(amount: 10),
                                person: person2
                            )
                        ),
                        ChartFeature.State(
                            chart: Chart(
                                name: "Homework",
                                reward: Reward(name: "TV"),
                                behaviors: [
                                    Behavior(name: "Math homework", amount: 1),
                                    Behavior(name: "Read", amount: 2)
                                ],
                                stickers: StickersFeature.State(amount: 4),
                                person: person2
                            )
                        )
                    ])
                )) {
                    AppFeature()._printChanges()
                }
            )
        }
    }
}
