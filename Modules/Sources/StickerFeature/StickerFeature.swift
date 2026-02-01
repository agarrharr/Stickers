import ComposableArchitecture
import Foundation
@preconcurrency import NonEmpty

import Models

public let stickerPack = NonEmpty<[Sticker]>(
    Sticker(imageName: "face-0"),
    Sticker(imageName: "face-1"),
    Sticker(imageName: "face-2"),
    Sticker(imageName: "face-3"),
    Sticker(imageName: "face-4"),
    Sticker(imageName: "face-5"),
    Sticker(imageName: "face-6"),
    Sticker(imageName: "face-7"),
    Sticker(imageName: "face-8"),
    Sticker(imageName: "face-8"),
    Sticker(imageName: "face-10"),
    Sticker(imageName: "face-11"),
    Sticker(imageName: "face-12"),
    Sticker(imageName: "face-13"),
    Sticker(imageName: "face-14"),
    Sticker(imageName: "face-15"),
    Sticker(imageName: "face-16"),
    Sticker(imageName: "face-17"),
    Sticker(imageName: "face-18"),
    Sticker(imageName: "face-19"),
    Sticker(imageName: "face-20"),
    Sticker(imageName: "face-21"),
    Sticker(imageName: "face-22"),
    Sticker(imageName: "face-23")
)

@Reducer
public struct StickerFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var sticker: Sticker

        public init(sticker: Sticker) {
            self.sticker = sticker
        }
    }

    public enum Action: Sendable {
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }

    public init() {}
}
