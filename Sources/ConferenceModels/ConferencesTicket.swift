import Dependencies
import Foundation
import SQLiteData

@Table
public struct ConferencesTicket: Equatable, Identifiable, Sendable {
    public let id: UUID

    public var eventID: ConferencesEvent.ID
    public var name = ""
    public var price = 0
    public var currency = ""
    public var url: URL?

    public init(
        id: UUID = { @Dependency(\.uuid) var uuid; return uuid() }(),
        eventID: ConferencesEvent.ID,
        name: String = "",
        price: Int = 0,
        currency: String = "",
        url: URL? = nil
    ) {
        self.id = id
        self.eventID = eventID
        self.name = name
        self.price = price
        self.currency = currency
        self.url = url
    }
}

extension ConferencesTicket {
    public static func migrate(using migrator: inout DatabaseMigrator) throws {
        migrator.registerMigration("Create 'conferencesTickets' table") { db in
            try #sql("""
                CREATE TABLE "conferencesTickets" (
                  "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "eventID" TEXT NOT NULL REFERENCES "conferencesEvents"("id") ON DELETE CASCADE,
                  "name" TEXT NOT NULL DEFAULT '',
                  "price" INTEGER NOT NULL DEFAULT 0,
                  "currency" TEXT NOT NULL DEFAULT '',
                  "url" TEXT
                ) STRICT
                """)
                .execute(db)

            try #sql("""
                CREATE INDEX "index_conferencesTickets_on_eventID" ON "conferencesTickets"("eventID")
                """)
                .execute(db)
        }
    }
}

extension ConferencesTicket {
    public static var seedData: [ConferencesTicket] {
        @Dependency(\.context) var context
        guard context != .live else { return [] }
        return [
            ConferencesTicket(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Super Early Bird",
                price: 4999,
                currency: "INR",
                url: URL(string: "https://www.swiftbharat.org/#tickets")!
            ),
            ConferencesTicket(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Regular Ticket",
                price: 5999,
                currency: "INR",
                url: URL(string: "https://www.swiftbharat.org/#tickets")!
            ),
        ]
    }
}
