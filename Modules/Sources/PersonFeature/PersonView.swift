import ComposableArchitecture
import SwiftUI

import ChartFeature

@Reducer
public struct PersonFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID
        public var name: String
        public var charts: IdentifiedArrayOf<ChartFeature.State>
        var activeChartID: UUID
        
        public init(
            id: UUID = UUID(),
            name: String,
            charts: IdentifiedArrayOf<ChartFeature.State>
        ) {
            self.id = id
            self.name = name
            self.charts = charts
            self.activeChartID = charts.first!.id // TODO: Don't force unwrap
        }
    }
    
    public enum Action: Sendable {
        case charts(IdentifiedActionOf<ChartFeature>)
        case selectChart(UUID)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .charts:
                return .none
            case let .selectChart(chartID):
                state.activeChartID = chartID
                return .none
            }
        }
        .forEach(\.charts, action: \.charts) {
            ChartFeature()
        }
    }
    
    public init() {}
}

public struct PersonView: View {
    @Bindable var store: StoreOf<PersonFeature>
    
    private var title: String {
        store.charts[id: store.activeChartID]?.name ?? "Chart"
    }
    
    public init(store: StoreOf<PersonFeature>) {
        self.store = store
    }
    
    public var body: some View {
        TabView(
            selection:  $store.activeChartID.sending(\.selectChart),
            content:  {
                ForEach(store.scope(state: \.charts, action: \.charts)) { childStore in
                    ChartView(store: childStore)
                        .tabItem {
                            Text(childStore.name)
                        }
                        .tag(childStore.state.id)
                }
            }
        )
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
