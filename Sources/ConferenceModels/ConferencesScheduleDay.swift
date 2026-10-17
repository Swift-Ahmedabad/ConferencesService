import Dependencies
import Foundation
import SQLiteData

@Table
public struct ConferencesScheduleDay: Equatable, Identifiable, Sendable {
    public let id: UUID

    public var eventID: ConferencesEvent.ID
    public var date = Date()
    public var status: ConferencesScheduleStatus?

    public init(
        id: UUID = { @Dependency(\.uuid) var uuid; return uuid() }(),
        eventID: ConferencesEvent.ID,
        date: Date = { @Dependency(\.date.now) var date; return date }(),
        status: ConferencesScheduleStatus? = nil
    ) {
        self.id = id
        self.eventID = eventID
        self.date = date
        self.status = status
    }
}

public enum ConferencesScheduleStatus: String, Equatable, QueryBindable, Sendable {
    case provisional
    case final
}

extension ConferencesScheduleDay {
    public static func migrate(using migrator: inout DatabaseMigrator) throws {
        migrator.registerMigration("Create 'conferencesScheduleDays' table") { db in
            try #sql("""
                CREATE TABLE "conferencesScheduleDays" (
                  "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "eventID" TEXT NOT NULL REFERENCES "conferencesEvents"("id") ON DELETE CASCADE,
                  "date" TEXT NOT NULL,
                  "status" TEXT
                ) STRICT
                """)
                .execute(db)

            try #sql("""
                CREATE INDEX "index_conferencesScheduleDays_on_eventID" ON "conferencesScheduleDays"("eventID")
                """)
                .execute(db)
        }
    }
}

extension ConferencesScheduleDay {
    public static var seedData: [ConferencesScheduleDay] {
        @Dependency(\.context) var context
        guard context != .live else { return [] }
        return [
            ConferencesScheduleDay(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                date: Date(timeIntervalSince1970: 1795046400),
                status: .provisional
            ),
            ConferencesScheduleDay(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                date: Date(timeIntervalSince1970: 1795132800),
                status: .provisional
            ),
        ]
    }
}
