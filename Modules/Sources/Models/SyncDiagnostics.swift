import CloudKit
import Foundation
import GRDB
import OSLog
import SQLiteData

public enum SyncDiagnostics {
    public static let cloudKitContainerIdentifierInfoKey = "CloudKitContainerIdentifier"
    public static let cloudKitEnvironmentInfoKey = "CloudKitEnvironment"

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Stickers",
        category: "CloudKit"
    )

    public static var cloudKitContainerIdentifier: String? {
        Bundle.main.object(forInfoDictionaryKey: cloudKitContainerIdentifierInfoKey) as? String
    }

    public static var cloudKitEnvironment: String {
        Bundle.main.object(forInfoDictionaryKey: cloudKitEnvironmentInfoKey) as? String ?? "Unknown"
    }

    public static func logStartupConfiguration() {
        logger.notice(
            """
            CloudKit setup: environment=\(cloudKitEnvironment, privacy: .public), \
            container=\((cloudKitContainerIdentifier ?? "<entitlements>"), privacy: .public)
            """
        )
    }

    @discardableResult
    public static func log(error: any Error, operation: String) -> String {
        let message = describe(error: error, operation: operation)
        logger.error("\(message, privacy: .public)")
        return message
    }

    public static func describe(error: any Error, operation: String) -> String {
        var lines: [String] = [
            "\(operation) failed.",
            "Error: \(error.localizedDescription)",
        ]

        if let databaseError = error as? DatabaseError {
            let databaseMessage = databaseError.message ?? "<none>"
            lines.append("Database message: \(databaseMessage)")
            if databaseMessage == SyncEngine.writePermissionError {
                lines.append(
                    """
                    Write was denied by CloudKit sharing permissions. \
                    The current account cannot modify this shared record.
                    """
                )
            }
            if databaseMessage.localizedCaseInsensitiveContains("FOREIGN KEY constraint failed") {
                lines.append(
                    """
                    A related parent record is missing locally. This usually means the chart was \
                    deleted on another device while this screen was open.
                    """
                )
            }
        }

        let errorText = String(describing: error)
        if errorText.localizedCaseInsensitiveContains("invalid attempt to set value type ENCRYPTED_TIMESTAMP") {
            lines.append(
                """
                CloudKit schema mismatch: this app is sending an encrypted timestamp for a field \
                that is typed as plain TIMESTAMP on the server.
                """
            )
        }
        if errorText.localizedCaseInsensitiveContains("cannot create or modify field")
            && errorText.localizedCaseInsensitiveContains("production schema")
        {
            lines.append(
                """
                Production schema is locked for new fields. Either deploy the schema change from \
                Development in CloudKit Dashboard, or stop syncing that field from the model.
                """
            )
        }

        appendCloudKitDetails(error, into: &lines)
        return lines.joined(separator: "\n")
    }

    private static func appendCloudKitDetails(_ error: any Error, into lines: inout [String]) {
        if let ckError = error as? CKError {
            lines.append("CKError: \(ckError.code.rawValue) (\(ckError.code))")
            if let retryAfter = ckError.userInfo[CKErrorRetryAfterKey] as? NSNumber {
                lines.append("Retry after: \(retryAfter.doubleValue)s")
            }
            if let partialErrors = ckError.partialErrorsByItemID, !partialErrors.isEmpty {
                lines.append("Partial errors:")
                for (itemID, partialError) in partialErrors.sorted(by: {
                    String(describing: $0.key) < String(describing: $1.key)
                }) {
                    lines.append("- \(itemID): \(partialError.localizedDescription)")
                }
            }
        }

        let nsError = error as NSError
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? any Error {
            lines.append("Underlying error: \(underlying.localizedDescription)")
            appendCloudKitDetails(underlying, into: &lines)
        }
    }
}
