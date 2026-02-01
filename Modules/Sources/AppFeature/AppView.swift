import ComposableArchitecture
import SwiftUI

import ChartsFeature

public struct AppView: View {
    var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        ChartsView(store: store.scope(state: \.charts, action: \.charts))
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
                ._printChanges()
        }
    )
}
