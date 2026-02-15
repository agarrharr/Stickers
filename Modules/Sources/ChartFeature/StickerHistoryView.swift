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
            ForEach(groupedStickers, id: \.date) { dayGroup in
                Section {
                    ForEach(dayGroup.batches, id: \.id) { batch in
                        VStack(alignment: .leading, spacing: 8) {
                            // Time and creator name above stickers
                            HStack(spacing: 4) {
                                Text(batch.stickers.first?.createdAt ?? Date(), style: .time)
                                    .font(.subheadline)
                                Text("·")
                                    .foregroundStyle(.secondary)
                                Text(displayName(for: batch.stickers.first))
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
                                    StickerView(
                                        store: Store(initialState: StickerFeature.State(sticker: sticker)) {
                                            StickerFeature()
                                        }
                                    )
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

    private func displayName(for sticker: Sticker?) -> String {
        guard let sticker = sticker else { return "Unknown" }

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

    private func creatorKey(for sticker: Sticker) -> String {
        creatorsBySticker[sticker.id]?.recordName ?? "local"
    }

    /// Round a date to the nearest 2-minute window
    private func timeWindow(for date: Date) -> Date {
        let interval: TimeInterval = 120 // 2 minutes
        let rounded = (date.timeIntervalSince1970 / interval).rounded(.down) * interval
        return Date(timeIntervalSince1970: rounded)
    }

    private var groupedStickers: [DayGroup] {
        let calendar = Calendar.current

        // First group by day
        let byDay = Dictionary(grouping: stickers) { sticker in
            calendar.startOfDay(for: sticker.createdAt)
        }

        return byDay.map { (date, dayStickers) in
            // Group by (timeWindow, creator) to batch stickers together
            let grouped = Dictionary(grouping: dayStickers) { sticker in
                BatchKey(
                    timeWindow: timeWindow(for: sticker.createdAt),
                    creator: creatorKey(for: sticker)
                )
            }

            // Convert to batches and sort by time descending (but stickers within batch ascending)
            let batches = grouped.map { (key, stickers) in
                StickerBatch(
                    creatorKey: key.creator,
                    // Sort ascending within batch so new stickers appear at the end
                    stickers: stickers.sorted { $0.createdAt < $1.createdAt }
                )
            }
            .sorted { ($0.stickers.first?.createdAt ?? .distantPast) > ($1.stickers.first?.createdAt ?? .distantPast) }

            return DayGroup(date: date, batches: batches)
        }
        .sorted { $0.date > $1.date }
    }
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
    let creatorKey: String
    var stickers: [Sticker]

    var id: String {
        stickers.first?.id.uuidString ?? UUID().uuidString
    }
}
