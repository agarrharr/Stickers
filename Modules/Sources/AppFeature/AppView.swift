import ComposableArchitecture
import SwiftUI

import AddSticker
import ChartFeature
import Models
import PeopleButtons
import SettingsFeature
import StickersFeature

@Reducer
public struct AppFeature {
    @Reducer(state: .equatable, action: .sendable)
    public enum Destination {
        case settings(SettingsFeature)
        case addSticker(AddStickerFeature)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var people: IdentifiedArrayOf<Person>
        @Shared var charts: IdentifiedArrayOf<ChartFeature.State>
        var personFilter: Person?
        
        public init(
            destination: Destination.State? = nil,
            people: Shared<IdentifiedArrayOf<Person>>,
            charts: Shared<IdentifiedArrayOf<ChartFeature.State>>,
            personFilter: Person? = nil
        ) {
            self.destination = destination
            self._people = people
            self._charts = charts
            self.personFilter = personFilter
        }
    }
    
    public enum Action: Sendable {
        case destination(PresentationAction<Destination.Action>)
        case charts(IdentifiedActionOf<ChartFeature>)
        case view(ViewAction)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case addChartTapped
            case addPersonTapped
            case addStickerTapped
            case personTapped(Person)
            case settingsIconTapped
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
            case .destination:
                return .none
            case .charts:
                return .none
            case let .view(action):
                switch action {
                case .addChartTapped:
                    return .none
                case .addPersonTapped:
                    return .none
                case .addStickerTapped:
                    state.destination = .addSticker(
                        AddStickerFeature.State(
                            people: state.$people,
                            charts: state.$charts
                        )
                    )
                    return .none
                case let .personTapped(person):
                    state.personFilter = person == state.personFilter ? nil : person
                    return .none
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
    
    private var title: String {
        guard let person = store.personFilter else {
            return "Everyone"
        }
        return person.name
    }
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            GeometryReader { reader in
                List {
                    Section {
                        // Empty section
                    } header: {
                        PeopleButtonsView(people: store.people) {
                            store.send(.view(.personTapped($0)))
                        }
                        .textCase(nil)
                        // Make the header the full width so that the buttons can
                        // scroll to the edges and not get cut off
                        .frame(width: reader.size.width, alignment: .leading)
                    }
                    ForEach(
                        store.scope(state: \.charts, action: \.charts),
                        id: \.state.id
                    ) { childStore in
                        if (store.personFilter == nil || store.personFilter == childStore.chart.person) {
                            Section {
                                ChartView(store: childStore)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gear") {
                        store.send(.view(.settingsIconTapped))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            store.send(.view(.addChartTapped))
                        } label: {
                            Label("Add Chart", systemImage: "rectangle.stack")
                        }
                        Button {
                            store.send(.view(.addPersonTapped))
                        } label: {
                            Label("Add Person", systemImage: "person.fill")
                        }
                        Button {
                            store.send(.view(.addStickerTapped))
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
                    .presentationDragIndicator(.visible)
            }
            .sheet(
                item: $store.scope(
                    state: \.destination?.addSticker,
                    action: \.destination.addSticker
                )
            ) { store in
                AddStickerView(store: store)
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    let person1 = Person(name: "Blob")
    let person2 = Person(name: "Son")
    let person3 = Person(name: "Daughter")
    
    return AppView(
        store: Store(
            initialState: AppFeature.State(
                people: Shared([person1, person2, person3]),
                charts: Shared([
                    ChartFeature.State(
                        chart: Chart(
                            name: "Chores",
                            reward: Reward(name: "Fishing rod"),
                            stickers: StickersFeature.State(
                                stickers: [
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .medium),
                                    Sticker(size: .small),
                                    Sticker(size: .small),
                                    Sticker(size: .small),
                                ]
                            ),
                            person: person1
                        )
                    ),
                    
                    ChartFeature.State(
                        chart: Chart(
                            name: "Homework",
                            reward: Reward(name: "Batting cages"),
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
                            ),
                            person: person2
                        )
                    )
                ])
            )
        ) {
            AppFeature()
        }
    )
}
