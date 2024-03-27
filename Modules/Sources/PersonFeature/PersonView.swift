import ComposableArchitecture
import SwiftUI

import ChartFeature
import StickerFeature

@Reducer
public struct PersonFeature {
    @ObservableState
    public struct State: Codable, Equatable, Identifiable {
        public var id: UUID
        public var name: String
        public var charts: IdentifiedArrayOf<ChartFeature.State>
        var activeChartID: UUID
        
        public mutating func addSticker() {
            charts[id: activeChartID]?.addSticker()
        }
        
        public init(
            id: UUID = UUID(),
            name: String,
            charts: IdentifiedArrayOf<ChartFeature.State>
        ) {
            self.id = id
            self.name = name
            self.charts = charts
            self.activeChartID = charts.first?.id ?? UUID()
        }
    }
    
    public enum Action: Sendable {
        case charts(IdentifiedActionOf<ChartFeature>)
        case selectChart(UUID)
        case view(ViewAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum ViewAction {
            case addChartButtonTapped
            case onTabChange
        }
        
        @CasePathable
        public enum DelegateAction {
            case onAddChartButtonTapped
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .charts:
                return .none
            case let .selectChart(chartID):
                state.activeChartID = chartID
                return .none
            case let .view(action):
                switch action {
                case .addChartButtonTapped:
                    return .send(.delegate(.onAddChartButtonTapped))
                case .onTabChange:
                    state.activeChartID = state.charts.first?.id ?? UUID()
                    return .none
                }
            case .delegate:
                return .none
            }
        }
        .forEach(\.charts, action: \.charts) {
            ChartFeature()
        }
    }
    
    public init() {}
}

public struct PersonView: View {
    @Bindable var store: StoreOf<PersonFeature>
    
    private var chartName: String {
        store.charts[id: store.activeChartID]?.name ?? "Unknown chart name"
    }
    private var totalStickers: Int {
        store.charts[id: store.activeChartID]?.stickers.count ?? 0
    }
    
    public init(store: StoreOf<PersonFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            if store.charts.count == 0 {
                Spacer()
                    .frame(height: 50)
                
                Text("It looks like \(store.name) doesn't have any charts yet.")
                
                Button {
                    store.send(.view(.addChartButtonTapped))
                } label: {
                    Text("Add one")
                }
                
                Spacer()
            } else {
                TabView(
                    selection:  $store.activeChartID.sending(\.selectChart),
                    content:  {
                        ForEach(store.scope(state: \.charts, action: \.charts)) { store in
                            VStack {
                                ChartView(store: store)
                                Spacer()
                                Text(chartName)
                                Text("^[\(totalStickers) stickers](inflect: true, partOfSpeech: nount)")
                                Spacer()
                                    .frame(height: 60)
                            }
                            .tabItem {
                                Text(store.name)
                            }
                            .tag(store.state.id)
                        }
                    }
                )
                
                Spacer()
            }
        }
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onChange(of: store.activeChartID) {
            store.send(.view(.onTabChange))
        }
    }
}

#Preview {
    NavigationView {
        PersonView(store: Store(
            initialState: PersonFeature.State(
                name: "Blob",
                charts: [
                    ChartFeature.State(
                        name: "Chores",
                        stickers: [
                            StickerFeature.State(
                                sticker: Sticker(imageName: "face-0")
                            )
                        ]
                    ),
                    ChartFeature.State(
                        name: "Homework",
                        stickers: [
                            StickerFeature.State(
                                sticker: Sticker(imageName: "face-0")
                            )
                        ]
                    )
                ]
            )
        ) {
            PersonFeature()
        })
    }
}
