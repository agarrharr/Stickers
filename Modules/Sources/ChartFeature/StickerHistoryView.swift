import CloudKit
import Dependencies
import SQLiteData
import SwiftUI

import Models
import StickerFeature

struct StickerHistoryView: View {
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.defaultSyncEngine) var syncEngine

    let chartID: Chart.ID
    @FetchAll var stickers: [Sticker]
    @State private var currentUserRecordID: CKRecord.ID?
    @State private var creatorsBySticker: [Sticker.ID: CKRecord.ID] = [:]
    @State private var modificationTimeBySticker: [Sticker.ID: Int64] = [:]
    @State private var fallbackAnchorDate = Date.now
    @State private var fallbackCreatedAtBySticker: [Sticker.ID: Date] = [:]
    @State private var participantNames: [String: String] = [:] // recordName -> displayName

    init(chartID: Chart.ID) {
        self.chartID = chartID
        _stickers = FetchAll(Sticker.where { $0.chartID.eq(chartID) })
    }

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(groupedStickers, id: \.date) { dayGroup in
                Section {
                    ForEach(dayGroup.batches) { batch in
                        VStack(alignment: .leading, spacing: 8) {
                            // Time and creator name above stickers
                            HStack(spacing: 4) {
                                Text(batch.createdAt, style: .time)
                                    .font(.subheadline)
                                Text("·")
                                    .foregroundStyle(.secondary)
                                Text(displayName(for: batch.creatorKey))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                if batch.stickers.count > 1 {
                                    Text("(\(batch.stickers.count))")
                                        .font(.subheadline)
                                        .foregroundStyle(.tertiary)
                                }
                            }

                            // Stickers in a grid that goes all the way across
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 4) {
                                ForEach(batch.stickers) { sticker in
                                    StickerView(sticker: sticker)
                                    .frame(width: 44, height: 44)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                } header: {
                    HStack {
                        Text(dayGroup.date, style: .date)
                            .font(.headline)
                        Spacer()
                        Text("\(dayGroup.totalCount) stickers")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .task(id: stickers.map(\.id)) {
            refreshFallbackCreatedAt()
            await loadCreatorInfo(forceReloadAll: false)
        }
        .onChange(of: syncEngine.isSynchronizing) {
            guard !syncEngine.isSynchronizing else { return }
            Task {
                await loadCreatorInfo(forceReloadAll: true)
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private func refreshFallbackCreatedAt() {
        let stickerIDs = Set(stickers.map(\.id))
        var updatedFallbackCreatedAt = fallbackCreatedAtBySticker.filter { stickerIDs.contains($0.key) }

        var fallback = Date.now
        for sticker in stickers where updatedFallbackCreatedAt[sticker.id] == nil {
            updatedFallbackCreatedAt[sticker.id] = fallback
            fallback = fallback.addingTimeInterval(0.001)
        }

        if updatedFallbackCreatedAt != fallbackCreatedAtBySticker {
            fallbackCreatedAtBySticker = updatedFallbackCreatedAt
        }
    }

    private func loadCreatorInfo(forceReloadAll: Bool) async {
        do {
            let userRecordID = try await CKContainer.default().userRecordID()
            if currentUserRecordID?.recordName != userRecordID.recordName {
                currentUserRecordID = userRecordID
            }
        } catch {
            // Ignore
        }

        // Fetch the share for this chart to get participant names
        do {
            let chartMetadata = try await database.read { db in
                try SyncMetadata
                    .find(Chart(id: chartID, name: "").syncMetadataID)
                    .fetchOne(db)
            }

            if let share = chartMetadata?.share {
                var names: [String: String] = [:]
                for participant in share.participants {
                    if let recordID = participant.userIdentity.userRecordID {
                        let displayName = participant.userIdentity.nameComponents?.formatted()
                            ?? participant.userIdentity.lookupInfo?.emailAddress
                            ?? "Unknown"
                        names[recordID.recordName] = displayName
                    }
                }
                if names != participantNames {
                    participantNames = names
                }

                // Prefer the share's current participant identity when available.
                // This resolves local creator grouping early, before per-sticker
                // metadata catches up.
                if let shareCurrentUserRecordID = share.currentUserParticipant?.userIdentity.userRecordID {
                    if currentUserRecordID?.recordName != shareCurrentUserRecordID.recordName {
                        currentUserRecordID = shareCurrentUserRecordID
                    }
                }
            }
        } catch {
            // Ignore
        }

        // Fetch sync metadata for relevant stickers.
        let liveStickerIDs = Set(stickers.map(\.id))
        var updatedCreators = forceReloadAll
            ? [:]
            : creatorsBySticker.filter { liveStickerIDs.contains($0.key) }
        var updatedModificationTimes = forceReloadAll
            ? [:]
            : modificationTimeBySticker.filter { liveStickerIDs.contains($0.key) }
        let stickersToLookup = forceReloadAll
            ? stickers
            : stickers.filter {
                updatedCreators[$0.id] == nil || updatedModificationTimes[$0.id] == nil
            }

        guard !stickersToLookup.isEmpty || forceReloadAll else { return }

        do {
            let metadata: [(Sticker.ID, SyncMetadata?)] = try await database.read { db in
                try stickersToLookup.map { sticker in
                    let syncMetadata = try SyncMetadata
                        .find(sticker.syncMetadataID)
                        .fetchOne(db)
                    return (sticker.id, syncMetadata)
                }
            }

            for (stickerID, syncMetadata) in metadata {
                if let syncMetadata {
                    updatedModificationTimes[stickerID] = syncMetadata.userModificationTime
                }
                if let creatorID = syncMetadata?.lastKnownServerRecord?.creatorUserRecordID {
                    updatedCreators[stickerID] = creatorID
                }
            }

            let existingCreatorRecordNames = creatorsBySticker.mapValues(\.recordName)
            let updatedCreatorRecordNames = updatedCreators.mapValues(\.recordName)
            if existingCreatorRecordNames != updatedCreatorRecordNames {
                creatorsBySticker = updatedCreators
            }
            if modificationTimeBySticker != updatedModificationTimes {
                modificationTimeBySticker = updatedModificationTimes
            }
        } catch {
            // Ignore errors
        }
    }

    private func displayName(for creatorKey: String) -> String {
        if creatorKey == "local" {
            if let currentUserRecordID,
               let localDisplayName = participantNames[currentUserRecordID.recordName] {
                return localDisplayName
            }
            return "You"
        }

        if let currentID = currentUserRecordID,
           creatorKey == currentID.recordName {
            return participantNames[currentID.recordName] ?? "You"
        }

        // Look up participant name from share
        if let name = participantNames[creatorKey] {
            return name
        }

        return "Shared user"
    }

    private var localCreatorKey: String {
        if let currentUserRecordID {
            return currentUserRecordID.recordName
        }

        let knownCreatorKeys = Set(stickers.compactMap { creatorsBySticker[$0.id]?.recordName })
        if knownCreatorKeys.count == 1, let knownCreatorKey = knownCreatorKeys.first {
            return knownCreatorKey
        }

        return "local"
    }

    private func creatorKey(for sticker: Sticker) -> String {
        creatorsBySticker[sticker.id]?.recordName ?? localCreatorKey
    }

    private func createdAt(for sticker: Sticker) -> Date {
        if let time = modificationTimeBySticker[sticker.id], time > 0 {
            return Date(timeIntervalSince1970: TimeInterval(time) / 1_000_000_000)
        }
        if let fallbackCreatedAt = fallbackCreatedAtBySticker[sticker.id] {
            return fallbackCreatedAt
        }
        return fallbackAnchorDate
    }

    /// Round a date to the nearest 2-minute window
    private func timeWindow(for date: Date) -> Date {
        let interval: TimeInterval = 120 // 2 minutes
        let rounded = (date.timeIntervalSince1970 / interval).rounded(.down) * interval
        return Date(timeIntervalSince1970: rounded)
    }

    private var groupedStickers: [DayGroup] {
        let calendar = Calendar.current
        var contexts: [StickerGroupingContext] = []
        contexts.reserveCapacity(stickers.count)
        for sticker in stickers {
            let createdAt = createdAt(for: sticker)
            contexts.append(
                StickerGroupingContext(
                    sticker: sticker,
                    createdAt: createdAt,
                    creatorKey: creatorKey(for: sticker),
                    day: calendar.startOfDay(for: createdAt),
                    timeWindow: timeWindow(for: createdAt)
                )
            )
        }

        // Deterministic ordering prevents broad list invalidation/jitter:
        // day desc -> time window desc -> creator -> createdAt asc -> id
        contexts.sort { lhs, rhs in
            if lhs.day != rhs.day { return lhs.day > rhs.day }
            if lhs.timeWindow != rhs.timeWindow { return lhs.timeWindow > rhs.timeWindow }
            if lhs.creatorKey != rhs.creatorKey { return lhs.creatorKey < rhs.creatorKey }
            if lhs.createdAt != rhs.createdAt { return lhs.createdAt < rhs.createdAt }
            return lhs.sticker.id.uuidString < rhs.sticker.id.uuidString
        }

        var dayGroups: [DayGroup] = []
        dayGroups.reserveCapacity(contexts.count)

        var currentDay: Date?
        var currentBatches: [StickerBatch] = []
        var currentBatch: StickerBatch?

        for context in contexts {
            if currentDay != context.day {
                if let currentBatch {
                    currentBatches.append(currentBatch)
                }
                if let currentDay {
                    dayGroups.append(DayGroup(date: currentDay, batches: currentBatches))
                }
                currentDay = context.day
                currentBatches = []
                currentBatch = nil
            }

            let batchKey = BatchKey(timeWindow: context.timeWindow, creator: context.creatorKey)
            if currentBatch?.key == batchKey {
                currentBatch?.stickers.append(context.sticker)
            } else {
                if let currentBatch {
                    currentBatches.append(currentBatch)
                }
                currentBatch = StickerBatch(
                    key: batchKey,
                    creatorKey: context.creatorKey,
                    createdAt: context.createdAt,
                    stickers: [context.sticker]
                )
            }
        }

        if let currentBatch {
            currentBatches.append(currentBatch)
        }
        if let currentDay {
            dayGroups.append(DayGroup(date: currentDay, batches: currentBatches))
        }

        return dayGroups
    }
}

private struct StickerGroupingContext {
    let sticker: Sticker
    let createdAt: Date
    let creatorKey: String
    let day: Date
    let timeWindow: Date
}

private struct BatchKey: Hashable {
    let timeWindow: Date
    let creator: String
}

private struct DayGroup {
    let date: Date
    let batches: [StickerBatch]

    var totalCount: Int {
        batches.reduce(0) { $0 + $1.stickers.count }
    }
}

private struct StickerBatch: Identifiable {
    let key: BatchKey
    let creatorKey: String
    let createdAt: Date
    var stickers: [Sticker]

    var id: BatchKey {
        key
    }
}
