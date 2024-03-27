import ComposableArchitecture
import SwiftUI

import PersonFeature

func getAppSandboxDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
func getPeopleJSONURL() -> URL {
    getAppSandboxDirectory().appendingPathComponent("people.json")
}

@Reducer
public struct PeopleSettingsFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.fileStorage(getPeopleJSONURL())) var people: IdentifiedArrayOf<PersonFeature.State> = []
        
        public init() {}
    }
    
    public enum Action: Sendable {
        case people(IdentifiedActionOf<PersonFeature>)
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
    
    public init() {}
}

struct PeopleSettingsView: View {
    @Bindable var store: StoreOf<PeopleSettingsFeature>
    
    var body: some View {
        List {
            ForEach(store.people, id: \.id) { person in
                Text(person.name)
            }
        }
    }
}

#Preview {
    PeopleSettingsView(store: Store(initialState: PeopleSettingsFeature.State()) {
        PeopleSettingsFeature()
    })
}
