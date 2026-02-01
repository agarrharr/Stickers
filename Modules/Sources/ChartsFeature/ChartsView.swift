import ComposableArchitecture
import SwiftUI

import AddChartFeature
import ChartFeature
import StickerFeature

@Reducer
public struct ChartsFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.charts) var charts
        @Presents var addChart: AddChartFeature.State?
        var path = StackState<ChartFeature.State>()

        public init(
            addChart: AddChartFeature.State? = nil
        ) {
            self.addChart = addChart
        }
    }

    public enum Action: Sendable {
        case addChartButtonTapped
        case chartTapped(Chart.ID)
        case addChart(PresentationAction<AddChartFeature.Action>)
        case path(StackActionOf<ChartFeature>)
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addChartButtonTapped:
                state.addChart = AddChartFeature.State()
                return .none

            case let .chartTapped(id):
                guard let chart = Shared(state.$charts[id: id]) else { return .none }
                state.path.append(ChartFeature.State(chart: chart))
                return .none

            case let .addChart(.presented(.delegate(action))):
                switch action {
                case let .onChartAdded(name, _):
                    let chart = Chart(
                        name: name,
                        behaviors: [],
                        stickers: [],
                        stickerPack: defaultStickerPack
                    )
                    _ = state.$charts.withLock { $0.append(chart) }
                    state.addChart = nil
                    return .none
                }

            case .addChart:
                return .none

            case .path:
                return .none
            }
        }
        .ifLet(\.$addChart, action: \.addChart) {
            AddChartFeature()
        }
        .forEach(\.path, action: \.path) {
            ChartFeature()
        }
    }

    public init() {}
}

public struct ChartsView: View {
    @Bindable var store: StoreOf<ChartsFeature>

    public init(store: StoreOf<ChartsFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                ForEach(store.charts) { chart in
                    Button {
                        store.send(.chartTapped(chart.id))
                    } label: {
                        Text(chart.name)
                    }
                }
            }
            .navigationTitle("Charts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.addChartButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if store.charts.isEmpty {
                    ContentUnavailableView {
                        Label("No Charts", systemImage: "chart.bar")
                    } description: {
                        Text("Tap + to add a chart.")
                    }
                }
            }
        } destination: { store in
            ChartView(store: store)
        }
        .sheet(item: $store.scope(state: \.addChart, action: \.addChart)) { store in
            AddChartView(store: store)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ChartsView(
        store: Store(initialState: ChartsFeature.State()) {
            ChartsFeature()
                ._printChanges()
        }
    )
}
