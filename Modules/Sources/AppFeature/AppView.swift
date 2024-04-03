import ComposableArchitecture
import SwiftUI

import PeopleFeature


@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        var people: PeopleFeature.State
        
        public init() {
            self.people = PeopleFeature.State()
        }
    }

    public enum Action: Sendable {
        case people(PeopleFeature.Action)
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .people:
                return .none
            }
        }
        
        Scope(state: \.people, action: \.people) {
            PeopleFeature()
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
        PeopleView(
            store: self.store.scope(
                state: \.people,
                action: \.people
            )
        )
    }
}

#Preview {
    return AppView(
        store: Store(
            initialState: AppFeature.State(
                // people: [person1, person2, person3]
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
