import ComposableArchitecture
import SwiftUI

import AppFeature
import ChartFeature
import PersonFeature
import StickerFeature

@main
struct StickersApp: App {
    let state = AppFeature.State()

    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: state) {
                AppFeature()._printChanges()
            })
        }
    }
}
