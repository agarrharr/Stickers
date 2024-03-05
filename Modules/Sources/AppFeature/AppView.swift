import ComposableArchitecture
import NonEmpty
import SwiftUI

import AddSticker
import ChartFeature
import Models
import PeopleButtons
import SettingsFeature
import StickersFeature

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
  }

  public var body: some Reducer<State, Action> {
      Reduce { state, action in
          switch action {
          case .charts:
              return .none
          case let .selectChart(chartID):
              state.activeChartID = chartID
              return .none
          }
      }
      .forEach(\.charts, action: \.charts) {
          ChartFeature()
      }
  }
}

public struct PersonView: View {
    @Bindable var store: StoreOf<PersonFeature>
    
    public var body: some View {
        TabView(
                selection:  $store.activeChartID.sending(\.selectChart),
                content:  {
                    ForEach(store.scope(state: \.charts, action: \.charts)) { childStore in
                        Text("Stickers for \(childStore.name)")
                            .tabItem {
                                Text(childStore.name)
                            }
                            .tag(childStore.state.id)
                    }
                }
            )
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

@Reducer
public struct AppFeature {
    @Reducer(state: .equatable, action: .sendable)
    public enum Destination {
        case settings(SettingsFeature)
//        case addSticker(AddStickerFeature)
//        case addStickerToChart(AddStickerToChartFeature)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var people: IdentifiedArrayOf<PersonFeature.State>
        var activePersonID: UUID
        var selectedTab = 1
        
        var filteredPeople: IdentifiedArrayOf<PersonFeature.State> {
            self.people.filter { $0.id == activePersonID }
        }
        
        public init(
            destination: Destination.State? = nil,
            people: Shared<IdentifiedArrayOf<PersonFeature.State>>,
            activePersonID: UUID
        ) {
            self.destination = destination
            self._people = people
            self.activePersonID = activePersonID
        }
    }
    
    public enum Action: Sendable {
        case destination(PresentationAction<Destination.Action>)
        case view(ViewAction)
        case people(IdentifiedActionOf<PersonFeature>)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case addChartTapped
            case addPersonTapped
            case addStickerTapped
            case personTapped(UUID)
//            case settingsIconTapped
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
            case .people:
                return .none
            case let .view(action):
                switch action {
                case .addChartTapped:
                    return .none
                case .addPersonTapped:
                    return .none
                case .addStickerTapped:
//                    state.destination = .addSticker(
//                        AddStickerFeature.State(
//                            people: state.$people
////                            charts: state.$charts
//                        )
//                    )
                    return .none
                case let .personTapped(personID):
                    state.activePersonID = personID
                    return .none
//                case .settingsIconTapped:
//                    state.destination = .settings(SettingsFeature.State())
//                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.people, action: \.people) {
            PersonFeature()
        }
    }
    
    public init() {}
}

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
//    private var title: String {
//        "Chart"
////        store.charts[id: store.activeChartID]?.name ?? "Chart"
//    }
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            PersonView(
                store: store.scope(
                    state: \.filteredPeople,
                    action: \.people
                ).first!
            )
//            .navigationTitle(title)
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ProfileButton(store: store)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AddButton(store: store)
                }
            }
            .sheet(
                item: $store.scope(
                    state: \.destination?.settings,
                    action: \.destination.settings
                )
            ) { store in
                SettingsView(store: store)
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    struct ProfileButton: View {
        var store: StoreOf<AppFeature>

        var body: some View {
            Menu {
                ForEach(store.people, id: \.id) { person in
                    Button {
                        store.send(.view(.personTapped(person.id)))
                    } label: {
                        Label(person.name, systemImage: "person")
                    }
                }
            } label: {
                Label("Switch profile", systemImage: "person.fill")
            }
        }
    }
    
    struct AddButton: View {
        var store: StoreOf<AppFeature>
        
        var body: some View {
            Button {
                store.send(.view(.addChartTapped))
            } label: {
                Label("Add chart", systemImage: "plus")
            }
        }
    }

}

#Preview {
    let chart11 = ChartFeature.State(
        name: "Chores",
        reward: Reward(name: "Fishing rod"),
        stickers: StickersFeature.State(amount: 98)
    )
    let chart12 = ChartFeature.State(
        name: "Homework",
        reward: Reward(name: "Fishing rod"),
        stickers: StickersFeature.State(amount: 98)
    )
    let chart21 = ChartFeature.State(
        name: "Calm body",
        reward: Reward(name: "Batting cages"),
        stickers: StickersFeature.State(amount: 38)
    )
    let chart31 = ChartFeature.State(
        name: "Homework",
        reward: Reward(name: "Batting cages"),
        stickers: StickersFeature.State(amount: 38)
    )
    
    let person1 = PersonFeature.State(name: "Blob", charts: [chart11, chart12])
    let person2 = PersonFeature.State(name: "Son", charts: [chart21])
    let person3 = PersonFeature.State(name: "Daughter", charts: [chart31])
    
    return AppView(
        store: Store(
            initialState: AppFeature.State(
                people: Shared([person1, person2, person3]),
                activePersonID: person1.id
            )
        ) {
            AppFeature()
        }
    )
}
