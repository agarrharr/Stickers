//import ComposableArchitecture
//import SwiftUI
//
//import ChartFeature
//import Models
//import StickersFeature
//
//import PeopleButtons
//
//@Reducer
//public struct AddStickerFeature {
//    @ObservableState
//    public struct State: Equatable {
//        @Shared var people: IdentifiedArrayOf<Person>
//        @Shared var charts: IdentifiedArrayOf<ChartFeature.State>
//        var personFilter: Person?
//        
//        public init(
//            people: Shared<IdentifiedArrayOf<Person>>,
//            charts: Shared<IdentifiedArrayOf<ChartFeature.State>>,
//            personFilter: Person? = nil
//        ) {
//            self._people = people
//            self._charts = charts
//            self.personFilter = personFilter
//        }
//    }
//    
//    public enum Action: Sendable {
//        case charts(IdentifiedActionOf<ChartFeature>)
//        case view(ViewAction)
//        
//        @CasePathable
//        public enum ViewAction: Sendable {
//            case personTapped(Person)
//            case behaviorButtonTapped(UUID, Behavior)
//            case addAmountButtonTapped(UUID, Int)
//        }
//    }
//    
//    @Dependency(\.dismiss) var dismiss
//    
//    public var body: some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case let .view(action):
//                switch action {
//                case let .personTapped(person):
//                    state.personFilter = person == state.personFilter ? nil : person
//                    return .none
//                case let .behaviorButtonTapped(chartID, behavior):
//                    state.charts[id: chartID]?.chart.stickers.amount += behavior.amount
//                    return .run { _ in
//                        await dismiss()
//                    }
//                case let .addAmountButtonTapped(chartID, amount):
//                    state.charts[id: chartID]?.chart.stickers.amount += amount
//                    return .run { _ in
//                        await dismiss()
//                    }
//                }
//            case .charts:
//                return .none
//            }
//        }
//        .forEach(\.charts, action: \.charts) {
//            ChartFeature()
//        }
//    }
//    
//    public init() {}
//}
//
//public struct AddStickerView: View {
//    var store: StoreOf<AddStickerFeature>
//    
//    public init(store: StoreOf<AddStickerFeature>) {
//        self.store = store
//    }
//    
//    public var body: some View {
//        NavigationView {
//            GeometryReader { reader in
//                List {
//                    Section {
//                        // Empty section
//                    } header: {
//                        PeopleButtonsView(people: store.people) {
//                            store.send(.view(.personTapped($0)))
//                        }
//                        .textCase(nil)
//                        // Make the header the full width so that the buttons can
//                        // scroll to the edges and not get cut off
//                        .frame(width: reader.size.width, alignment: .leading)
//                    }
//                    ForEach(
//                        store.scope(state: \.charts, action: \.charts),
//                        id: \.state.id
//                    ) { childStore in
//                        if (store.personFilter == nil || store.personFilter == childStore.chart.person) {
//                            Section {
//                                ForEach(childStore.chart.behaviors, id: \.id) { behavior in
//                                    Button {
//                                        store.send(.view(.behaviorButtonTapped(childStore.chart.id, behavior)))
//                                    } label: {
//                                        HStack {
//                                            Text(behavior.name)
//                                            Spacer()
//                                            Text("\(behavior.amount)")
//                                        }
//                                    }
//                                }
//                                Button {
//                                    store.send(.view(.addAmountButtonTapped(childStore.chart.id, 1)))
//                                } label: {
//                                    Text("+1")
//                                }
//                                Button {
//                                    store.send(.view(.addAmountButtonTapped(childStore.chart.id, 5)))
//                                } label: {
//                                    Text("+5")
//                                }
//                                Button {
//                                    store.send(.view(.addAmountButtonTapped(childStore.chart.id, 10)))
//                                } label: {
//                                    Text("+10")
//                                }
//                            } header: {
//                                Text(childStore.chart.name)
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Add Sticker")
//        }
//    }
//}
//
//#Preview {
//    let person1 = Person(name: "Blob")
//    let person2 = Person(name: "Son")
//    let person3 = Person(name: "Daughter")
//    
//    return AddStickerView(
//        store: Store(
//            initialState: AddStickerFeature.State(
//                people: Shared([person1, person2, person3]),
//                charts: Shared([
//                    ChartFeature.State(
//                        chart: Chart(
//                            name: "Chores",
//                            reward: Reward(name: "Fishing rod"),
//                            behaviors: [
//                                Behavior(name: "Load dishwasher", amount: 1),
//                                Behavior(name: "Sweep bathroom", amount: 5),
//                                Behavior(name: "Put away clothes", amount: 2)
//                            ],
//                            person: person1
//                        )
//                    ),
//                    
//                    ChartFeature.State(
//                        chart: Chart(
//                            name: "Homework",
//                            reward: Reward(name: "Batting cages"),
//                            behaviors: [
//                                Behavior(name: "Math homework", amount: 1),
//                                Behavior(name: "Read", amount: 2)
//                            ],
//                            person: person2
//                        )
//                    )
//                ])
//            )
//        ) {
//            AddStickerFeature()
//        }
//    )
//}
