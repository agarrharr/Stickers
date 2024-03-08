import ComposableArchitecture
import SwiftUI

@Reducer
public struct SettingsFeature {
    @Reducer(state: .equatable, action: .sendable)
    public enum Path {
        @ReducerCaseIgnored
        case people
    }
    
    @ObservableState
    public struct State: Equatable {
        var path = StackState<Path.State>()
        
        public init(path: StackState<Path.State> = StackState<Path.State>()) {
            self.path = path
        }
    }
    
    public enum Action: Sendable {
        case path(StackAction<Path.State, Path.Action>)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    public init() {}
}

public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    // Why am I initially hiding the list?
    // It's because of a bug with SwiftUI
    // I want to have a large title, but if
    // there is a list, it shrinks down
    // So I wait a split second to show the list
    // https://developer.apple.com/forums/thread/737787
    @State private var showList: Bool = false
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                if showList {
                    List {
                        Section("Setup") {
                            NavigationLink(state: SettingsFeature.Path.State.people) {
                                HStack {
                                    Image(systemName: "person.crop.square.fill")
                                        .resizable()
                                        .frame(width: 26, height: 26)
                                        .foregroundStyle(.white, .blue)
                                    Text("People")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        } destination: { store in
            switch store.state {
            case .people:
                Text("List of people")
                    .navigationTitle("People")
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showList = true
            }
        }
    }
}

#Preview {
    SettingsView(
        store: Store(
            initialState: SettingsFeature.State()
        ) {
            SettingsFeature()
        }
    )
}
