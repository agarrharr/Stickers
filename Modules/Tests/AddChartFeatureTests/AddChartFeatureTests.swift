import ComposableArchitecture
import DependenciesTestSupport
import Foundation
import Testing

@testable import AddChartFeature

@MainActor
struct AddChartFeatureTests {
    @Test
    func addButtonTapped() async {
        let store = TestStore(initialState: AddChartFeature.State(
            name: "Chores",
            quickActions: [
                QuickActionInput(id: UUID(1), name: "Take out trash", amount: 5)
            ]
        )) {
            AddChartFeature()
        }

        await store.send(.view(.addButtonTapped))
        await store.receive(\.delegate.onChartAdded)
    }

    @Test
    func cancelButtonTapped() async {
        let store = TestStore(
            initialState: AddChartFeature.State(
                quickActions: []
            )
        ) {
            AddChartFeature()
        }

        await store.send(.view(.cancelButtonTapped))
    }

    @Test
    func addQuickAction() async {
        prepareDependencies {
            $0.uuid = .incrementing
        }
        let store = TestStore(
            initialState: AddChartFeature.State(
                quickActions: []
            )
        ) {
            AddChartFeature()
        }

        await store.send(.view(.addQuickActionButtonTapped)) {
            $0.quickActions = [QuickActionInput(id: UUID(0), name: "", amount: 1)]
        }
    }

    @Test
    func removeQuickAction() async {
        let id = UUID(1)
        let store = TestStore(
            initialState: AddChartFeature.State(
                quickActions: [
                    QuickActionInput(id: UUID(1), name: "Chore", amount: 3)
                ]
            )
        ) {
            AddChartFeature()
        }

        await store.send(.view(.removeQuickAction(id))) {
            $0.quickActions = []
        }
    }

    @Test
    func quickActionNameChanged() async {
        let id = UUID(1)
        let store = TestStore(
            initialState: AddChartFeature.State(
                quickActions: [
                    QuickActionInput(id: id, name: "", amount: 1)
                ]
            )
        ) {
            AddChartFeature()
        }

        await store.send(.view(.quickActionNameChanged(id, "Homework"))) {
            $0.quickActions[id: id]?.name = "Homework"
        }
    }

    @Test
    func quickActionAmountChanged() async {
        let id = UUID(1)
        let store = TestStore(
            initialState: AddChartFeature.State(
                quickActions: [
                    QuickActionInput(id: id, name: "Chore", amount: 1)
                ]
            )
        ) {
            AddChartFeature()
        }

        await store.send(.view(.quickActionAmountChanged(id, 10))) {
            $0.quickActions[id: id]?.amount = 10
        }
    }

    @Test
    func nameChanged() async {
        let store = TestStore(
            initialState: AddChartFeature.State(
                quickActions: []
            )
        ) {
            AddChartFeature()
        }

        await store.send(.view(.nameChanged("Chores"))) {
            $0.name = "Chores"
        }
    }
}
