import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State {
        var people: IdentifiedArrayOf<Person>
        
        public init(people: IdentifiedArrayOf<Person>) {
            self.people = people
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
        Text("View")
    }
}

#Preview {
    AppView(
        store: Store(
            initialState: AppFeature.State(
                people: []
            )
        ) {
            AppFeature()
        }
    )
}
