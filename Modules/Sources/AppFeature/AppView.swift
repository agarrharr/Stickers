import ComposableArchitecture
import Dependencies
import SwiftUI

import ChartsFeature
import Models

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
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
    }
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
                ._printChanges()
        }
    )
}
