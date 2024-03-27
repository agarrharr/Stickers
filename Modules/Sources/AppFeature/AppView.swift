import ComposableArchitecture
import SwiftUI

import AddChartFeature
import AddPersonFeature
import ChartFeature
import PersonFeature
import SettingsFeature
import StickerFeature

// TODO: extract out these functions to a shared module
func getAppSandboxDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
func getPeopleJSONURL() -> URL {
    getAppSandboxDirectory().appendingPathComponent("people.json")
}

@Reducer
public struct AppFeature {
    @Reducer(state: .equatable, action: .sendable)
    public enum Destination {
        case settings(SettingsFeature)
        case addPerson(AddPersonFeature)
        case addChart(AddChartFeature)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared(.fileStorage(getPeopleJSONURL())) var people: IdentifiedArrayOf<PersonFeature.State> = []
        var activePersonID: UUID?
        var selectedTab = 1
        
        var filteredPeople: IdentifiedArrayOf<PersonFeature.State> {
            self.people.filter { $0.id == activePersonID }
        }
        
        public init(
            destination: Destination.State? = nil,
            activePersonID: UUID? = nil
        ) {
            self.destination = destination
            self.activePersonID = activePersonID ?? self.people.first?.id
        }
    }
    
    public enum Action: Sendable {
        case destination(PresentationAction<Destination.Action>)
        case view(ViewAction)
        case people(IdentifiedActionOf<PersonFeature>)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case addPersonButtonTapped
            case settingsButtonTapped
            case addStickerButtonTapped
            case personTapped(UUID)
            case redeemButtonTapped
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
            case let .destination(.presented(.addPerson(.delegate(action)))):
                switch action {
                case let .onPersonAdded(name):
                    let person = PersonFeature.State(name: name, charts: [])
                    state.people.append(person)
                    state.activePersonID = person.id
                    return .none
                }
            case let .destination(.presented(.addChart(.delegate(action)))):
                switch action {
                case let .onChartAdded(name):
                    guard let id = state.activePersonID else { return .none }
                    let chart = ChartFeature.State(
                        name: name,
                        stickers: []
                    )
                    state.people[id: id]?.charts.append(chart)
                    state.people[id: id]?.activeChartID = chart.id
                    return .none
                }
            case .destination:
                return .none
            case let .people(.element(id: _, action: .delegate(action))):
                state.destination = .addChart(AddChartFeature.State())
                return .none
            case .people:
                return .none
            case let .view(action):
                switch action {
                case .addPersonButtonTapped:
                    state.destination = .addPerson(AddPersonFeature.State())
                    return .none
                case .settingsButtonTapped:
                    state.destination = .settings(SettingsFeature.State())
                    return .none
                case .addStickerButtonTapped:
                    if let activePersonID = state.activePersonID {
                        state.people[id: activePersonID]?.addSticker()
                    }
                    return .none
                case let .personTapped(personID):
                    state.activePersonID = personID
                    return .none
                case .redeemButtonTapped:
                    // TODO
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.people, action: \.people) {
            PersonFeature()
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
            VStack {
                if store.activePersonID == nil {
                    VStack {
                        Spacer()
                        
                        Text("No people added yet")
                        Button{
                            store.send(.view(.addPersonButtonTapped))
                        } label: {
                            Text("Add a person")
                        }
                        
                        Spacer()
                    }
                    .navigationTitle("Stickers")
                } else {
                    PersonView(
                        store: store.scope(
                            state: \.filteredPeople,
                            action: \.people
                        ).first! // TODO: fix this. Add an activePerson
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            ProfileButton(store: store)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            AddButton(store: store)
                        }
                    }
                }
                
                HStack {
                    Spacer()
                        .frame(width: 20)
                    
                    Button {
                        store.send(.view(.settingsButtonTapped))
                    } label: {
                        Image(systemName: "gear")
                            .imageScale(.large)
                            .accessibilityLabel("Settings")
                    }
                    
                    Spacer()
                    
                    Button {
                        store.send(.view(.addStickerButtonTapped))
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .accessibilityLabel("Add sticker")
                    }
                    
                    Spacer()
                        .frame(width: 20)
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
                state: \.destination?.addPerson,
                action: \.destination.addPerson
            )
        ) { store in
            AddPersonView(store: store)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.addChart,
                action: \.destination.addChart
            )
        ) { store in
            AddChartView(store: store)
               .presentationDragIndicator(.visible)
               .presentationDetents([.medium])
        }
        .navigationViewStyle(.stack)
    }
    
    struct ProfileButton: View {
        var store: StoreOf<AppFeature>

        var body: some View {
            Menu {
                ForEach(store.people, id: \.id) { person in
                    Button {
                        store.send(.view(.personTapped(person.id)))
                    } label: {
                        Label(person.name, systemImage: "person")
                    }
                }
                Button {
                    store.send(.view(.addPersonButtonTapped))
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
                store.send(.view(.redeemButtonTapped))
            } label: {
                Image(systemName: "gift")
                    .accessibilityLabel("Redeem stickers")
            }
        }
    }
}

#Preview {
//    let chart11 = ChartFeature.State(
//        name: "Chores",
//        reward: Reward(name: "Fishing rod"),
//        stickers: [
//            StickerFeature.State(sticker: Sticker(imageName: "face-0"))
//        ]
//    )
//    let chart12 = ChartFeature.State(
//        name: "Homework",
//        reward: Reward(name: "Fishing rod"),
//        stickers: [
//            StickerFeature.State(sticker: Sticker(imageName: "face-0"))
//        ]
//    )
//    let chart21 = ChartFeature.State(
//        name: "Calm body",
//        reward: Reward(name: "Batting cages"),
//        stickers: [
//            StickerFeature.State(sticker: Sticker(imageName: "face-0"))
//        ]
//    )
//    let chart31 = ChartFeature.State(
//        name: "Homework",
//        reward: Reward(name: "Batting cages"),
//        stickers: [
//            StickerFeature.State(sticker: Sticker(imageName: "face-0"))
//        ]
//    )
//    
//    let person1 = PersonFeature.State(name: "Blob", charts: [chart11, chart12])
//    let person2 = PersonFeature.State(name: "Son", charts: [chart21])
//    let person3 = PersonFeature.State(name: "Daughter", charts: [chart31])
    
    return AppView(
        store: Store(
            initialState: AppFeature.State(
//                people: [person1, person2, person3]
            )
        ) {
            AppFeature()
        }
    )
}

#Preview("Empty state") {
    AppView(
        store: Store(
            initialState: AppFeature.State()
        ) {
            AppFeature()
        }
    )
   
}
