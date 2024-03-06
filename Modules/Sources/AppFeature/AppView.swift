import ComposableArchitecture
import SwiftUI

import ChartFeature
import PersonFeature
import SettingsFeature
import StickerFeature

@Reducer
public struct AppFeature {
    @Reducer(state: .equatable, action: .sendable)
    public enum Destination {
        case settings(SettingsFeature)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var people: IdentifiedArrayOf<PersonFeature.State>
        var activePersonID: UUID
        var selectedTab = 1
        
        var filteredPeople: IdentifiedArrayOf<PersonFeature.State> {
            self.people.filter { $0.id == activePersonID }
        }
        
        public init(
            destination: Destination.State? = nil,
            people: Shared<IdentifiedArrayOf<PersonFeature.State>>,
            activePersonID: UUID
        ) {
            self.destination = destination
            self._people = people
            self.activePersonID = activePersonID
        }
    }
    
    public enum Action: Sendable {
        case destination(PresentationAction<Destination.Action>)
        case view(ViewAction)
        case people(IdentifiedActionOf<PersonFeature>)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case addPersonTapped
            case personTapped(UUID)
            case settingsIconTapped
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
            case .people:
                return .none
            case let .view(action):
                switch action {
                case .addPersonTapped:
                    // TODO: open new person feature
                    return .none
                case let .personTapped(personID):
                    state.activePersonID = personID
                    return .none
                case .settingsIconTapped: // TODO: send this action
                    state.destination = .settings(SettingsFeature.State())
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
            PersonView(
                store: store.scope(
                    state: \.filteredPeople,
                    action: \.people
                ).first!
            )
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
                ForEach(store.people, id: \.id) { person in
                    Button {
                        store.send(.view(.personTapped(person.id)))
                    } label: {
                        Label(person.name, systemImage: "person")
                    }
                }
                Button {
                    store.send(.view(.addPersonTapped))
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
                store.send(.view(.settingsIconTapped))
            } label: {
                Label("Settings", systemImage: "gear")
            }
        }
    }

}

#Preview {
    let chart11 = ChartFeature.State(
        name: "Chores",
        reward: Reward(name: "Fishing rod"),
        stickers: [
            StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill"))
        ]
    )
    let chart12 = ChartFeature.State(
        name: "Homework",
        reward: Reward(name: "Fishing rod"),
        stickers: [
            StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill"))
        ]
    )
    let chart21 = ChartFeature.State(
        name: "Calm body",
        reward: Reward(name: "Batting cages"),
        stickers: [
            StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill"))
        ]
    )
    let chart31 = ChartFeature.State(
        name: "Homework",
        reward: Reward(name: "Batting cages"),
        stickers: [
            StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill"))
        ]
    )
    
    let person1 = PersonFeature.State(name: "Blob", charts: [chart11, chart12])
    let person2 = PersonFeature.State(name: "Son", charts: [chart21])
    let person3 = PersonFeature.State(name: "Daughter", charts: [chart31])
    
    return AppView(
        store: Store(
            initialState: AppFeature.State(
                people: Shared([person1, person2, person3]),
                activePersonID: person1.id
            )
        ) {
            AppFeature()
        }
    )
}
