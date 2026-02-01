import ComposableArchitecture
import SwiftUI

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
        }

        @CasePathable
        public enum DelegateAction: Sendable {
            case onChartAdded(String, BackgroundColor)
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
                    return .run { [name = state.name, color = state.color] send in
                        await send(.delegate(.onChartAdded(name, color)))
//                        await dismiss()
                    }
                case .cancelButtonTapped:
                    return .run { _ in
//                        await dismiss()
                    }
                case let .colorButtonTapped(color):
                    state.color = color
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
                    HStack {
                        Text("Take out the trash")
                        Spacer()
                        Text("+5")
                    }
                    Button {
                        
                    } label: {
                        Text("Add New")
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
