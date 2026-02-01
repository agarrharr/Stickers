import ComposableArchitecture
import SwiftUI

import AppFeature

@main
struct StickersApp: App {
    static let state = AppFeature.State()

    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: Self.state) {
                AppFeature()._printChanges()
            })
        }
    }
}
