import Dependencies
import Foundation
import SQLiteData

@Table
public struct ConferencesEvent: Equatable, Identifiable, Sendable {
    public let id: UUID

    public var name = ""
    public var summary = ""
    public var language = ""
    public var version = ""
    public var homePageURL: URL?
    public var feedURL: URL?
    public var iconURL: URL?
    public var startDate = Date()
    public var endDate = Date()
    public var timezone = ""
    @Column(as: ConferencesVenue.JSONRepresentation.self)
    public var venue: ConferencesVenue
    @Column(as: [ConferencesAuthor].JSONRepresentation.self)
    public var authors: [ConferencesAuthor] = []
    
    public init(
        id: UUID = { @Dependency(\.uuid) var uuid; return uuid() }(),
        name: String = "",
        summary: String = "",
        language: String = "",
        version: String = "",
        homePageURL: URL? = nil,
        feedURL: URL? = nil,
        iconURL: URL? = nil,
        startDate: Date = { @Dependency(\.date.now) var date; return date }(),
        endDate: Date = { @Dependency(\.date.now) var date; return date }(),
        timezone: String = "",
        venue: ConferencesVenue,
        authors: [ConferencesAuthor] = []
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.language = language
        self.version = version
        self.homePageURL = homePageURL
        self.feedURL = feedURL
        self.iconURL = iconURL
        self.startDate = startDate
        self.endDate = endDate
        self.timezone = timezone
        self.venue = venue
        self.authors = authors
    }
}

@Selection
public struct ConferencesVenue: Equatable, Codable, Sendable {
    public var name = ""
    public var city = ""
    public var region = ""
    public var country = ""
    
    public init(
        name: String = "",
        city: String = "",
        region: String = "",
        country: String = ""
    ) {
        self.name = name
        self.city = city
        self.region = region
        self.country = country
    }
}

@Selection
public struct ConferencesAuthor: Equatable, Codable, Sendable {
    public var name = ""
    public var url: URL?
    
    public init(name: String = "", url: URL? = nil) {
        self.name = name
        self.url = url
    }
}

extension ConferencesEvent {
    public static func migrate(using migrator: inout DatabaseMigrator) throws {
        migrator.registerMigration("Create 'conferencesEvents' table") { db in
            try #sql("""
                CREATE TABLE "conferencesEvents" (
                  "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "name" TEXT NOT NULL DEFAULT '',
                  "summary" TEXT NOT NULL DEFAULT '',
                  "language" TEXT NOT NULL DEFAULT '',
                  "version" TEXT NOT NULL DEFAULT '',
                  "homePageURL" TEXT,
                  "feedURL" TEXT,
                  "iconURL" TEXT,
                  "startDate" TEXT NOT NULL,
                  "endDate" TEXT NOT NULL,
                  "timezone" TEXT NOT NULL DEFAULT '',
                  "venue" TEXT NOT NULL,
                  "authors" TEXT NOT NULL DEFAULT '[]'
                ) STRICT
                """)
                .execute(db)
        }
    }
}

extension ConferencesEvent {
    public static var seedData: [ConferencesEvent] {
        @Dependency(\.context) var context
        guard context != .live else { return [] }
        return [
            ConferencesEvent(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Swift Bharat 2026",
                summary: "Speakers, talks, schedule, tickets, and event updates for Swift Bharat 2026 in Mumbai.",
                language: "en-IN",
                version: "https://jsonfeed.org/version/1.1",
                homePageURL: URL(string: "https://www.swiftbharat.org/")!,
                feedURL: URL(string: "https://www.swiftbharat.org/2026/feed.json")!,
                iconURL: URL(string: "https://www.swiftbharat.org/favicon.ico")!,
                startDate: Date(timeIntervalSince1970: 1795046400),
                endDate: Date(timeIntervalSince1970: 1795132800),
                timezone: "Asia/Kolkata",
                venue: ConferencesVenue(name: "Yashwantrao Chavan Centre", city: "Mumbai", region: "Maharashtra", country: "IN"),
                authors: [ConferencesAuthor(name: "Swift Bharat", url: URL(string: "https://www.swiftbharat.org/")!)]
            )
        ]
    }
}
