import ComposableArchitecture
import SwiftUI

public struct QuickAction: Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var amount: Int

    public init(id: UUID = UUID(), name: String = "", amount: Int = 1) {
        self.id = id
        self.name = name
        self.amount = amount
    }
}

public enum BackgroundColor: String, Sendable {
    case yellow
    case orange
    case red
    case purple
    case blue
    case green
    case gray
    case black
    case brown

    public var color: Color {
        switch self {
        case .yellow: .yellow
        case .orange: .orange
        case .red: .red
        case .purple: .purple
        case .blue: .blue
        case .green: .green
        case .gray: .gray
        case .black: .black
        case .brown: .brown
        }
    }
}

@Reducer
public struct AddChartFeature {
    @ObservableState
    public struct State: Equatable {
        var name = ""
        var color: BackgroundColor = .yellow
        var quickActions: IdentifiedArrayOf<QuickAction> = []

        public init() {}
    }

    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case view(ViewAction)
        case delegate(DelegateAction)

        @CasePathable
        public enum ViewAction: Sendable {
            case addButtonTapped
            case cancelButtonTapped
            case colorButtonTapped(BackgroundColor)
            case addQuickActionButtonTapped
            case removeQuickAction(QuickAction.ID)
            case quickActionNameChanged(QuickAction.ID, String)
            case quickActionAmountChanged(QuickAction.ID, Int)
        }

        @CasePathable
        public enum DelegateAction: Sendable {
            case onChartAdded(String, BackgroundColor, IdentifiedArrayOf<QuickAction>)
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
                    return .run { [name = state.name, color = state.color, quickActions = state.quickActions] send in
                        await send(.delegate(.onChartAdded(name, color, quickActions)))
                    }
                case .cancelButtonTapped:
                    return .run { _ in
//                        await dismiss()
                    }
                case let .colorButtonTapped(color):
                    state.color = color
                    return .none
                case .addQuickActionButtonTapped:
                    state.quickActions.append(QuickAction())
                    return .none
                case let .removeQuickAction(id):
                    state.quickActions.remove(id: id)
                    return .none
                case let .quickActionNameChanged(id, name):
                    state.quickActions[id: id]?.name = name
                    return .none
                case let .quickActionAmountChanged(id, amount):
                    state.quickActions[id: id]?.amount = amount
                    return .none
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

    let colors: [BackgroundColor] = [.yellow, .orange, .red, .purple, .blue, .green, .gray, .black, .brown]
    
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
                Section("Color") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                            ForEach(colors, id: \.self) { color in
                                Button {
                                    store.send(.view(.colorButtonTapped(color)))
                                    print(color.rawValue)
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(color.color)
                                            .frame(width: 40)
                                        if store.color == color {
                                            Circle()
                                                .stroke(color.color, lineWidth: 4)
                                                .frame(width: 50)
                                        }
                                    }
                                }
                                .frame(height: 50)
                                .buttonStyle(.borderless) // This is to prevent a bug where EVERY button gets triggered when you tap on one of them
                            }
                        }
                }
                Section("Quick Actions") {
                    ForEach(store.quickActions) { action in
                        HStack {
                            TextField("Name", text: Binding(
                                get: { action.name },
                                set: { store.send(.view(.quickActionNameChanged(action.id, $0))) }
                            ))
                            Stepper(
                                "+\(action.amount)",
                                value: Binding(
                                    get: { action.amount },
                                    set: { store.send(.view(.quickActionAmountChanged(action.id, $0))) }
                                ),
                                in: 1...99
                            )
                            Button(role: .destructive) {
                                store.send(.view(.removeQuickAction(action.id)))
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    Button {
                        store.send(.view(.addQuickActionButtonTapped))
                    } label: {
                        Label("Add New", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Add Chart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        store.send(.view(.cancelButtonTapped))
                    } label: {
                        Text("Cancel")
                    }
                }
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
                ._printChanges()
        })
    }
}
