import ComposableArchitecture
import SwiftUI

import PeopleFeature
import SettingsFeature

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        var people: PeopleFeature.State
        var settings: SettingsFeature.State
        
        public init() {
            self.people = PeopleFeature.State()
            self.settings = SettingsFeature.State()
        }
    }

    public enum Action: Sendable {
        case people(PeopleFeature.Action)
        case settings(SettingsFeature.Action)
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .people:
                return .none
            case .settings:
                return .none
            }
        }
        
        Scope(state: \.people, action: \.people) {
            PeopleFeature()
        }
        
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
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
        TabView {
            PeopleView(
                store: self.store.scope(
                    state: \.people,
                    action: \.people
                )
            )
            .tabItem {
                Label("Charts", systemImage: "person.crop.rectangle.stack.fill")
            }
            
            Text("Rewards")
                .tabItem {
                    Label("Rewards", systemImage: "gift.fill")
                }
            
            SettingsView(store: store.scope(state: \.settings, action: \.settings))
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
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
