import ComposableArchitecture
import SwiftUI

struct Sticker: Identifiable {
    var id: UUID
}

@Reducer
public struct StickersFeature {
    @ObservableState
    public struct State {
        var stickers: IdentifiedArrayOf<Sticker> = []
    }
}

public struct StickersView: View {
    var store: StoreOf<StickersFeature>
    
    public init(store: StoreOf<StickersFeature>) {
        self.store = store
    }
    
    public var body: some View {
        LazyHGrid(rows: [GridItem(.fixed(20))], content: {
            ForEach(store.stickers, id: \.id) { sticker in
                Image(systemName: "star")
            }
        })
    }
}

#Preview {
    StickersView(
        store: Store(
            initialState: StickersFeature.State(
                stickers: [
                    Sticker(id: UUID()),
                    Sticker(id: UUID()),
                    Sticker(id: UUID()),
                ]
            )) {
                StickersFeature()
            }
    )
}
