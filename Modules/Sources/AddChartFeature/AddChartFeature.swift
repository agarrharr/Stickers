import ComposableArchitecture
import Dependencies
import Foundation

import Models

@Reducer
public struct AddChartFeature {
    @ObservableState
    public struct State: Equatable {
        var name = ""
        var color: BackgroundColor = .yellow
        var quickActions: IdentifiedArrayOf<QuickAction> = []

        public init(name: String = "", color: BackgroundColor = .yellow, quickActions: IdentifiedArrayOf<QuickAction> = []) {
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
