import ComposableArchitecture
import ChartFeature
import Models
import StickersFeature
import SwiftUI

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
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
        case charts(IdentifiedActionOf<ChartFeature>)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { _, _ in
            return .none
        }
        .forEach(\.charts, action: \.charts) {
            ChartFeature()
        }
    }
    
    public init() {}
}

public struct AppView: View {
    var store: StoreOf<AppFeature>
    
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
                        // TODO:
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        // TODO:
                    }
                }
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
