import ComposableArchitecture
import Dependencies
import Foundation
import IdentifiedCollections
import Models

public struct QuickActionInput: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var amount: Int

    public init(id: UUID, name: String = "", amount: Int = 1) {
        self.id = id
        self.name = name
        self.amount = amount
    }

    public init(name: String = "", amount: Int = 1) {
        @Dependency(\.uuid) var uuid
        self.init(id: uuid(), name: name, amount: amount)
    }
}

@Reducer
public struct AddChartFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        var name = ""
        var color: BackgroundColor = .yellow
        var quickActions: IdentifiedArrayOf<QuickActionInput> = []

        public init(name: String = "", color: BackgroundColor = .yellow, quickActions: IdentifiedArrayOf<QuickActionInput> = []) {
            self.name = name
            self.color = color
            self.quickActions = quickActions
        }
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
            case nameChanged(String)
            case removeQuickAction(QuickActionInput.ID)
            case quickActionNameChanged(QuickActionInput.ID, String)
            case quickActionAmountChanged(QuickActionInput.ID, Int)
        }

        @CasePathable
        public enum DelegateAction: Sendable {
            case onChartAdded(String, BackgroundColor, [QuickActionInput])
        }
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .addButtonTapped:
                    return .run { [name = state.name, color = state.color, quickActions = Array(state.quickActions)] send in
                        await send(.delegate(.onChartAdded(name, color, quickActions)))
                    }
                case .cancelButtonTapped:
                    return .run { _ in
                        @Dependency(\.dismiss) var dismiss
                        await dismiss()
                    }
                case let .colorButtonTapped(color):
                    state.color = color
                    return .none
                case .addQuickActionButtonTapped:
                    state.quickActions.append(QuickActionInput())
                    return .none
                case let .nameChanged(name):
                    state.name = name
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
