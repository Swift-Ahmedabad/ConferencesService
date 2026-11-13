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
    @Column(as: [String]?.JSONRepresentation.self)
    public var speakers: [String]?
    @Column(as: [String: ConferencesSpeaker]?.JSONRepresentation.self)
    public var speakerRows: [String: ConferencesSpeaker]?

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
        audience: String? = nil,
        speakers: [String]? = nil,
        speakerRows: [String: ConferencesSpeaker]? = nil
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
        self.speakers = speakers
        self.speakerRows = speakerRows
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
        
        migrator.registerMigration("Add Speakers columns in conferencesSessions table") { database in
            try database.alter(table: Self.tableName) { t in
                t.add(column: "speakers", .jsonText)
                t.add(column: "speakerRows", .jsonText)
            }
        }
    }
}

extension ConferencesSession {
    public static var seedData: [ConferencesSession] {
        @Dependency(\.context) var context
        guard context != .live else { return [] }

        let speakers = ConferencesSpeaker.seedData
        let speakersByFirstName = Dictionary(
            speakers.map { speaker in
                (speaker.name.split(separator: " ").first.map(String.init) ?? "", speaker)
            },
            uniquingKeysWith: { current, _ in current }
        )
        func rows(for names: [String]) -> [String: ConferencesSpeaker]? {
            let rows = names.reduce(into: [String: ConferencesSpeaker]()) { rows, name in
                let lookup = name == "Surprise Guest" ? "Opening" : name
                if let speaker = speakersByFirstName[lookup] {
                    rows[name] = speaker
                }
            }
            return rows.isEmpty ? nil : rows
        }

        return [
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000256")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Registration & Welcome",
                startTime: Date(timeIntervalSince1970: 1795059000),
                endTime: Date(timeIntervalSince1970: 1795062000),
                durationMinutes: 50,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000257")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Welcome to Swift Bharat",
                startTime: Date(timeIntervalSince1970: 1795062000),
                endTime: Date(timeIntervalSince1970: 1795062600),
                durationMinutes: 10,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: ["Mustafa"],
                speakerRows: rows(for: ["Mustafa"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000258")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Opening Talk",
                startTime: Date(timeIntervalSince1970: 1795062600),
                endTime: Date(timeIntervalSince1970: 1795063200),
                durationMinutes: 10,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: ["Surprise Guest"],
                speakerRows: rows(for: ["Surprise Guest"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000259")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "?????????????????",
                startTime: Date(timeIntervalSince1970: 1795063200),
                endTime: Date(timeIntervalSince1970: 1795065600),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "404, not found.",
                audience: nil,
                speakers: ["Josh"],
                speakerRows: rows(for: ["Josh"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000260")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Designing for iPhone Duo",
                startTime: Date(timeIntervalSince1970: 1795065600),
                endTime: Date(timeIntervalSince1970: 1795068000),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: ["Ashutosh"],
                speakerRows: rows(for: ["Ashutosh"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000261")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Chai Break",
                startTime: Date(timeIntervalSince1970: 1795068000),
                endTime: Date(timeIntervalSince1970: 1795069200),
                durationMinutes: 20,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/chai-snacks.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000262")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Maximizing On-Device AI on Apple Silicon",
                startTime: Date(timeIntervalSince1970: 1795069200),
                endTime: Date(timeIntervalSince1970: 1795071600),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "All of us already possess AI-powerhouses at our disposal: our Macs and iPhones. A discussion on making the most out of on-device intelligence right on Apple Platforms for AI use-cases that are private, secure and free of cost.",
                audience: nil,
                speakers: ["Sabesh"],
                speakerRows: rows(for: ["Sabesh"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000263")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Every Render Matters: Behind the Scenes of SwiftUI",
                startTime: Date(timeIntervalSince1970: 1795071600),
                endTime: Date(timeIntervalSince1970: 1795072800),
                durationMinutes: 20,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "What really happens behind the scenes when a SwiftUI view updates? Explore how SwiftUI walks the view hierarchy and drives rendering, alongside practical techniques to optimise rendering and keep high-performance apps smooth under load.",
                audience: nil,
                speakers: ["Kanishka"],
                speakerRows: rows(for: ["Kanishka"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000264")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Group Photo",
                startTime: Date(timeIntervalSince1970: 1795072800),
                endTime: Date(timeIntervalSince1970: 1795073100),
                durationMinutes: 5,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/group-photo.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "Everyone together, before we head to lunch.",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000265")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Lunch",
                startTime: Date(timeIntervalSince1970: 1795073100),
                endTime: Date(timeIntervalSince1970: 1795077600),
                durationMinutes: 75,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/maharashtrian-thali.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000266")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "The AI-Enhanced App",
                startTime: Date(timeIntervalSince1970: 1795077600),
                endTime: Date(timeIntervalSince1970: 1795080000),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "Your app doesn't need another random AI chatbot. It needs features that solve real problems your users actually care about. In this talk, we'll look beyond the obvious AI features and explore how to supercharge your apps behind the scenes.",
                audience: nil,
                speakers: ["Natasha"],
                speakerRows: rows(for: ["Natasha"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000267")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "From React Native to Native: An AI Developers’ Journey",
                startTime: Date(timeIntervalSince1970: 1795080000),
                endTime: Date(timeIntervalSince1970: 1795081800),
                durationMinutes: 30,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: ["Aarshad"],
                speakerRows: rows(for: ["Aarshad"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000268")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Chai Break",
                startTime: Date(timeIntervalSince1970: 1795081800),
                endTime: Date(timeIntervalSince1970: 1795083600),
                durationMinutes: 30,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/chai-snacks.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000269")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "0xdead10cc and Other Ways iOS Kills Your App",
                startTime: Date(timeIntervalSince1970: 1795083600),
                endTime: Date(timeIntervalSince1970: 1795086000),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "Not every failure shows up as a crash. Many of the worst ones are hangs, watchdog kills and terminations during suspension, and they arrive with a vague report and no clear stack trace. This talk covers real production cases: what each looked like, how we found the cause, and what fixed it.",
                audience: nil,
                speakers: ["Monika"],
                speakerRows: rows(for: ["Monika"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000270")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Surprise",
                startTime: Date(timeIntervalSince1970: 1795086000),
                endTime: Date(timeIntervalSince1970: 1795088700),
                durationMinutes: 45,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000271")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                title: "Indie App Fair & Networking",
                startTime: Date(timeIntervalSince1970: 1795088700),
                endTime: Date(timeIntervalSince1970: 1795096800),
                durationMinutes: 135,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/chaat-stall.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "Show off your app, meet fellow makers, and swap stories over refreshments and snacks.",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000272")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Pre-Conference Mingling",
                startTime: Date(timeIntervalSince1970: 1795145400),
                endTime: Date(timeIntervalSince1970: 1795149000),
                durationMinutes: 60,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "Doors open at 9 AM. Come early, catch up with familiar faces, and meet someone new before talks begin at 10 AM.",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000273")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Outsmart Your Agents with Concurrency Skills for Humans",
                startTime: Date(timeIntervalSince1970: 1795149000),
                endTime: Date(timeIntervalSince1970: 1795151400),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "Provide your agents with some well-written skills, write smart prompts, and you can spend your days honing your Magic: The Gathering skills. Sadly, we’re not quite there yet. This talk will help you hone your Concurrency domain knowledge so you can be a more knowledgeable expert than your agent.",
                audience: nil,
                speakers: ["Donny"],
                speakerRows: rows(for: ["Donny"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000274")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Keeping Up with the Agent-ians: Shipping Fast and with Confidence in an Agentic World",
                startTime: Date(timeIntervalSince1970: 1795151400),
                endTime: Date(timeIntervalSince1970: 1795153800),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "When code is commoditized, how do you stand out anymore? We’ll tackle this question through the lens of the Software Development Lifecycle in the Apple ecosystem, plus the launch of a brand new developer tool, to raise the bar on the big differentiators: pace and quality.",
                audience: nil,
                speakers: ["Kabir"],
                speakerRows: rows(for: ["Kabir"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000275")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Chai Break",
                startTime: Date(timeIntervalSince1970: 1795153800),
                endTime: Date(timeIntervalSince1970: 1795155600),
                durationMinutes: 30,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/chai-snacks.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000276")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Swift on Server - Pi to Max",
                startTime: Date(timeIntervalSince1970: 1795155600),
                endTime: Date(timeIntervalSince1970: 1795158000),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "Explore how you can use Swift to write server-side code for your app’s APIs and unlock new workflows. We start small on a Pi, and scale things up to 11…",
                audience: nil,
                speakers: ["Nikhil", "Ratnesh"],
                speakerRows: rows(for: ["Nikhil", "Ratnesh"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000277")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Beyond Translation: Live Voice Cloning with Apple Technologies",
                startTime: Date(timeIntervalSince1970: 1795158000),
                endTime: Date(timeIntervalSince1970: 1795159200),
                durationMinutes: 20,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "Explore how we’re building live translation with voice cloning using Apple technologies. Learn about our on-device approach using Apple frameworks, and MLX, the challenges we encountered, and how we’re making multilingual conversations more natural and private.",
                audience: nil,
                speakers: ["Manoj"],
                speakerRows: rows(for: ["Manoj"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000278")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Group Photo",
                startTime: Date(timeIntervalSince1970: 1795159200),
                endTime: Date(timeIntervalSince1970: 1795159500),
                durationMinutes: 5,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/group-photo.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "One more photo with the whole Swift Bharat crew.",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000279")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Lunch",
                startTime: Date(timeIntervalSince1970: 1795159500),
                endTime: Date(timeIntervalSince1970: 1795164000),
                durationMinutes: 75,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/maharashtrian-thali.png")!,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000280")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Shaders, Taste & Curiosity",
                startTime: Date(timeIntervalSince1970: 1795164000),
                endTime: Date(timeIntervalSince1970: 1795166400),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "What if great interface ideas came from the world around us, not just from apps? In this talk, I’ll show how I use Metal to turn light, glass, texture, and movement into custom experiences for Apple devices. Good examples, curiosity, and AI can help you learn shader code and try new ideas more easily. This isn’t about using shaders everywhere. It’s about building your visual taste, looking beyond familiar app designs, and creating something unusual, delightful, and uniquely yours.",
                audience: nil,
                speakers: ["Hidde"],
                speakerRows: rows(for: ["Hidde"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000281")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "What's Native Anyway",
                startTime: Date(timeIntervalSince1970: 1795166400),
                endTime: Date(timeIntervalSince1970: 1795168800),
                durationMinutes: 40,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: ["Marcin"],
                speakerRows: rows(for: ["Marcin"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000282")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Afternoon Break",
                startTime: Date(timeIntervalSince1970: 1795168800),
                endTime: Date(timeIntervalSince1970: 1795170600),
                durationMinutes: 30,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "Stretch your legs while we get ready for Launched.",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000283")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Launched Live",
                startTime: Date(timeIntervalSince1970: 1795170600),
                endTime: Date(timeIntervalSince1970: 1795174200),
                durationMinutes: 60,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "A live recording of the Launched podcast.",
                audience: nil,
                speakers: ["Charlie"],
                speakerRows: rows(for: ["Charlie"])
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000284")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "Closing Notes & Thank Yous",
                startTime: Date(timeIntervalSince1970: 1795174200),
                endTime: Date(timeIntervalSince1970: 1795175100),
                durationMinutes: 15,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
            ConferencesSession(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000285")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                scheduleDayID: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                title: "One Last Catch-Up",
                startTime: Date(timeIntervalSince1970: 1795175100),
                endTime: Date(timeIntervalSince1970: 1795183200),
                durationMinutes: 135,
                imageURL: nil,
                endTimeIsLatest: false,
                status: nil,
                summary: "We’ve reserved a big outdoor space for one last catch-up. Swap contacts, find someone you’ve been meaning to chat with, and say your goodbyes.",
                audience: nil,
                speakers: nil,
                speakerRows: nil
            ),
        ]
    }
}
