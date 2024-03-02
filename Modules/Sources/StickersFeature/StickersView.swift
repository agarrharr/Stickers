import ComposableArchitecture
import SwiftUI

import Models

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
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                HStack(alignment: .bottom) {
                    ForEach(0..<totalNumberOfStars(), id: \.self) { index in
                        let starSize = self.starSize(forIndex: index)
                        starImage(size: starSize)
                    }
                }
                Spacer()
            }
            .scrollIndicators(.hidden)
            .onChange(of: store.amount, { _, _ in
                // Scroll all the way to the right
                value.scrollTo(totalNumberOfStars() - 1, anchor: .trailing)
            })
            .onAppear {
                // Scroll all the way to the right
                value.scrollTo(totalNumberOfStars() - 1, anchor: .trailing)
            }
        }
    }
    
    private func starImage(size: CGFloat) -> some View {
        Image(systemName: "star.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(.yellow)
    }
    
    private func totalNumberOfStars() -> Int {
        return numberOfLargeStars() + numberOfMediumStars() + numberOfSmallStars()
    }
    
    private func starSize(forIndex index: Int) -> CGFloat {
        if index < numberOfLargeStars() {
            return 30
        } else if index < numberOfLargeStars() + numberOfMediumStars() {
            return 20
        } else {
            return 15
        }
    }
    
    private func numberOfLargeStars() -> Int {
        store.amount / 10
    }
    
    private func numberOfMediumStars() -> Int {
        (store.amount % 10) / 5
    }
    
    private func numberOfSmallStars() -> Int {
        (store.amount % 10) % 5
    }
}

#Preview {
    StickersView(store: Store(
        initialState: StickersFeature.State(amount: 88)) {
            StickersFeature()
        }
    )
}
