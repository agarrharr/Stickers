import ComposableArchitecture
import SwiftUI

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
        AddChartView(
            store: Store(
                initialState: AddChartFeature.State(
                    quickActions: []
                )
        ) {
            AddChartFeature()
                ._printChanges()
        })
    }
}
