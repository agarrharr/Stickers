import ComposableArchitecture
import SwiftUI

@Reducer
public struct StickersFeature {
    @ObservableState
    public struct State: Equatable {
        public var amount: Int
        
        public init(amount: Int = 0) {
            self.amount = amount
        }
    }
    
    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
    }
    
    public init() {}
}

public struct StickersView: View {
    var store: StoreOf<StickersFeature>
    
    public init(store: StoreOf<StickersFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 30))], spacing: 20) {
                ForEach(0..<store.amount, id: \.self) { index in
                    starImage()
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func starImage() -> some View {
        Image(systemName: "star.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundColor(.yellow)
    }
}

#Preview {
    StickersView(store: Store(
        initialState: StickersFeature.State(amount: 88)) {
            StickersFeature()
        }
    )
}
