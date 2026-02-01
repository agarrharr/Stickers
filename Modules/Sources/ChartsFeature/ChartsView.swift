import ComposableArchitecture
import SwiftUI

import AddChartFeature
import ChartFeature

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
