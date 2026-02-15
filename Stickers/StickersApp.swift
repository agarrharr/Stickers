import CloudKit
import ComposableArchitecture
import Dependencies
import SQLiteData
import SwiftUI

import AppFeature
import Models

@main
struct StickersApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

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

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    @Dependency(\.defaultSyncEngine) var syncEngine

    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        Task {
            do {
                try await syncEngine.acceptShare(metadata: cloudKitShareMetadata)
            } catch {
                SyncDiagnostics.log(error: error, operation: "Accepting CloudKit share")
            }
        }
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let cloudKitShareMetadata = connectionOptions.cloudKitShareMetadata
        else { return }
        Task {
            do {
                try await syncEngine.acceptShare(metadata: cloudKitShareMetadata)
            } catch {
                SyncDiagnostics.log(error: error, operation: "Accepting CloudKit share")
            }
        }
    }
}
