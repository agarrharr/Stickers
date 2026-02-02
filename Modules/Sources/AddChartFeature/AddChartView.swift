import ComposableArchitecture
import SwiftUI

extension BackgroundColor {
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
//                        TextField("Name", text: $store.name.sending(\.nameChanged))
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
        AddChartView(
            store: Store(
                initialState: AddChartFeature.State(
                    color: .blue,
                    quickActions: []
                )
        ) {
            AddChartFeature()
                ._printChanges()
        })
    }
}
