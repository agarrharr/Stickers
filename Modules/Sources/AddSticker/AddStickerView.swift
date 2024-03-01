import ComposableArchitecture
import SwiftUI

import ChartFeature
import Models
import StickersFeature

import PeopleButtons

@Reducer
public struct AddStickerFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared var people: IdentifiedArrayOf<Person>
        @Shared var charts: IdentifiedArrayOf<ChartFeature.State>
        var personFilter: Person?
        
        public init(
            people: Shared<IdentifiedArrayOf<Person>>,
            charts: Shared<IdentifiedArrayOf<ChartFeature.State>>,
            personFilter: Person? = nil
        ) {
            self._people = people
            self._charts = charts
            self.personFilter = personFilter
        }
    }
    
    public enum Action: Sendable {
        case charts(IdentifiedActionOf<ChartFeature>)
        case view(ViewAction)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case personTapped(Person)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case let .personTapped(person):
                    state.personFilter = person == state.personFilter ? nil : person
                    return .none
                }
            case .charts:
                return .none
            }
        }
        .forEach(\.charts, action: \.charts) {
            ChartFeature()
        }
    }
    
    public init() {}
}

public struct AddStickerView: View {
    var store: StoreOf<AddStickerFeature>
    
    public init(store: StoreOf<AddStickerFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                PeopleButtonsView(people: store.people) {
                    store.send(.view(.personTapped($0)))
                }
                ForEach(
                    store.scope(state: \.charts, action: \.charts),
                    id: \.state.id
                ) { childStore in
                    if (store.personFilter == nil || store.personFilter == childStore.chart.person) {
                        Text(childStore.chart.name)
                    }
                }
                Spacer()
            }
            .navigationTitle("Add Sticker")
        }
    }
}

#Preview {
    let person1 = Person(name: "Blob")
    let person2 = Person(name: "Son")
    let person3 = Person(name: "Daughter")
    
    return AddStickerView(
        store: Store(
            initialState: AddStickerFeature.State(
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
            AddStickerFeature()
        }
    )
}
