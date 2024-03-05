import ComposableArchitecture
import SwiftUI

import AppFeature
import ChartFeature
import PersonFeature
import StickersFeature

let chart11 = ChartFeature.State(
    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
    name: "Chores",
    reward: Reward(name: "Fishing rod"),
    stickers: StickersFeature.State(amount: 98)
)
let chart12 = ChartFeature.State(
    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
    name: "Homework",
    reward: Reward(name: "Fishing rod"),
    stickers: StickersFeature.State(amount: 43)
)
let chart21 = ChartFeature.State(
    name: "Calm body",
    reward: Reward(name: "Batting cages"),
    stickers: StickersFeature.State(amount: 5)
)
let chart22 = ChartFeature.State(
    name: "Homework",
    reward: Reward(name: "Batting cages"),
    stickers: StickersFeature.State(amount: 14)
)
let chart31 = ChartFeature.State(
    name: "Homework",
    reward: Reward(name: "Batting cages"),
    stickers: StickersFeature.State(amount: 38)
)

let person1 = PersonFeature.State(name: "Blob", charts: [chart11, chart12])
let person2 = PersonFeature.State(name: "Son", charts: [chart21, chart22])
let person3 = PersonFeature.State(name: "Daughter", charts: [chart31])

@main
struct StickersApp: App {
    
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppFeature.State(
                        people: Shared([person1, person2, person3]),
                        activePersonID: person1.id
                    )
                ) {
                    AppFeature()._printChanges()
                }
            )
        }
    }
}
