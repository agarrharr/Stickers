import ComposableArchitecture
import SwiftUI

@Reducer
public struct SettingsFeature {
    @Reducer(state: .equatable, action: .sendable)
    public enum Destination {
        @ReducerCaseIgnored
        case stickerValues
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        
        public init(destination: Destination.State? = nil) {
            self.destination = destination
        }
    }
    
    public enum Action: Sendable {
        case destination(PresentationAction<Destination.Action>)
        case view(ViewAction)
        
        @CasePathable
        public enum ViewAction {
            case stickerValuesButtonTapped
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
            case let .view(action):
                switch action {
                case .stickerValuesButtonTapped:
                    state.destination = .stickerValues
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    public init() {}
}

public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section("Stickers") {
                    Button {
                        store.send(.view(.stickerValuesButtonTapped))
                    } label : {
                        Text("Button")
                    }
                }
            }
            .navigationDestination(
                isPresented: Binding(
                    get: {
                        switch store.destination {
                        case .stickerValues:
                            return true
                        default:
                            return false
                        }
                    },
                    set: { _ in
                        store.send(.destination(.dismiss))
                    }
                ),
                destination: {
                    Text("Sticker Values")
                }
            )
            .navigationTitle("Settings")
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
