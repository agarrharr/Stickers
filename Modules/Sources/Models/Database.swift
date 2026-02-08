import Dependencies
import Foundation
import GRDB
import SQLiteData
import StructuredQueriesSQLite

@DatabaseFunction nonisolated func uuid() -> UUID {
    @Dependency(\.uuid) var uuid
    return uuid()
}

extension DependencyValues {
    public mutating func bootstrapDatabase() throws {
        var configuration = Configuration()
        configuration.prepareDatabase { db in
            try db.attachMetadatabase()
            db.add(function: $uuid)
        }
        let database = try SQLiteData.defaultDatabase(configuration: configuration)

        var migrator = DatabaseMigrator()
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("Create 'charts', 'quickActions', and 'stickers' tables") { db in
            try #sql("""
                CREATE TABLE "charts" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "name" TEXT NOT NULL DEFAULT ''
                ) STRICT
                """)
                .execute(db)

            try #sql("""
                CREATE TABLE "quickActions" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "chartID" TEXT NOT NULL REFERENCES "charts"("id") ON DELETE CASCADE,
                    "name" TEXT NOT NULL DEFAULT '',
                    "amount" INTEGER NOT NULL DEFAULT 1
                ) STRICT
                """)
                .execute(db)
            try #sql("""
                CREATE INDEX "index_quickActions_on_chartID" ON "quickActions"("chartID")
                """)
                .execute(db)

            try #sql("""
                CREATE TABLE "stickers" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "chartID" TEXT NOT NULL REFERENCES "charts"("id") ON DELETE CASCADE,
                    "imageName" TEXT NOT NULL DEFAULT ''
                ) STRICT
                """)
                .execute(db)
            try #sql("""
                CREATE INDEX "index_stickers_on_chartID" ON "stickers"("chartID")
                """)
                .execute(db)
        }

        migrator.registerMigration("Add column 'color' to 'charts'") { db in
            try #sql("""
                ALTER TABLE "charts"
                ADD COLUMN "color" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT 'yellow'
                """)
                .execute(db)
        }

        try migrator.migrate(database)
        defaultDatabase = database
        defaultSyncEngine = try SyncEngine(
            for: database,
            tables: Chart.self, QuickAction.self, Sticker.self
        )
    }
}

extension DatabaseWriter {
    public func seed() throws {
        try write { db in
            try db.seed {
                Chart.Draft(id: UUID(0), name: "Chores")
                Chart.Draft(id: UUID(1), name: "Work")
                
                QuickAction.Draft(id: UUID(1), chartID: UUID(0), name: "Take out the trash", amount: 5)
                QuickAction.Draft(id: UUID(2), chartID: UUID(0), name: "Do homework", amount: 3)
                Sticker.Draft(id: UUID(3), chartID: UUID(0), imageName: "face-0")
                Sticker.Draft(id: UUID(4), chartID: UUID(0), imageName: "face-1")
                Sticker.Draft(id: UUID(5), chartID: UUID(0), imageName: "face-2")
                Sticker.Draft(id: UUID(6), chartID: UUID(0), imageName: "face-3")
                Sticker.Draft(id: UUID(7), chartID: UUID(0), imageName: "face-4")
                Sticker.Draft(id: UUID(8), chartID: UUID(0), imageName: "face-5")
                Sticker.Draft(id: UUID(9), chartID: UUID(0), imageName: "face-6")
                Sticker.Draft(id: UUID(10), chartID: UUID(0), imageName: "face-7")
            }
        }
    }
}
