import ComposableArchitecture
import GRDB
import NonEmpty
import SQLiteData
import SwiftUI

import Models
import StickerFeature

public struct ChartView: View {
    @Bindable var store: StoreOf<ChartFeature>

    public init(store: StoreOf<ChartFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                ForEach(store.state.stickers) { sticker in
                    StickerView(
                        store: Store(initialState: StickerFeature.State(sticker: sticker)) {
                            StickerFeature()
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle(store.state.chart?.name ?? "")
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
                if !store.state.quickActions.isEmpty {
                    Menu {
                        ForEach(store.state.quickActions) { quickAction in
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
        .task {
            store.send(.task)
        }
    }
}

struct ChartSettingsView: View {
    var store: StoreOf<ChartFeature>

    var body: some View {
        NavigationView {
            List {
                Section {
                    LabeledContent {
                        TextField("Chart name", text: Binding(
                            get: { store.state.chart?.name ?? "" },
                            set: { store.send(.nameChanged($0)) }
                        ))
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Name")
                    }
                }
                Section("Quick Actions") {
                    ForEach(store.state.quickActions) { quickAction in
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
        try! $0.defaultDatabase.write { db in
            try db.seed {
                Chart(id: UUID(0), name: "Chores")
                QuickAction(id: UUID(1), chartID: UUID(0), name: "Take out the trash", amount: 5)
                QuickAction(id: UUID(2), chartID: UUID(0), name: "Do homework", amount: 3)
                Sticker(id: UUID(3), chartID: UUID(0), imageName: "face-0")
                Sticker(id: UUID(4), chartID: UUID(0), imageName: "face-1")
                Sticker(id: UUID(5), chartID: UUID(0), imageName: "face-2")
                Sticker(id: UUID(6), chartID: UUID(0), imageName: "face-3")
                Sticker(id: UUID(7), chartID: UUID(0), imageName: "face-4")
                Sticker(id: UUID(8), chartID: UUID(0), imageName: "face-5")
                Sticker(id: UUID(9), chartID: UUID(0), imageName: "face-6")
                Sticker(id: UUID(10), chartID: UUID(0), imageName: "face-7")
            }
        }
    }
    NavigationStack {
        ChartView(
            store: Store(
                initialState: ChartFeature.State(chartID: UUID(0))
            ) {
                ChartFeature()
            }
        )
    }
}
