import ComposableArchitecture
import ChartFeature
import Models
import SettingsFeature
import StickersFeature
import SwiftUI

@Reducer
public struct AppFeature {
    @Reducer(state: .equatable, action: .sendable)
    public enum Destination {
        case settings(SettingsFeature)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        var people: IdentifiedArrayOf<Person>
        var charts: IdentifiedArrayOf<ChartFeature.State>
        
        public init(
            people: IdentifiedArrayOf<Person> = [],
            charts: IdentifiedArrayOf<ChartFeature.State> = []
        ) {
            self.people = people
            self.charts = charts
        }
    }
    
    public enum Action: Sendable {
        case destination(PresentationAction<Destination.Action>)
        case charts(IdentifiedActionOf<ChartFeature>)
        case view(ViewAction)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case settingsIconTapped
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
            case .charts:
                return .none
            case let .view(action):
                switch action {
                case .settingsIconTapped:
                    state.destination = .settings(SettingsFeature.State())
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.charts, action: \.charts) {
            ChartFeature()
        }
    }
    
    public init() {}
}

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            List {
                HStack {
                    Image(systemName: "person.circle")
                        .font(.largeTitle)
                    Image(systemName: "person.circle")
                        .font(.largeTitle)
                    Image(systemName: "person.circle")
                        .font(.largeTitle)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                ForEach(
                    store.scope(state: \.charts, action: \.charts),
                    id: \.state.id
                ) { store in
                    Section {
                        ChartView(store: store)
                    }
                }
            }
            .navigationTitle("Everyone")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gear") {
                        store.send(.view(.settingsIconTapped))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                           // TODO
                        } label: {
                            Label("Add Chart", systemImage: "rectangle.stack")
                        }
                        Button {
                           // TODO
                        } label: {
                            Label("Add Person", systemImage: "person.fill")
                        }
                        Button {
                           // TODO
                        } label: {
                            Label("Add Sticker", systemImage: "star.fill")
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(
                item: $store.scope(
                    state: \.destination?.settings,
                    action: \.destination.settings
                )
            ) { store in
                SettingsView(store: store)
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(
            initialState: AppFeature.State(
                people: [],
                charts: [
                    ChartFeature.State(
                        chart: Chart(
                            name: "Chores",
                            reward: Reward(name: "Fishing rod")
                        ),
                        stickers: StickersFeature.State(
                            stickers: [
                                Sticker(size: .large),
                                Sticker(size: .large),
                                Sticker(size: .large),
                                Sticker(size: .medium),
                                Sticker(size: .small),
                                Sticker(size: .small),
                                Sticker(size: .small),
                            ]
                        )
                    ),
                    
                    ChartFeature.State(
                        chart: Chart(
                            name: "Homework",
                            reward: Reward(name: "Batting cages")
                        ),
                        stickers: StickersFeature.State(
                            stickers: [
                                Sticker(size: .large),
                                Sticker(size: .large),
                                Sticker(size: .large),
                                Sticker(size: .medium),
                                Sticker(size: .small),
                                Sticker(size: .small),
                                Sticker(size: .small),
                            ]
                        )
                    )
                ]
            )
        ) {
            AppFeature()
        }
    )
}
