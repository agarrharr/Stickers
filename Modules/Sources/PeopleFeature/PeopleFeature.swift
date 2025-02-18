import ComposableArchitecture
import SwiftUI

import AddChartFeature
import AddPersonFeature
import ChartFeature
import PersonFeature
import StickerFeature

@Reducer
public struct PeopleFeature {
    @Reducer(state: .equatable, action: .sendable)
    public enum Destination {
        case addPerson(AddPersonFeature)
        case addChart(AddChartFeature)
    }

    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared(.people) var people
        var activePersonID: UUID?

        var selectedTab = 1

        var filteredPeople: IdentifiedArrayOf<Person> {
            people.filter { $0.id == activePersonID }
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
//        case people(IdentifiedActionOf<PersonFeature>)

        @CasePathable
        public enum ViewAction: Sendable {
            case addPersonButtonTapped
            case addStickerButtonTapped
            case personTapped(UUID)
            case addChartButtonTapped
        }
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .destination(.presented(.addPerson(.delegate(action)))):
                switch action {
                case let .onPersonAdded(name):
//                    let person = PersonFeature.State(name: name, charts: [])
//                    _ = state.$people.withLock {
//                        $0.append(person)
//                    }
//                    state.activePersonID = person.id
                    return .none
                }

            case let .destination(.presented(.addChart(.delegate(action)))):
                switch action {
                case let .onChartAdded(name, _):
                    guard let id = state.activePersonID else { return .none }
                    // TODO: use the color
//                    let chart = ChartFeature.State(
//                        name: name,
//                        stickers: []
//                    )
//                    _ = state.$people.withLock {
//                        $0[id: id]?.charts.append(chart)
//                    }
//                    _ = state.$people.withLock {
//                        $0[id: id]?.activeChartID = chart.id
//                    }
                    return .none
                }
            case .destination:
                return .none
//            case let .people(.element(id: _, action: .delegate(action))):
//                switch action {
//                case .onAddChartButtonTapped:
//                    state.destination = .addChart(AddChartFeature.State())
//                }
//                return .none
//            case .people:
//                return .none
            case let .view(action):
                switch action {
                case .addPersonButtonTapped:
                    state.destination = .addPerson(AddPersonFeature.State())
                    return .none
                case .addStickerButtonTapped:
                    if let activePersonID = state.activePersonID {
//                        state.$people.withLock {
//                            $0[id: activePersonID]?.addSticker()
//                        }
                    }
                    return .none
                case let .personTapped(personID):
                    state.activePersonID = personID
                    return .none
                case .addChartButtonTapped:
                    state.destination = .addChart(AddChartFeature.State())
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
//        .forEach(\.people, action: \.people) {
//            PersonFeature()
//        }
    }

    public init() {}
}

public struct PeopleView: View {
    @Bindable var store: StoreOf<PeopleFeature>

    public init(store: StoreOf<PeopleFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                if let activePersonID = store.activePersonID {
                    if let person = Shared(store.$people[id: activePersonID]) {
                        PersonView(
                            store: Store(
                                initialState: PersonFeature.State(
                                    person: person,
                                    activeChartID: UUID() // TODO: fix
                                )
                            ) {
                                PersonFeature()
                            }
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
                } else {
                    VStack {
                        Spacer()

                        Text("No people added yet")
                        Button {
                            store.send(.view(.addPersonButtonTapped))
                        } label: {
                            Text("Add a person")
                        }

                        Spacer()
                    }
                    .navigationTitle("Stickers")
                }

                Button(action: {
                    store.send(.view(.addStickerButtonTapped))
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(20)
            }
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
                .presentationDetents([.medium, .large])
        }
        .navigationViewStyle(.stack)
    }

    struct ProfileButton: View {
        var store: StoreOf<PeopleFeature>

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
        var store: StoreOf<PeopleFeature>

        var body: some View {
            Button {
                store.send(.view(.addChartButtonTapped))
            } label: {
                Image(systemName: "plus")
                    .accessibilityLabel("Add Chart")
            }
        }
    }
}

//#Preview {
//    let chart11 = ChartFeature.State(
//        name: "Chores",
//        reward: Reward(name: "Fishing rod"),
//        stickers: [
//            StickerFeature.State(sticker: Sticker(imageName: "face-0")),
//        ]
//    )
//    let chart12 = ChartFeature.State(
//        name: "Homework",
//        reward: Reward(name: "Fishing rod"),
//        stickers: [
//            StickerFeature.State(sticker: Sticker(imageName: "face-0")),
//        ]
//    )
//    let chart21 = ChartFeature.State(
//        name: "Calm body",
//        reward: Reward(name: "Batting cages"),
//        stickers: [
//            StickerFeature.State(sticker: Sticker(imageName: "face-0")),
//            StickerFeature.State(sticker: Sticker(imageName: "face-1")),
//        ]
//    )
//    let chart31 = ChartFeature.State(
//        name: "Homework",
//        reward: Reward(name: "Batting cages"),
//        stickers: [
//            StickerFeature.State(sticker: Sticker(imageName: "face-0")),
//            StickerFeature.State(sticker: Sticker(imageName: "face-1")),
//            StickerFeature.State(sticker: Sticker(imageName: "face-2")),
//        ]
//    )
//
//    let person1 = PersonFeature.State(name: "Blob", charts: [chart11, chart12])
//    let person2 = PersonFeature.State(name: "Son", charts: [chart21])
//    let person3 = PersonFeature.State(name: "Daughter", charts: [chart31])
//    @Shared(.people) var people = [person1, person2, person3]
//
//    PeopleView(
//        store: Store(initialState: PeopleFeature.State()) {
//            PeopleFeature()
//        }
//    )
//}
//
//#Preview("Empty state") {
//    PeopleView(
//        store: Store(
//            initialState: PeopleFeature.State()
//        ) {
//            PeopleFeature()
//        }
//    )
//}
