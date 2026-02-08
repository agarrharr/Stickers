import ComposableArchitecture
import Foundation
import SQLiteData

import AddChartFeature
import ChartFeature
import Models

@Reducer
public struct ChartsFeature {
    @ObservableState
    public struct State {
        @Presents var addChart: AddChartFeature.State?
        @ObservationStateIgnored @FetchAll var charts: [Chart]
        var path = StackState<ChartFeature.State>()

        public init(
            addChart: AddChartFeature.State? = nil
        ) {
            self.addChart = addChart
        }
    }

    public enum Action: Sendable {
        case addChartButtonTapped
        case chartTapped(Chart)
        case chartsDeleteRequested(IndexSet)
        case addChart(PresentationAction<AddChartFeature.Action>)
        case path(StackActionOf<ChartFeature>)
    }

    @Dependency(\.defaultDatabase) var database

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addChartButtonTapped:
                state.addChart = AddChartFeature.State()
                return .none

            case let .chartTapped(chart):
                state.path.append(ChartFeature.State(chart: chart))
                return .none

            case let .chartsDeleteRequested(offsets):
                let charts = state.charts
                let database = database
                return .run { _ in
                    withErrorReporting {
                        try database.write { db in
                            try Chart.find(offsets.map { charts[$0].id })
                                .delete()
                                .execute(db)
                        }
                    }
                }

            case let .addChart(.presented(.delegate(action))):
                switch action {
                case let .onChartAdded(name, color, quickActions):
                    state.addChart = nil
                    let database = database
                    return .run { _ in
                        try database.write { db in
                            let chart = try Chart.insert {
                                Chart.Draft(name: name, color: color.rawValue)
                            }
                            .returning(\.self)
                            .fetchOne(db)!

                            for qa in quickActions {
                                try QuickAction.insert {
                                    QuickAction.Draft(
                                        chartID: chart.id,
                                        name: qa.name,
                                        amount: qa.amount
                                    )
                                }.execute(db)
                            }
                        }
                    }
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
