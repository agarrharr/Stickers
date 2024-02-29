import ComposableArchitecture
import SwiftUI

@Reducer
public struct ChartFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id: UUID
        
        public init(id: UUID) {
            self.id = id
        }
    }

    public enum Action: BindableAction, Sendable {
      case binding(BindingAction<State>)
    }

    public var body: some Reducer<State, Action> {
      BindingReducer()
    }

    public init() {}
}

public struct ChartView: View {
    var store: StoreOf<ChartFeature>
    
    public init(store: StoreOf<ChartFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Chart")
    }
}

#Preview {
    ChartView(store: Store(initialState: ChartFeature.State(id: UUID())) {
        ChartFeature()
    })
}
