import ComposableArchitecture
import SwiftUI

public struct StickerView: View {
    var store: StoreOf<StickerFeature>

    public init(store: StoreOf<StickerFeature>) {
        self.store = store
    }

    public var body: some View {
        Image(store.sticker.imageName, bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
    }
}

#Preview {
    StickerView(
        store: Store(
            initialState: StickerFeature.State(
                sticker: stickerPack.first
            )
        ) {
            StickerFeature()
        }
    )
}
