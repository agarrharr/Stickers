import ComposableArchitecture
import NonEmpty
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
                ForEach(store.chart.stickers) { sticker in
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
                if !store.chart.quickActions.isEmpty {
                    Menu {
                        ForEach(store.chart.quickActions) { quickAction in
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
    var store: StoreOf<ChartFeature>

    var body: some View {
        NavigationView {
            List {
                Section {
                    LabeledContent {
                        TextField("Chart name", text: Binding(
                            get: { store.chart.name },
                            set: { store.send(.nameChanged($0)) }
                        ))
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Name")
                    }
                }
                Section("Quick Actions") {
                    ForEach(store.chart.quickActions) { quickAction in
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
    NavigationStack {
        ChartView(
            store: Store(
                initialState: ChartFeature.State(
                    chart: Shared(value: Chart(
                        name: "Chores",
                        quickActions: [
                            QuickAction(name: "Take out the trash", amount: 5),
                            QuickAction(name: "Do homework", amount: 3),
                        ],
                        stickers: [
                            Sticker(imageName: "face-0"),
                            Sticker(imageName: "face-1"),
                            Sticker(imageName: "face-2"),
                            Sticker(imageName: "face-3"),
                            Sticker(imageName: "face-4"),
                            Sticker(imageName: "face-5"),
                            Sticker(imageName: "face-6"),
                            Sticker(imageName: "face-7")
                        ],
                    ))
                )
            ) {
                ChartFeature()
            }
        )
    }
}
