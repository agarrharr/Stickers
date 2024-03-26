import ComposableArchitecture
import SwiftUI

import AppFeature
import ChartFeature
import PersonFeature
import StickerFeature

let chart11 = ChartFeature.State(
    name: "Chores",
    reward: Reward(name: "Fishing rod"),
    stickers: [
        StickerFeature.State(sticker: Sticker(imageName: "face-0")),
        StickerFeature.State(sticker: Sticker(imageName: "face-1")),
        StickerFeature.State(sticker: Sticker(imageName: "face-2")),
        StickerFeature.State(sticker: Sticker(imageName: "face-3"))
    ]
)
let chart12 = ChartFeature.State(
    name: "Homework",
    reward: Reward(name: "Fishing rod"),
    stickers: [
        StickerFeature.State(sticker: Sticker(imageName: "cat-0"))
    ],
    stickerPack: catStickerPack
)
let chart21 = ChartFeature.State(
    name: "Calm body",
    reward: Reward(name: "Batting cages"),
    stickers: [
        StickerFeature.State(sticker: Sticker(imageName: "face-0"))
    ]
)
let chart22 = ChartFeature.State(
    name: "Homework",
    reward: Reward(name: "Batting cages"),
    stickers: [
        StickerFeature.State(sticker: Sticker(imageName: "face-0"))
    ]
)
let chart31 = ChartFeature.State(
    name: "Homework",
    reward: Reward(name: "Batting cages"),
    stickers: [
        StickerFeature.State(sticker: Sticker(imageName: "face-0"))
    ]
)

let person1 = PersonFeature.State(name: "Blob", charts: [chart11, chart12])
let person2 = PersonFeature.State(name: "Son", charts: [chart21, chart22])
let person3 = PersonFeature.State(name: "Daughter", charts: [chart31])

@main
struct StickersApp: App {
    let state = AppFeature.State()
    
    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: state) {
                AppFeature()._printChanges()
            })
        }
    }
}
