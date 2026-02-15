import ComposableArchitecture
import SQLiteData
import SwiftUI
import SwiftUINavigation

import Models
import StickerFeature

public struct ChartView: View {
    @Dependency(\.defaultSyncEngine) var syncEngine
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
            VStack(spacing: 16) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(stickers.count)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("stickers")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    ProgressView()
                        .controlSize(.small)
                        .frame(width: 14, height: 14)
                        .alignmentGuide(.firstTextBaseline) { dimensions in
                            dimensions[VerticalAlignment.bottom]
                        }
                        .opacity(syncEngine.isSynchronizing ? 1 : 0)
                        .accessibilityHidden(!syncEngine.isSynchronizing)
                    Spacer()
                }
                .padding(.horizontal)

                Picker("View Mode", selection: $store.viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch store.viewMode {
                case .grid:
                    StickerGridView(stickers: stickers)
                case .history:
                    StickerHistoryView(chartID: store.chart.id)
                }
            }
            .padding(.top, 8)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.syncNowButtonTapped)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.shareButtonTapped)
                } label: {
                    Image(systemName: "square.and.arrow.up")
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
        .sheet(
            item: Binding(
                get: { store.sharedRecord },
                set: { _ in store.send(.shareDismissed) }
            )
        ) { sharedRecord in
            CloudSharingView(
                sharedRecord: sharedRecord,
                availablePermissions: [.allowPrivate, .allowPublic, .allowReadWrite]
            )
        }
        .alert(
            "CloudKit Sync Error",
            isPresented: Binding(
                get: { store.syncErrorMessage != nil },
                set: { newValue in
                    if !newValue {
                        store.send(.syncErrorDismissed)
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                store.send(.syncErrorDismissed)
            }
        } message: {
            Text(store.syncErrorMessage ?? "Unknown CloudKit error.")
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

                Section {
                    Button(role: .destructive) {
                        store.send(.deleteAllStickersButtonTapped)
                    } label: {
                        Text("Delete All Stickers")
                    }
                }
            }
            .alert(
                "Delete All Stickers?",
                isPresented: $store.destination.deleteAllStickersAlert
            ) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    store.send(.deleteAllStickersConfirmed)
                }
            } message: {
                Text("This will permanently delete all stickers from this chart. This action cannot be undone.")
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
