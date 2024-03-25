import ComposableArchitecture
import SwiftUI

@Reducer
public struct AddPersonFeature {
    @ObservableState
    public struct State: Equatable {
        var name = ""
        
        public init() {
        }
    }
    
    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case view(ViewAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case addButtonTapped
        }
        
        @CasePathable
        public enum DelegateAction: Sendable {
            case onPersonAdded(String)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .addButtonTapped:
                    return .run { [name = state.name] send in
                        await send(.delegate(.onPersonAdded(name)))
                        await dismiss()
                    }
                }
            case .delegate:
                return .none
            case .binding:
                return .none
            }
        }
    }
    
    public init() {}
}

public struct AddPersonView: View {
    @Bindable var store: StoreOf<AddPersonFeature>
    
    public init(store: StoreOf<AddPersonFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            List {
                Section {
                    LabeledContent {
                        TextField("Add name", text: $store.name)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Name")
                    }
                    
                }
            }
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        store.send(.view(.addButtonTapped))
                    } label: {
                        Text("Add")
                    }
                    .disabled(store.name == "")
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AddPersonView(store: Store(
            initialState: AddPersonFeature.State()
        ) {
            AddPersonFeature()
        })
    }
}
