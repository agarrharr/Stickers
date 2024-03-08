import ComposableArchitecture
import SwiftUI

import ChartFeature
import StickerFeature

@Reducer
public struct PersonFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID
        public var name: String
        public var charts: IdentifiedArrayOf<ChartFeature.State>
        var activeChartID: UUID
        
        public init(
            id: UUID = UUID(),
            name: String,
            charts: IdentifiedArrayOf<ChartFeature.State>
        ) {
            self.id = id
            self.name = name
            self.charts = charts
            self.activeChartID = charts.first!.id // TODO: Don't force unwrap
        }
    }
    
    public enum Action: Sendable {
        case charts(IdentifiedActionOf<ChartFeature>)
        case selectChart(UUID)
        case view(ViewAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case addButtonTapped
            case settingsButtonTapped
        }
        
        @CasePathable
        public enum DelegateAction: Sendable {
            case onSettingsAppTapped
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
                case .addButtonTapped:
                    state.charts[id: state.activeChartID]?.addSticker()
                    return .none
                case .settingsButtonTapped:
                    return .run { send in
                        await send(.delegate(.onSettingsAppTapped))
                    }
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
        store.charts[id: store.activeChartID]?.name ?? "Chart"
    }
    private var totalStickers: Int {
        store.charts[id: store.activeChartID]?.stickers.count ?? 0
    }
    
    public init(store: StoreOf<PersonFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
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
            
            HStack {
                Spacer()
                    .frame(width: 20)
                
                Button {
                    store.send(.view(.settingsButtonTapped))
                } label: {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .accessibilityLabel("Settings")
                }
                
                Spacer()
                
                Button {
                    store.send(.view(.addButtonTapped))
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .accessibilityLabel("Add sticker to \(store.name)")
                }
                
                Spacer()
                    .frame(width: 20)
            }
        }
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
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
