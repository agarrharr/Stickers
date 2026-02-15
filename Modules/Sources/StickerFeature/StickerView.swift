import SwiftUI

import Models

public struct StickerView: View {
    let imageName: String

    public init(sticker: Sticker) {
        self.imageName = sticker.imageName
    }

    public var body: some View {
        Image(imageName, bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
    }
}

#Preview {
    StickerView(
        sticker: Sticker(id: UUID(0), chartID: UUID(0), imageName: stickerPack.first)
    )
}
