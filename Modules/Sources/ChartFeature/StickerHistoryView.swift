import CloudKit
import ComposableArchitecture
import Dependencies
import SQLiteData
import SwiftUI

import Models
import StickerFeature

struct StickerHistoryView: View {
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.defaultSyncEngine) var syncEngine

    let store: StoreOf<ChartFeature>
    let chartID: Chart.ID
    @FetchAll var batches: [StickerBatch]
    @FetchAll var stickers: [Sticker]
    @State private var currentUserRecordID: CKRecord.ID?
    @State private var creatorsByBatch: [StickerBatch.ID: CKRecord.ID] = [:]
    @State private var participantNames: [String: String] = [:] // recordName -> displayName

    init(store: StoreOf<ChartFeature>) {
        self.store = store
        let chartID = store.chart.id
        self.chartID = chartID
        _batches = FetchAll(
            StickerBatch
                .where { $0.chartID.eq(chartID) }
                .order { $0.createdAt.desc() },
            sectionBy: { #sql("date(\($0.createdAt), 'localtime')", as: String.self).desc() }
        )
        _stickers = FetchAll(Sticker.where { $0.chartID.eq(chartID) })
    }

    var body: some View {
        let stickersByBatch = Dictionary(grouping: stickers, by: \.batchID)
        LazyVStack(spacing: 0) {
            ForEach($batches.sections) { section in
                Section {
                    ForEach(section) { batch in
                        batchView(batch, stickers: stickersByBatch[batch.id] ?? [])
                    }
                } header: {
                    dayHeader(
                        name: section.name,
                        totalCount: section.reduce(0) { $0 + (stickersByBatch[$1.id]?.count ?? 0) }
                    )
                }
            }
            if let ungrouped = stickersByBatch[nil], !ungrouped.isEmpty {
                Section {
                    stickerGrid(ungrouped)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                } header: {
                    HStack {
                        Text("Earlier")
                            .font(.headline)
                        Spacer()
                        Text("\(ungrouped.count) stickers")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .task(id: batches.map(\.id)) {
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

    private func batchView(_ batch: StickerBatch, stickers: [Sticker]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(batch.createdAt, style: .time)
                    .font(.subheadline)
                if let note = batch.note {
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(note)
                        .font(.subheadline)
                }
                Text("·")
                    .foregroundStyle(.secondary)
                Text(displayName(for: creatorKey(for: batch)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if stickers.count > 1 {
                    Text("(\(stickers.count))")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }

            stickerGrid(stickers)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                store.send(.editBatchButtonTapped(batch, stickerCount: stickers.count))
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                store.send(.deleteBatchButtonTapped(batch.id))
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func stickerGrid(_ stickers: [Sticker]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 4) {
            ForEach(stickers) { sticker in
                StickerView(sticker: sticker)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private func dayHeader(name: String?, totalCount: Int) -> some View {
        HStack {
            if let name, let day = Self.dayFormatter.date(from: name) {
                Text(day, style: .date)
                    .font(.headline)
            } else {
                Text(name ?? "")
                    .font(.headline)
            }
            Spacer()
            Text("\(totalCount) stickers")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

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
                // This resolves local creator attribution early, before per-batch
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

        // Fetch sync metadata for relevant batches.
        let liveBatchIDs = Set(batches.map(\.id))
        var updatedCreators = forceReloadAll
            ? [:]
            : creatorsByBatch.filter { liveBatchIDs.contains($0.key) }
        let batchesToLookup = forceReloadAll
            ? batches
            : batches.filter { updatedCreators[$0.id] == nil }

        guard !batchesToLookup.isEmpty || forceReloadAll else { return }

        do {
            let metadata: [(StickerBatch.ID, SyncMetadata?)] = try await database.read { db in
                try batchesToLookup.map { batch in
                    let syncMetadata = try SyncMetadata
                        .find(batch.syncMetadataID)
                        .fetchOne(db)
                    return (batch.id, syncMetadata)
                }
            }

            for (batchID, syncMetadata) in metadata {
                if let creatorID = syncMetadata?.lastKnownServerRecord?.creatorUserRecordID {
                    updatedCreators[batchID] = creatorID
                }
            }

            let existingCreatorRecordNames = creatorsByBatch.mapValues(\.recordName)
            let updatedCreatorRecordNames = updatedCreators.mapValues(\.recordName)
            if existingCreatorRecordNames != updatedCreatorRecordNames {
                creatorsByBatch = updatedCreators
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

        let knownCreatorKeys = Set(batches.compactMap { creatorsByBatch[$0.id]?.recordName })
        if knownCreatorKeys.count == 1, let knownCreatorKey = knownCreatorKeys.first {
            return knownCreatorKey
        }

        return "local"
    }

    private func creatorKey(for batch: StickerBatch) -> String {
        creatorsByBatch[batch.id]?.recordName ?? localCreatorKey
    }
}
