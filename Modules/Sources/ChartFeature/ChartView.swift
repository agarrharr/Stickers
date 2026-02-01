import ComposableArchitecture
import NonEmpty
import Sharing
import SwiftUI

import StickerFeature

public struct Chart: Identifiable, Equatable, Sendable, Codable {
    public var id: UUID
    public var name: String
    public var reward: Reward?
    public var behaviors: [Behavior]
    public var stickers: IdentifiedArrayOf<Sticker>
    public var stickerPack: StickerPack
    
    public init(id: UUID = UUID(), name: String, reward: Reward? = nil, behaviors: [Behavior], stickers: IdentifiedArrayOf<Sticker>, stickerPack: StickerPack) {
        self.id = id
        self.name = name
        self.reward = reward
        self.behaviors = behaviors
        self.stickers = stickers
        self.stickerPack = stickerPack
    }
}

public struct Reward: Codable, Equatable, Sendable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct Behavior: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var amount: Int
    
    public init(
        id: UUID = UUID(),
        name: String,
        amount: Int
    ) {
        self.id = id
        self.name = name
        self.amount = amount
    }
}

@Reducer
public struct ChartFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared public var chart: Chart
        var showSettings = false

        public init(chart: Shared<Chart>) {
            self._chart = chart
        }
    }

    public enum Action: Sendable {
        case addStickerButtonTapped
        case quickActionTapped(Behavior.ID)
        case settingsButtonTapped
        case settingsDismissed
        case nameChanged(String)
        case addBehaviorButtonTapped
        case removeBehavior(Behavior.ID)
        case behaviorNameChanged(Behavior.ID, String)
        case behaviorAmountChanged(Behavior.ID, Int)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addStickerButtonTapped:
                let sticker = state.chart.stickerPack.stickers.randomElement()!
                _ = state.$chart.withLock { $0.stickers.append(Sticker(imageName: sticker.imageName)) }
                return .none

            case let .quickActionTapped(behaviorID):
                guard let behavior = state.chart.behaviors.first(where: { $0.id == behaviorID }) else { return .none }
                let pack = state.chart.stickerPack
                state.$chart.withLock { chart in
                    for _ in 0..<behavior.amount {
                        let sticker = pack.stickers.randomElement()!
                        chart.stickers.append(Sticker(imageName: sticker.imageName))
                    }
                }
                return .none

            case .settingsButtonTapped:
                state.showSettings = true
                return .none

            case .settingsDismissed:
                state.showSettings = false
                return .none

            case let .nameChanged(name):
                state.$chart.withLock { $0.name = name }
                return .none

            case .addBehaviorButtonTapped:
                state.$chart.withLock { $0.behaviors.append(Behavior(name: "", amount: 1)) }
                return .none

            case let .removeBehavior(id):
                state.$chart.withLock { $0.behaviors.removeAll { $0.id == id } }
                return .none

            case let .behaviorNameChanged(id, name):
                state.$chart.withLock { chart in
                    if let index = chart.behaviors.firstIndex(where: { $0.id == id }) {
                        chart.behaviors[index].name = name
                    }
                }
                return .none

            case let .behaviorAmountChanged(id, amount):
                state.$chart.withLock { chart in
                    if let index = chart.behaviors.firstIndex(where: { $0.id == id }) {
                        chart.behaviors[index].amount = amount
                    }
                }
                return .none
            }
        }
    }

    public init() {}
}

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
                HStack {
                    Button {
                        store.send(.settingsButtonTapped)
                    } label: {
                        Image(systemName: "gear")
                    }
                    if !store.chart.behaviors.isEmpty {
                        Menu {
                            ForEach(store.chart.behaviors) { behavior in
                                Button {
                                    store.send(.quickActionTapped(behavior.id))
                                } label: {
                                    Text("\(behavior.name) +\(behavior.amount)")
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
                    ForEach(store.chart.behaviors) { behavior in
                        HStack {
                            TextField("Name", text: Binding(
                                get: { behavior.name },
                                set: { store.send(.behaviorNameChanged(behavior.id, $0)) }
                            ))
                            Stepper(
                                "+\(behavior.amount)",
                                value: Binding(
                                    get: { behavior.amount },
                                    set: { store.send(.behaviorAmountChanged(behavior.id, $0)) }
                                ),
                                in: 1...99
                            )
                            Button(role: .destructive) {
                                store.send(.removeBehavior(behavior.id))
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    Button {
                        store.send(.addBehaviorButtonTapped)
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

public extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<Chart>>.Default {
    static var charts: Self {
        Self[.fileStorage(getChartsJSONURL()), default: []]
    }
}

func getAppSandboxDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func getChartsJSONURL() -> URL {
    getAppSandboxDirectory().appendingPathComponent("charts.json")
}

#Preview {
    NavigationStack {
        ChartView(
            store: Store(
                initialState: ChartFeature.State(
                    chart: Shared(value: Chart(
                        id: UUID(),
                        name: "Chores",
                        reward: Reward(name: "Fishing rod"),
                        behaviors: [
                            Behavior(name: "Take out the trash", amount: 5),
                            Behavior(name: "Do homework", amount: 3),
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
                        stickerPack: StickerPack(stickers: NonEmpty<[Sticker]>(Sticker(id: UUID(), imageName: "face-0")))
                    ))
                )
            ) {
                ChartFeature()
            }
        )
    }
}
