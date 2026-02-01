import ComposableArchitecture
import SwiftUI

import ChartsFeature

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        var charts: ChartsFeature.State

        public init() {
            self.charts = ChartsFeature.State()
        }
    }

    public enum Action: Sendable {
        case charts(ChartsFeature.Action)
    }

    public var body: some Reducer<State, Action> {
        Scope(state: \.charts, action: \.charts) {
            ChartsFeature()
        }
    }

    public init() {}
}

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
