import ComposableArchitecture
import ChartFeature
import Models
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
            VStack {
                HStack {
                    Image(systemName: "person.circle")
                        .font(.largeTitle)
                    Image(systemName: "person.circle")
                        .font(.largeTitle)
                    Image(systemName: "person.circle")
                        .font(.largeTitle)
                    Spacer()
                }
                .padding(.horizontal)
                ForEach(
                    store.scope(state: \.charts, action: \.charts),
                    id: \.state.id
                ) { store in
                    ChartView(store: store)
                }
                Spacer()
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
                        id: UUID(),
                        chart: Chart(
                            id: UUID(),
                            name: "Chores",
                            reward: Reward(name: "Fishing rod"),
                            stickers: [
                                Sticker(id: UUID(), size: .large),
                                Sticker(id: UUID(), size: .large),
                                Sticker(id: UUID(), size: .large),
                                Sticker(id: UUID(), size: .medium),
                                Sticker(id: UUID(), size: .small),
                                Sticker(id: UUID(), size: .small),
                                Sticker(id: UUID(), size: .small),
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
