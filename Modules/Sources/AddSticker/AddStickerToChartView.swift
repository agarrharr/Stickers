import ComposableArchitecture
import SwiftUI

import ChartFeature
import Models
import StickersFeature

import PeopleButtons

@Reducer
public struct AddStickerToChartFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared var charts: IdentifiedArrayOf<ChartFeature.State>
        var chartID: UUID
        
        public init(
            charts: Shared<IdentifiedArrayOf<ChartFeature.State>>,
            chartID: UUID
        ) {
            self._charts = charts
            self.chartID = chartID
        }
    }
    
    public enum Action: Sendable {
        case charts(IdentifiedActionOf<ChartFeature>)
        case view(ViewAction)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case behaviorButtonTapped(Behavior)
            case addAmountButtonTapped(Int)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case let .behaviorButtonTapped(behavior):
                    state.charts[id: state.chartID]?.chart.stickers.amount += behavior.amount
                    return .run { _ in
                        await dismiss()
                    }
                case let .addAmountButtonTapped(amount):
                    state.charts[id: state.chartID]?.chart.stickers.amount += amount
                    return .run { _ in
                        await dismiss()
                    }
                }
            case .charts:
                return .none
            }
        }
        .forEach(\.charts, action: \.charts) {
            ChartFeature()
        }
    }
    
    public init() {}
}

public struct AddStickerToChartView: View {
    var store: StoreOf<AddStickerToChartFeature>
    
    public init(store: StoreOf<AddStickerToChartFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            GeometryReader { reader in
                List {
                    ForEach(
                        store.scope(state: \.charts, action: \.charts),
                        id: \.state.id
                    ) { childStore in
                        if (childStore.chart.id == store.chartID) {
                            Section {
                                ForEach(childStore.chart.behaviors, id: \.id) { behavior in
                                    Button {
                                        store.send(.view(.behaviorButtonTapped(behavior)))
                                    } label: {
                                        HStack {
                                            Text(behavior.name)
                                            Spacer()
                                            Text("\(behavior.amount)")
                                        }
                                    }
                                }
                                Button {
                                    store.send(.view(.addAmountButtonTapped(1)))
                                } label: {
                                    Text("+1")
                                }
                                Button {
                                    store.send(.view(.addAmountButtonTapped(5)))
                                } label: {
                                    Text("+5")
                                }
                                Button {
                                    store.send(.view(.addAmountButtonTapped(10)))
                                } label: {
                                    Text("+10")
                                }
                            } header: {
                                Text(childStore.chart.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Sticker")
        }
    }
}

#Preview {
    let person1 = Person(name: "Blob")
    let id1 = UUID()
    
    return AddStickerToChartView(
        store: Store(
            initialState: AddStickerToChartFeature.State(
                charts: Shared([
                    ChartFeature.State(
                        chart: Chart(
                            id: id1,
                            name: "Chores",
                            reward: Reward(name: "Fishing rod"),
                            behaviors: [
                                Behavior(name: "Load dishwasher", amount: 1),
                                Behavior(name: "Sweep bathroom", amount: 5),
                                Behavior(name: "Put away clothes", amount: 2)
                            ],
                            person: person1
                        )
                    ),
                    
                    ChartFeature.State(
                        chart: Chart(
                            name: "Homework",
                            reward: Reward(name: "Batting cages"),
                            behaviors: [
                                Behavior(name: "Math homework", amount: 1),
                                Behavior(name: "Read", amount: 2)
                            ],
                            person: person1
                        )
                    )
                ]),
                chartID: id1
            )
        ) {
            AddStickerToChartFeature()
        }
    )
}
