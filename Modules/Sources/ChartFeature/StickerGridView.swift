import ComposableArchitecture
import SQLiteData
import SwiftUI

import Models
import StickerFeature

struct StickerGridView: View {
    let stickers: [Sticker]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
            ForEach(stickers) { sticker in
                StickerView(
                    store: Store(initialState: StickerFeature.State(sticker: sticker)) {
                        StickerFeature()
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}
