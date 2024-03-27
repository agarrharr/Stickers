import ComposableArchitecture
import SwiftUI

@Reducer
public struct SettingsFeature {
    @Reducer(state: .equatable, action: .sendable)
    public enum Path {
        @ReducerCaseIgnored
        case people
        @ReducerCaseIgnored
        case charts
        @ReducerCaseIgnored
        case rewards
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
    
    @Environment(\.sizeCategory) var sizeCategory
    
    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                if showList {
                    List {
                        Section("Setup") {
                            NavigationLink(state: SettingsFeature.Path.State.people) {
                                HStack {
                                    Image(systemName: "person.crop.square.fill")
                                        .padding(4)
                                        .background(.blue)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                                    Text("People")
                                }
                            }
                            NavigationLink(state: SettingsFeature.Path.State.charts) {
                                HStack {
                                    Image(systemName: "star.square.fill")
                                        .padding(4)
                                        .background(.yellow)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                                    Text("Charts")
                                }
                            }
                            NavigationLink(state: SettingsFeature.Path.State.rewards) {
                                HStack {
                                    Image(systemName: "gift.fill")
                                        .padding(4)
                                        .background(.purple)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                                    Text("Rewards")
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
                PeopleSettingsView(store: Store(initialState: PeopleSettingsFeature.State()) {
                    PeopleSettingsFeature()
                })
                .navigationTitle("People")
            case .charts:
                Text("List of charts")
                    .navigationTitle("Charts")
            case .rewards:
                Text("List of rewards")
                    .navigationTitle("Rewards")
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showList = true
            }
        }
    }
    
    var cornerRadius: CGFloat {
            switch sizeCategory {
            case .extraSmall, .small: 4
            case .medium: 6
            default: 8
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
