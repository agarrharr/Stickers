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

        try migrator.migrate(database)
        defaultDatabase = database
    }
}

extension DatabaseWriter {
    public func seed() throws {
        try write { db in
            try db.seed {
                Chart.Draft(name: "Chores")
                Chart.Draft(name: "Work")
            }
        }
    }
}
