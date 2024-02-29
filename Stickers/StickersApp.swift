import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct StickersApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State(people: [])) {
                    AppFeature()._printChanges()
                }
            )
        }
    }
}
