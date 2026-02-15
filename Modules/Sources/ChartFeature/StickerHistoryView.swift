import CloudKit
import ComposableArchitecture
import Dependencies
import SQLiteData
import SwiftUI

import Models
import StickerFeature

struct StickerHistoryView: View {
    @Dependency(\.defaultDatabase) var database

    let chartID: Chart.ID
    @FetchAll var stickers: [Sticker]
    @State private var currentUserRecordID: CKRecord.ID?
    @State private var creatorsBySticker: [Sticker.ID: CKRecord.ID] = [:]
    @State private var participantNames: [String: String] = [:] // recordName -> displayName

    init(chartID: Chart.ID) {
        self.chartID = chartID
        _stickers = FetchAll(
            Sticker
                .where { $0.chartID.eq(chartID) }
                .order { $0.createdAt.desc() },
            animation: .default
        )
    }

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(groupedStickers, id: \.date) { group in
                Section {
                    ForEach(group.stickers) { sticker in
                        HStack(spacing: 12) {
                            StickerView(
                                store: Store(initialState: StickerFeature.State(sticker: sticker)) {
                                    StickerFeature()
                                }
                            )
                            .frame(width: 50, height: 50)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(sticker.createdAt, style: .time)
                                    .font(.subheadline)
                                Text(displayName(for: sticker))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                } header: {
                    HStack {
                        Text(group.date, style: .date)
                            .font(.headline)
                        Spacer()
                        Text("\(group.stickers.count) stickers")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .task {
            await loadCreatorInfo()
        }
        .onChange(of: stickers) {
            Task {
                await loadCreatorInfo()
            }
        }
    }

    private func loadCreatorInfo() async {
        do {
            currentUserRecordID = try await CKContainer.default().userRecordID()
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
                participantNames = names
            }
        } catch {
            // Ignore
        }

        // Fetch sync metadata for all stickers
        let stickersToLookup = stickers
        do {
            let metadata: [(Sticker.ID, SyncMetadata?)] = try await database.read { db in
                try stickersToLookup.map { sticker in
                    let syncMetadata = try SyncMetadata
                        .find(sticker.syncMetadataID)
                        .fetchOne(db)
                    return (sticker.id, syncMetadata)
                }
            }

            var creators: [Sticker.ID: CKRecord.ID] = [:]
            for (stickerID, syncMetadata) in metadata {
                if let creatorID = syncMetadata?.lastKnownServerRecord?.creatorUserRecordID {
                    creators[stickerID] = creatorID
                }
            }
            creatorsBySticker = creators
        } catch {
            // Ignore errors
        }
    }

    private func displayName(for sticker: Sticker) -> String {
        guard let creatorID = creatorsBySticker[sticker.id] else {
            return "You" // Assume local if no sync metadata yet
        }

        if let currentID = currentUserRecordID,
           creatorID.recordName == currentID.recordName {
            return "You"
        }

        // Look up participant name from share
        if let name = participantNames[creatorID.recordName] {
            return name
        }

        return "Shared user"
    }

    private var groupedStickers: [StickerGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: stickers) { sticker in
            calendar.startOfDay(for: sticker.createdAt)
        }
        return grouped
            .map { StickerGroup(date: $0.key, stickers: $0.value.sorted { $0.createdAt > $1.createdAt }) }
            .sorted { $0.date > $1.date }
    }
}

private struct StickerGroup {
    let date: Date
    let stickers: [Sticker]
}
