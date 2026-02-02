import ComposableArchitecture
import SQLiteData
import SwiftUI

import AddChartFeature
import ChartFeature
import Models

public struct ChartsView: View {
    @Bindable var store: StoreOf<ChartsFeature>
    @FetchAll(animation: .default) var charts: [Chart]

    public init(store: StoreOf<ChartsFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                ForEach(charts) { chart in
                    Button {
                        store.send(.chartTapped(chart.id))
                    } label: {
                        Text(chart.name)
                    }
                }
                .onDelete { offsets in
                    store.send(.chartsDeleteRequested(offsets))
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
                if charts.isEmpty {
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
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    ChartsView(
        store: Store(initialState: ChartsFeature.State()) {
            ChartsFeature()
                ._printChanges()
        }
    )
}
