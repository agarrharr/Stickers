import ComposableArchitecture
import GRDB
import NonEmpty
import SQLiteData
import SwiftUI

import Models
import StickerFeature

//public struct ChartDataRequest: FetchKeyRequest {
//    var chartID: Chart.ID
//
//    public struct Value: Equatable, Sendable {
//        var chart: Chart?
//        var stickers: [Sticker] = []
//        var quickActions: [QuickAction] = []
//    }
//
//    public func fetch(_ db: Database) throws -> Value {
//        try Value(
//            chart: Chart.find(chartID).fetchOne(db),
//            stickers: Sticker.where { $0.chartID.eq(chartID) }.fetchAll(db),
//            quickActions: QuickAction.where { $0.chartID.eq(chartID) }.fetchAll(db)
//        )
//    }
//}

public struct ChartView: View {
    @FetchAll var stickers: [Sticker]
    @FetchAll var quickActions: [QuickAction]
    @Bindable var store: StoreOf<ChartFeature>

    public init(store: StoreOf<ChartFeature>) {
        self.store = store
        _stickers = FetchAll(
            Sticker.where { $0.chartID.eq(store.chart.id) },
            animation: .default
        )
        _quickActions = FetchAll(
            QuickAction.where { $0.chartID.eq(store.chart.id) },
            animation: .default
        )
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                ForEach(stickers) { sticker in
                    StickerView(
                        store: Store(initialState: StickerFeature.State(sticker: sticker)) {
                            StickerFeature()
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle(store.chart.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.settingsButtonTapped)
                } label: {
                    Image(systemName: "gear")
                }
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !quickActions.isEmpty {
                    Menu {
                        ForEach(quickActions) { quickAction in
                            Button {
                                store.send(.quickActionTapped(quickAction.id))
                            } label: {
                                Text("\(quickAction.name) +\(quickAction.amount)")
                            }
                        }
                    } label: {
                        Image(systemName: "bolt.fill")
                    }
                }
                Button {
                    store.send(.addStickerButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(
            isPresented: Binding(
                get: { store.showSettings },
                set: { newValue in
                    if !newValue { store.send(.settingsDismissed) }
                }
            )
        ) {
            ChartSettingsView(store: store)
        }
    }
}

struct ChartSettingsView: View {
    @FetchAll var quickActions: [QuickAction]
    @Bindable var store: StoreOf<ChartFeature>

    init(store: StoreOf<ChartFeature>) {
        self.store = store
        _quickActions = FetchAll(
            QuickAction.where { $0.chartID.eq(store.chart.id) },
            animation: .default
        )
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    LabeledContent {
                        TextField("Chart name", text: Binding(
                            get: { store.chart.name },
                            set: { store.send(.nameChanged($0)) }
                        ))
//                        TextField("Chart name", text: $store.chart.name)
//                        TextField("Chart name", text: $store.chart.name.sending(\.nameChanged))
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Name")
                    }
                }
                Section("Quick Actions") {
                    ForEach(quickActions) { quickAction in
                        HStack {
                            TextField("Name", text: Binding(
                                get: { quickAction.name },
                                set: { store.send(.quickActionNameChanged(quickAction.id, $0)) }
                            ))
                            Stepper(
                                "+\(quickAction.amount)",
                                value: Binding(
                                    get: { quickAction.amount },
                                    set: { store.send(.quickActionAmountChanged(quickAction.id, $0)) }
                                ),
                                in: 1...99
                            )
                            Button(role: .destructive) {
                                store.send(.removeQuickAction(quickAction.id))
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    Button {
                        store.send(.addQuickActionButtonTapped)
                    } label: {
                        Label("Add New", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        store.send(.settingsDismissed)
                    }
                }
            }
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    NavigationStack {
        ChartView(
            store: Store(
                initialState: ChartFeature.State(chart: Chart(id: UUID(0), name: "Chores"))
            ) {
                ChartFeature()
            }
        )
    }
}
