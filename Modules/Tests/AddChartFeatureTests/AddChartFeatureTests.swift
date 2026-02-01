import ComposableArchitecture
import Foundation
import Testing

@testable import AddChartFeature

@MainActor
struct AddChartFeatureTests {
    @Test
    func addButtonTapped() async {
        prepareDependencies {
            $0.uuid = .incrementing
        }
        let store = TestStore(initialState: AddChartFeature.State(
            name: "Chores",
            color: .blue,
            quickActions: [
                QuickAction(name: "Take out trash", amount: 5)
            ]
        )) {
            AddChartFeature()
        }

        await store.send(.view(.addButtonTapped))
        await store.receive(\.delegate.onChartAdded) {
            _ = $0  // delegate action doesn't mutate state
        }
    }

    @Test
    func cancelButtonTapped() async {
        let store = TestStore(
            initialState: AddChartFeature.State(
                color: .blue,
                quickActions: []
            )
        ) {
            AddChartFeature()
        }

        await store.send(.view(.cancelButtonTapped))
    }

    @Test
    func colorButtonTapped() async {
        let store = TestStore(
            initialState: AddChartFeature.State(
                color: .blue,
                quickActions: []
            )
        ) {
            AddChartFeature()
        }

        await store.send(.view(.colorButtonTapped(.blue))) {
            $0.color = .blue
        }
    }

    @Test
    func addQuickAction() async {
        let store = TestStore(
            initialState: AddChartFeature.State(
                color: .blue,
                quickActions: []
            )
        ) {
            AddChartFeature()
        }

//        await store.send(.view(.addQuickActionButtonTapped)) {
//            $0.quickActions = [QuickAction(id: UUID(0), name: "", amount: 1)]
//        }
    }

    @Test
    func removeQuickAction() async {
        let store = TestStore(
            initialState: AddChartFeature.State(
                color: .blue,
                quickActions: [
                    QuickAction(name: "Chore", amount: 3)
                ]
            )
        ) {
            AddChartFeature()
        }

//        await store.send(.view(.removeQuickAction(id))) {
//            $0.quickActions = []
//        }
    }

    @Test
    func quickActionNameChanged() async {
        let store = TestStore(
            initialState: AddChartFeature.State(
                color: .blue,
                quickActions: []
            )
        ) {
            AddChartFeature()
        }
//        store.state.quickActions = [
//            QuickAction(id: id, name: "", amount: 1)
//        ]
//
//        await store.send(.view(.quickActionNameChanged(id, "Homework"))) {
//            $0.quickActions[id: id]?.name = "Homework"
//        }
    }

    @Test
    func quickActionAmountChanged() async {
        let store = TestStore(
            initialState: AddChartFeature.State(
                color: .blue,
                quickActions: []
            )
        ) {
            AddChartFeature()
        }
//        store.state.quickActions = [
//            QuickAction(id: id, name: "Chore", amount: 1)
//        ]
//
//        await store.send(.view(.quickActionAmountChanged(id, 10))) {
//            $0.quickActions[id: id]?.amount = 10
//        }
    }
}
