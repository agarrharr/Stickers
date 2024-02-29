import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State {
        var people: IdentifiedArrayOf<Person>
        var charts: IdentifiedArrayOf<Chart>
        
        public init(people: IdentifiedArrayOf<Person>, charts: IdentifiedArrayOf<Chart>) {
            self.people = people
            self.charts = charts
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
                ForEach(store.charts, id: \.id) { chart in
                    Text(chart.name)
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
                    Chart(
                        id: UUID(),
                        name: "Chores",
                        reward: Reward(name: "Fishing pole"),
                        stickers: []
                    )
                ]
            )
        ) {
            AppFeature()
        }
    )
}
