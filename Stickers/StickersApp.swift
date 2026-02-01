import ComposableArchitecture
import Dependencies
import SwiftUI

import AppFeature
import Models

@main
struct StickersApp: App {
    static let state = AppFeature.State()

    init() {
        prepareDependencies {
            try! $0.bootstrapDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: Self.state) {
                AppFeature()._printChanges()
            })
        }
    }
}
