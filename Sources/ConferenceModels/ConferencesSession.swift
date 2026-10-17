import Dependencies
import Foundation
import SQLiteData

@Table
public struct ConferencesSession: Equatable, Identifiable, Sendable {
    public let id: UUID

    public var eventID: ConferencesEvent.ID
    public var scheduleDayID: ConferencesScheduleDay.ID
    public var title = ""
    public var startTime = Date()
    public var endTime = Date()
    public var durationMinutes = 0
    public var imageURL: URL?
    public var endTimeIsLatest = false
    public var status: ConferencesSessionStatus?
    public var summary = ""
    public var audience: String?

    public init(
        id: UUID = { @Dependency(\.uuid) var uuid; return uuid() }(),
        eventID: ConferencesEvent.ID,
        scheduleDayID: ConferencesScheduleDay.ID,
        title: String = "",
        startTime: Date = { @Dependency(\.date.now) var date; return date }(),
        endTime: Date = { @Dependency(\.date.now) var date; return date }(),
        durationMinutes: Int = 0,
        imageURL: URL? = nil,
        endTimeIsLatest: Bool = false,
        status: ConferencesSessionStatus? = nil,
        summary: String = "",
        audience: String? = nil
    ) {
        self.id = id
        self.eventID = eventID
        self.scheduleDayID = scheduleDayID
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.durationMinutes = durationMinutes
        self.imageURL = imageURL
        self.endTimeIsLatest = endTimeIsLatest
        self.status = status
        self.summary = summary
        self.audience = audience
    }
}

public enum ConferencesSessionStatus: String, QueryBindable, Sendable {
    case tentative
    case confirmed
}

extension ConferencesSession {
    public static func migrate(using migrator: inout DatabaseMigrator) throws {
        migrator.registerMigration("Create 'conferencesSessions' table") { db in
            try #sql("""
                CREATE TABLE "conferencesSessions" (
                  "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "eventID" TEXT NOT NULL REFERENCES "conferencesEvents"("id") ON DELETE CASCADE,
                  "scheduleDayID" TEXT NOT NULL REFERENCES "conferencesScheduleDays"("id") ON DELETE CASCADE,
                  "title" TEXT NOT NULL DEFAULT '',
                  "startTime" TEXT NOT NULL,
                  "endTime" TEXT NOT NULL,
                  "durationMinutes" INTEGER NOT NULL DEFAULT 0,
                  "imageURL" TEXT,
                  "endTimeIsLatest" INTEGER NOT NULL DEFAULT 0,
                  "status" TEXT,
                  "summary" TEXT NOT NULL DEFAULT '',
                  "audience" TEXT
                ) STRICT
                """)
                .execute(db)

            try #sql("""
                CREATE INDEX "index_conferencesSessions_on_eventID" ON "conferencesSessions"("eventID")
                """)
                .execute(db)

            try #sql("""
                CREATE INDEX "index_conferencesSessions_on_scheduleDayID" ON "conferencesSessions"("scheduleDayID")
                """)
                .execute(db)
        }
    }
}

extension ConferencesSession {
    public static var seedData: [ConferencesSession] {
        @Dependency(\.context) var context
        guard context != .live else { return [] }
        return [
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000256")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Welcome & reception",
                startTime: Date(timeIntervalSince1970: 1795059000),
                endTime: Date(timeIntervalSince1970: 1795062600),
                durationMinutes: 60,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000257")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Welcome & opening",
                startTime: Date(timeIntervalSince1970: 1795062600),
                endTime: Date(timeIntervalSince1970: 1795063200),
                durationMinutes: 10,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000258")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Session 01",
                startTime: Date(timeIntervalSince1970: 1795063200),
                endTime: Date(timeIntervalSince1970: 1795065600),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000259")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Session 02",
                startTime: Date(timeIntervalSince1970: 1795065600),
                endTime: Date(timeIntervalSince1970: 1795068000),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000260")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Chai break",
                startTime: Date(timeIntervalSince1970: 1795068000),
                endTime: Date(timeIntervalSince1970: 1795069200),
                durationMinutes: 20,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/chai-snacks.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000261")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Session 03",
                startTime: Date(timeIntervalSince1970: 1795069200),
                endTime: Date(timeIntervalSince1970: 1795071600),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000262")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Session 04",
                startTime: Date(timeIntervalSince1970: 1795071600),
                endTime: Date(timeIntervalSince1970: 1795072800),
                durationMinutes: 20,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000263")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Buffer ¯\\_(ツ)_/¯",
                startTime: Date(timeIntervalSince1970: 1795072800),
                endTime: Date(timeIntervalSince1970: 1795073100),
                durationMinutes: 5,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000264")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Lunch",
                startTime: Date(timeIntervalSince1970: 1795073100),
                endTime: Date(timeIntervalSince1970: 1795077300),
                durationMinutes: 70,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/maharashtrian-thali.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000265")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Session 05",
                startTime: Date(timeIntervalSince1970: 1795077300),
                endTime: Date(timeIntervalSince1970: 1795079700),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000266")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Session 06",
                startTime: Date(timeIntervalSince1970: 1795079700),
                endTime: Date(timeIntervalSince1970: 1795082100),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000267")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Chai break",
                startTime: Date(timeIntervalSince1970: 1795082100),
                endTime: Date(timeIntervalSince1970: 1795083900),
                durationMinutes: 30,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/chai-snacks.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000268")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Surprise \\( ^o^ )/",
                startTime: Date(timeIntervalSince1970: 1795083900),
                endTime: Date(timeIntervalSince1970: 1795087800),
                durationMinutes: 65,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000269")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Post-conference mixer + BEST buses",
                startTime: Date(timeIntervalSince1970: 1795087800),
                endTime: Date(timeIntervalSince1970: 1795100400),
                durationMinutes: 0,
                imageURL: nil,
                endTimeIsLatest: true,
                status: .tentative,
                summary: "The talks wrap. Mumbai takes over! Mingling, vada pav + iconic red BEST buses. Plans still cooking — 5 PM to 8:30 PM latest. Details soon!",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000270")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Welcome back",
                startTime: Date(timeIntervalSince1970: 1795149000),
                endTime: Date(timeIntervalSince1970: 1795149600),
                durationMinutes: 10,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000271")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Session 01",
                startTime: Date(timeIntervalSince1970: 1795149600),
                endTime: Date(timeIntervalSince1970: 1795152000),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000272")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Session 02",
                startTime: Date(timeIntervalSince1970: 1795152000),
                endTime: Date(timeIntervalSince1970: 1795154400),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000273")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Chai break",
                startTime: Date(timeIntervalSince1970: 1795154400),
                endTime: Date(timeIntervalSince1970: 1795156200),
                durationMinutes: 30,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/chai-snacks.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000274")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Session 03",
                startTime: Date(timeIntervalSince1970: 1795156200),
                endTime: Date(timeIntervalSince1970: 1795158600),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000275")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Session 04",
                startTime: Date(timeIntervalSince1970: 1795158600),
                endTime: Date(timeIntervalSince1970: 1795159800),
                durationMinutes: 20,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000276")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Buffer ¯\\_(ツ)_/¯",
                startTime: Date(timeIntervalSince1970: 1795159800),
                endTime: Date(timeIntervalSince1970: 1795160100),
                durationMinutes: 5,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000277")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Lunch",
                startTime: Date(timeIntervalSince1970: 1795160100),
                endTime: Date(timeIntervalSince1970: 1795164600),
                durationMinutes: 75,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/maharashtrian-thali.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000278")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Session 05",
                startTime: Date(timeIntervalSince1970: 1795164600),
                endTime: Date(timeIntervalSince1970: 1795167000),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000279")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Session 06",
                startTime: Date(timeIntervalSince1970: 1795167000),
                endTime: Date(timeIntervalSince1970: 1795168200),
                durationMinutes: 20,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000280")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Chai break",
                startTime: Date(timeIntervalSince1970: 1795168200),
                endTime: Date(timeIntervalSince1970: 1795169700),
                durationMinutes: 25,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/chai-snacks.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000281")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Live podcast",
                startTime: Date(timeIntervalSince1970: 1795169700),
                endTime: Date(timeIntervalSince1970: 1795173300),
                durationMinutes: 60,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000282")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Closing & goodbyes",
                startTime: Date(timeIntervalSince1970: 1795173300),
                endTime: Date(timeIntervalSince1970: 1795174200),
                durationMinutes: 15,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000283")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Indie app fair + dinner",
                startTime: Date(timeIntervalSince1970: 1795174200),
                endTime: Date(timeIntervalSince1970: 1795186800),
                durationMinutes: 0,
                imageURL: nil,
                endTimeIsLatest: true,
                status: .tentative,
                summary: "Small apps. Big appetites. Show off your app, meet fellow makers + swap stories over dinner. Only for conference attendees with apps; no outside guests. Tentative: 5 PM–8:30 PM. Details soon!",
                audience: "Conference attendees with apps only; no outside guests."
            ),
        ]
    }
}
