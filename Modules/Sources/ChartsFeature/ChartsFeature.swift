import ComposableArchitecture
import Foundation
import SQLiteData

import AddChartFeature
import ChartFeature
import Models

@Reducer
public struct ChartsFeature {
    @ObservableState
    public struct State: Equatable {
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

            case let .chartTapped(id):
                state.path.append(ChartFeature.State(chartID: id))
                return .none
                
            case let .chartsDeleteRequested(offsets):
                let database = database
                return .run { _ in
                    @FetchAll var charts: [Chart]
                    
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
                case let .onChartAdded(name, _, quickActions):
                    state.addChart = nil
                    let database = database
                    return .run { _ in
                        try database.write { db in
                            let chart = try Chart.insert {
                                Chart.Draft(name: name)
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
