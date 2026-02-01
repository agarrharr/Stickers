import ComposableArchitecture

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
