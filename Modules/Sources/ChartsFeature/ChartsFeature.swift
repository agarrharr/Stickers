import ComposableArchitecture

import AddChartFeature
import ChartFeature
import Models
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
                case let .onChartAdded(name, _, quickActions):
                    let chart = Chart(
                        name: name,
                        quickActions: quickActions,
                        stickers: []
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
