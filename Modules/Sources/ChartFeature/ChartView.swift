import ComposableArchitecture
import SwiftUI

@Reducer
public struct ChartFeature {
    @ObservableState
    public struct State {
    }
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
    ChartView(store: Store(initialState: ChartFeature.State()) {
        ChartFeature()
    })
}
