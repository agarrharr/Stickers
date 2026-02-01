import ComposableArchitecture
import Foundation
@preconcurrency import NonEmpty

import Models

public let stickerPack = NonEmpty<[Sticker]>(
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, imageName: "face-0"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, imageName: "face-1"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, imageName: "face-2"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, imageName: "face-3"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!, imageName: "face-4"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!, imageName: "face-5"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!, imageName: "face-6"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!, imageName: "face-7"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!, imageName: "face-8"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-00000000000A")!, imageName: "face-8"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-00000000000B")!, imageName: "face-10"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-00000000000C")!, imageName: "face-11"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-00000000000D")!, imageName: "face-12"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-00000000000E")!, imageName: "face-13"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-00000000000F")!, imageName: "face-14"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!, imageName: "face-15"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!, imageName: "face-16"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!, imageName: "face-17"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!, imageName: "face-18"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!, imageName: "face-19"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000015")!, imageName: "face-20"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000016")!, imageName: "face-21"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000017")!, imageName: "face-22"),
    Sticker(id: UUID(uuidString: "00000000-0000-0000-0000-000000000018")!, imageName: "face-23")
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
