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
        
        public init(
            people: Shared<IdentifiedArrayOf<Person>>,
            charts: Shared<IdentifiedArrayOf<ChartFeature.State>>
        ) {
            self._people = people
            self._charts = charts
        }
    }
    
    public enum Action: Sendable {
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
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
                PeopleButtonsView(
                    people: store.people,
                    onTap: { person in }
                )
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
