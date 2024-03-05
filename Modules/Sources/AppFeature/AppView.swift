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
        case addStickerToChart(AddStickerToChartFeature)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var people: IdentifiedArrayOf<Person>
        @Shared var charts: IdentifiedArrayOf<ChartFeature.State>
        var activePersonID: UUID
        var activeChartID: UUID
        var selectedTab = 1
        
        public init(
            destination: Destination.State? = nil,
            people: Shared<IdentifiedArrayOf<Person>>,
            charts: Shared<IdentifiedArrayOf<ChartFeature.State>>,
            activePersonID: UUID,
            activeChartID: UUID
        ) {
            self.destination = destination
            self._people = people
            self._charts = charts
            self.activePersonID = activePersonID
            self.activeChartID = activeChartID
        }
    }
    
    public enum Action: Sendable {
        case destination(PresentationAction<Destination.Action>)
        case charts(IdentifiedActionOf<ChartFeature>)
        case view(ViewAction)
        case selectChart(UUID)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case addChartTapped
            case addPersonTapped
            case addStickerTapped
            case personTapped(Person)
            case profileButtonTapped
//            case settingsIconTapped
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
            case let .charts(.element(id: _, action: action)):
                switch action {
                case let .delegate(action):
                    switch action {
                    case let .onAddButtonTap(chartID):
                        state.destination = .addStickerToChart(
                            AddStickerToChartFeature.State(
                                charts: state.$charts,
                                chartID: chartID
                            )
                        )
                        return .none
                    }
                default:
                    return .none
                }
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
                    state.activePersonID = person.id
                    return .none
                case .profileButtonTapped:
                    return .none
                    
//                case .settingsIconTapped:
//                    state.destination = .settings(SettingsFeature.State())
//                    return .none
                }
            case let .selectChart(chartID):
                state.activeChartID = chartID
                return .none
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
        store.charts[id: store.activeChartID]?.chart.name ?? "Chart"
    }
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            TabView(
                selection:  $store.activeChartID.sending(\.selectChart),
                content:  {
                    ForEach(
                        store.scope(state: \.charts, action: \.charts),
                        id: \.state.id
                    ) { childStore in
                        if (store.activePersonID == childStore.chart.person.id) {
                            Text("Stickers for \(childStore.chart.name)")
                                .tabItem {
                                    Text(childStore.chart.name)
                                }
                                .tag(childStore.chart.id)
                        }
                    }
                }
            )
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ProfileButton(store: store)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AddButton(store: store)
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
        }
    }
    
    struct ProfileButton: View {
        var store: StoreOf<AppFeature>

        var body: some View {
            Menu {
                // TODO: make this dynamic with each person
                Button {
                    // TODO: send the person in the action
                    store.send(.view(.profileButtonTapped))
                } label: {
                    Label("Blob", systemImage: "person")
                }
                Button {
                    // TODO: send the person in the action
                    store.send(.view(.profileButtonTapped))
                } label: {
                    Label("Son", systemImage: "cat.fill")
                }
                Button {
                    // TODO: send the person in the action
                    store.send(.view(.profileButtonTapped))
                } label: {
                    Label("Daughter", systemImage: "fish.fill")
                }
                Button {
                    // TODO: send the person in the action
                    store.send(.view(.profileButtonTapped))
                } label: {
                    Label("Add person", systemImage: "person.fill.badge.plus")
                }
            } label: {
                Label("Switch profile", systemImage: "person.fill")
            }
        }
    }
    
    struct AddButton: View {
        var store: StoreOf<AppFeature>
        
        var body: some View {
            Button {
                store.send(.view(.addChartTapped))
            } label: {
                Label("Add chart", systemImage: "plus")
            }
        }
    }

}

#Preview {
    let person1 = Person(name: "Blob")
    let person2 = Person(name: "Son")
    let person3 = Person(name: "Daughter")
    
    let chart1 = Chart(
        name: "Chores",
        reward: Reward(name: "Fishing rod"),
        stickers: StickersFeature.State(amount: 98),
        person: person1
    )
    let chart2 = Chart(
        name: "Homework",
        reward: Reward(name: "Fishing rod"),
        stickers: StickersFeature.State(amount: 98),
        person: person1
    )
    
    return AppView(
        store: Store(
            initialState: AppFeature.State(
                people: Shared([person1, person2, person3]),
                charts: Shared([
                    ChartFeature.State(chart: chart1),
                    ChartFeature.State(chart: chart2),
                    
                    ChartFeature.State(
                        chart: Chart(
                            name: "Homework",
                            reward: Reward(name: "Batting cages"),
                            stickers: StickersFeature.State(amount: 38),
                            person: person2
                        )
                    )
                ]),
                activePersonID: person1.id,
                activeChartID: chart1.id
            )
        ) {
            AppFeature()
        }
    )
}
