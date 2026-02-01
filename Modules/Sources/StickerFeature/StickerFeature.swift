import ComposableArchitecture
import Foundation
@preconcurrency import NonEmpty

import Models

public let stickerPack = NonEmpty<[String]>(
    "face-0",
    "face-1",
    "face-2",
    "face-3",
    "face-4",
    "face-5",
    "face-6",
    "face-7",
    "face-8",
    "face-8",
    "face-10",
    "face-11",
    "face-12",
    "face-13",
    "face-14",
    "face-15",
    "face-16",
    "face-17",
    "face-18",
    "face-19",
    "face-20",
    "face-21",
    "face-22",
    "face-23"
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
