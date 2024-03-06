import ComposableArchitecture
import SwiftUI

import AppFeature
import ChartFeature
import PersonFeature
import StickersFeature

let chart11 = ChartFeature.State(
    name: "Chores",
    reward: Reward(name: "Fishing rod"),
    stickers: StickersFeature.State(stickers: [
        StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill")),
        StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "cat.fill")),
        StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "dog.fill")),
        StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "moon.fill"))
    ])
)
let chart12 = ChartFeature.State(
    name: "Homework",
    reward: Reward(name: "Fishing rod"),
    stickers: StickersFeature.State(stickers: [
        StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill"))
    ])
)
let chart21 = ChartFeature.State(
    name: "Calm body",
    reward: Reward(name: "Batting cages"),
    stickers: StickersFeature.State(stickers: [
        StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill"))
    ])
)
let chart22 = ChartFeature.State(
    name: "Homework",
    reward: Reward(name: "Batting cages"),
    stickers: StickersFeature.State(stickers: [
        StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill"))
    ])
)
let chart31 = ChartFeature.State(
    name: "Homework",
    reward: Reward(name: "Batting cages"),
    stickers: StickersFeature.State(stickers: [
        StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill"))
    ])
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
