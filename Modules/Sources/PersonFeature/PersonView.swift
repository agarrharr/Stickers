import ComposableArchitecture
import NonEmpty
import SwiftUI

import ChartFeature
import StickerFeature

public struct Person: Identifiable, Equatable, Sendable, Codable {
    public var id: UUID
    public var name: String
    public var charts: IdentifiedArrayOf<Chart>
}

@Reducer
public struct PersonFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared var person: Person
        public var activeChartID: UUID

//        public mutating func addSticker() {
//            person.charts[id: activeChartID]?.addSticker()
//        }

        public init(
            person: Shared<Person>,
            activeChartID: UUID//? = nil

        ) {
            self._person = person
            // TODO: allow optional and assign the id of the first chart
            self.activeChartID = activeChartID
        }
    }

    public enum Action: Sendable {
//        case charts(IdentifiedActionOf<Chart>)
        case selectChart(UUID)
        case view(ViewAction)
        case delegate(DelegateAction)

        @CasePathable
        public enum ViewAction: Sendable {
            case addChartButtonTapped
        }

        @CasePathable
        public enum DelegateAction: Sendable {
            case onAddChartButtonTapped
        }
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
//            case .charts:
//                return .none
            case let .selectChart(chartID):
                state.activeChartID = chartID
                return .none
            case let .view(action):
                switch action {
                case .addChartButtonTapped:
                    return .send(.delegate(.onAddChartButtonTapped))
                }
            case .delegate:
                return .none
            }
        }
//        .forEach(\.charts, action: \.charts) {
//            ChartFeature()
//        }
    }

    public init() {}
}

import Sharing

public extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<Person>>.Default {
  static var people: Self {
    Self[.fileStorage(getPeopleJSONURL()), default: []]
  }
}

func getAppSandboxDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func getPeopleJSONURL() -> URL {
    getAppSandboxDirectory().appendingPathComponent("people.json")
}

public struct PersonView: View {
    @Bindable var store: StoreOf<PersonFeature>

    private var chartName: String {
        store.person.charts[id: store.activeChartID]?.name ?? "Unknown chart name"
    }

    private var totalStickers: Int {
        store.person.charts[id: store.activeChartID]?.stickers.count ?? 0
    }

    public init(store: StoreOf<PersonFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            if store.person.charts.count == 0 {
                Spacer()
                    .frame(height: 50)

                Text("It looks like \(store.person.name) doesn't have any charts yet.")

                Button {
                    store.send(.view(.addChartButtonTapped))
                } label: {
                    Text("Add one")
                }

                Spacer()
            } else {
                TabView(
                    selection: $store.activeChartID.sending(\.selectChart),
                    content: {
                        ForEach(Array(store.$person.charts)) { $chart in
                            VStack {
                                ChartView(store: Store(initialState: ChartFeature.State(chart: $chart)) {
                                    ChartFeature()
                                })
                                Spacer()
                                
                                Text(chartName)
                                
                                Text("^[\(totalStickers) stickers](inflect: true, partOfSpeech: nount)")
                                
                                Spacer()
                                    .frame(height: 60)
                            }
                            .tabItem {
                                Text(chart.name)
                            }
                            .tag(chart.id)
                        }
                    }
                )

                Spacer()
            }
        }
        .navigationTitle(store.person.name)
        .navigationBarTitleDisplayMode(.inline)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

//#Preview {
//    NavigationView {
//        let chartId = UUID()
//        PersonView(
//            store: Store(
//                initialState: PersonFeature.State(
//                    person: Shared(value: Person(
//                        id: UUID(),
//                        name: "Blob",
//                        charts: [
//                            Chart(
//                                id: chartId,
//                                name: "Chores",
//                                behaviors: [],
//                                stickers: [
//                                    Sticker(imageName: "face-0"),
//                                ],
//                                stickerPack: StickerPack(stickers: NonEmpty<Sticker>(Sticker(imageName: "face-0")))
//                            ),
////                            Chart(
////                                name: "Homework",
////                                stickers: [
////                                    StickerFeature.State(
////                                        sticker: Sticker(imageName: "face-0")
////                                    ),
////                                ]
////                            ),
//                        ]
//                    )),
//                    activeChartID: chartId
//                )
//        ) {
//            PersonFeature()
//        })
//    }
//}
