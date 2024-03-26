import ComposableArchitecture
import SwiftUI

@Reducer
public struct AddChartFeature {
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
            case onChartAdded(String)
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
                        await send(.delegate(.onChartAdded(name)))
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

public struct AddChartView: View {
    @Bindable var store: StoreOf<AddChartFeature>
    
    public init(store: StoreOf<AddChartFeature>) {
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
            .navigationTitle("Add Chart")
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
        AddChartView(store: Store(
            initialState: AddChartFeature.State()
        ) {
            AddChartFeature()
        })
    }
}
