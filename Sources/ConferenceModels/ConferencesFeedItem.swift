import Dependencies
import Foundation
import SQLiteData

@Table
public struct ConferencesFeedItem: Equatable, Identifiable, Sendable {
    public let id: UUID

    public var eventID: ConferencesEvent.ID
    public var feedID = ""
    public var url: URL?
    public var title = ""
    public var summary = ""
    public var contentText = ""
    public var contentHTML = ""
    public var imageURL: URL?
    @Column(as: [String].JSONRepresentation.self)
    public var tags: [String] = []
    public var dateModified = Date()

    public init(
        id: UUID = { @Dependency(\.uuid) var uuid; return uuid() }(),
        eventID: ConferencesEvent.ID,
        feedID: String = "",
        url: URL? = nil,
        title: String = "",
        summary: String = "",
        contentText: String = "",
        contentHTML: String = "",
        imageURL: URL? = nil,
        tags: [String] = [],
        dateModified: Date = { @Dependency(\.date.now) var date; return date }()
    ) {
        self.id = id
        self.eventID = eventID
        self.feedID = feedID
        self.url = url
        self.title = title
        self.summary = summary
        self.contentText = contentText
        self.contentHTML = contentHTML
        self.imageURL = imageURL
        self.tags = tags
        self.dateModified = dateModified
    }
}

extension ConferencesFeedItem {
    public static func migrate(using migrator: inout DatabaseMigrator) throws {
        migrator.registerMigration("Create 'conferencesFeedItems' table") { db in
            try #sql("""
                CREATE TABLE "conferencesFeedItems" (
                  "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "eventID" TEXT NOT NULL REFERENCES "conferencesEvents"("id") ON DELETE CASCADE,
                  "feedID" TEXT NOT NULL DEFAULT '',
                  "url" TEXT,
                  "title" TEXT NOT NULL DEFAULT '',
                  "summary" TEXT NOT NULL DEFAULT '',
                  "contentText" TEXT NOT NULL DEFAULT '',
                  "contentHTML" TEXT NOT NULL DEFAULT '',
                  "imageURL" TEXT,
                  "tags" TEXT NOT NULL DEFAULT '[]',
                  "dateModified" TEXT NOT NULL
                ) STRICT
                """)
                .execute(db)

            try #sql("""
                CREATE INDEX "index_conferencesFeedItems_on_eventID" ON "conferencesFeedItems"("eventID")
                """)
                .execute(db)
        }
    }
}

extension ConferencesFeedItem {
    public static var seedData: [ConferencesFeedItem] {
        @Dependency(\.context) var context
        guard context != .live else { return [] }
        return [
            ConferencesFeedItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000512")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                feedID: "https://www.swiftbharat.org/#event-guide",
                url: URL(string: "https://www.swiftbharat.org/")!,
                title: "Swift Bharat 2026 event guide",
                summary: "Event details and the announced speaker lineup for Swift Bharat 2026.",
                contentText: "Swift Bharat 2026 takes place on 19–20 November 2026 at Yashwantrao Chavan Centre in Mumbai. Announced speakers: Donny Wals — Indie Developer, Consultant, and Content Creator; Monika Mateska — Software engineer at RevenueCat and conference organizer; Marcin Krzyzanowski — Open source developer, building Notepad.exe, and senior engineer at Goodnotes; Hidde van der Ploeg — Better than Mustafa at everything; Natasha The Robot — Creator, writer, and community organizer; Nikhil Nigade — Indie iOS and macOS developer, designing delightful apps; Kanishka Chaudhry — iOS engineer at Upstox and Apple Scholar; Josh Holtz — Odd jobs at RevenueCat, lead maintainer of fastlane, and organizer of Deep Dish Swift; Ratnesh Jain — Indie developer building CommunityTalks. The provisional schedule is available: Day 1 runs 9:00 AM–5:00 PM IST and Day 2 runs 10:00 AM–5:00 PM IST. Speaker names for each session and talk titles will be announced soon. Tickets start at ₹4,999 and include all keynote sessions, lunch and refreshments, conference materials, and the post-conference mixer. Tentative evening plans: Day 1 — mixer + BEST buses; Day 2 — indie app fair + dinner. Both start at 5 PM. Day 1 wraps by 8:30 PM; Day 2 wraps by 8:30 PM and is only for conference attendees with apps, with no outside guests. Details to come!",
                contentHTML: "<p>Swift Bharat 2026 takes place on 19–20 November 2026 at Yashwantrao Chavan Centre in Mumbai.</p>\n<h2>Announced speakers</h2>\n<p><img src=\"https://www.swiftbharat.org/2026/speakers/donny-wals.webp\" alt=\"Donny Wals\" width=\"196\" height=\"254\" /><img src=\"https://www.swiftbharat.org/2026/stickers/speakers/donny-wals.webp\" alt=\"Dabbawala steel tiffin carrier tagged “await” with a stroopwafel on the lid\" width=\"96\" height=\"96\" /><br /><strong>Donny Wals</strong> — Indie Developer, Consultant, and Content Creator<br /><em>Dabbawala-grade await:</em> Donny wrote the book on Swift Concurrency. Mumbai’s dabbawalas deliver lakhs of lunches a day without a data race: every tiffin awaited, none lost. Stroopwafel for the flight from the Netherlands.</p>\n<p><img src=\"https://www.swiftbharat.org/2026/speakers/monika-mateska.webp\" alt=\"Monika Mateska\" width=\"196\" height=\"254\" /><img src=\"https://www.swiftbharat.org/2026/stickers/speakers/monika-mateska.webp\" alt=\"Developer in yoga tree pose on a mat, balancing an open laptop full of code on one palm\" width=\"96\" height=\"96\" /><br /><strong>Monika Mateska</strong> — Software engineer at RevenueCat and conference organizer<br /><em>Tree pose, green build:</em> Monika codes and does yoga, sometimes at the same time. Balanced on one leg, laptop in one hand, build passing: peak work–life balance.</p>\n<p><img src=\"https://www.swiftbharat.org/2026/speakers/marcin-krzyzanowski.webp\" alt=\"Marcin Krzyzanowski\" width=\"196\" height=\"254\" /><img src=\"https://www.swiftbharat.org/2026/stickers/speakers/marcin-krzyzanowski.webp\" alt=\"Brass Indian padlock clamped onto a spiral notepad full of code\" width=\"96\" height=\"96\" /><br /><strong>Marcin Krzyzanowski</strong> — Open source developer, building Notepad.exe, and senior engineer at Goodnotes<br /><em>Locked and noted:</em> CryptoSwift keeps a lot of apps’ secrets safe, and now he’s building Notepad.exe. So: a trusty brass padlock on a notepad full of code.</p>\n<p><img src=\"https://www.swiftbharat.org/2026/speakers/hidde-van-der-ploeg.webp\" alt=\"Hidde van der Ploeg\" width=\"196\" height=\"254\" /><img src=\"https://www.swiftbharat.org/2026/stickers/speakers/hidde-van-der-ploeg.webp\" alt=\"Brushed-aluminium award cube engraved “Mustafa’s Design Award”\" width=\"96\" height=\"96\" /><br /><strong>Hidde van der Ploeg</strong> — Better than Mustafa at everything<br /><em>Mustafa’s Design Award:</em> Hidde is the best at crafting delightful app experiences, and Mustafa’s favourite to win the design award (after a few others, obviously). So he gets the only cube that matters.</p>\n<p><img src=\"https://www.swiftbharat.org/2026/speakers/natasha-the-robot.webp\" alt=\"Natasha The Robot\" width=\"196\" height=\"254\" /><img src=\"https://www.swiftbharat.org/2026/stickers/speakers/natasha-the-robot.webp\" alt=\"Retro tin robot munching Kerala banana chips on a mangrove root\" width=\"96\" height=\"96\" /><br /><strong>Natasha The Robot</strong> — Creator, writer, and community organizer<br /><em>Powered by banana chips:</em> Natasha has spent a good stretch of time in Kerala, out by the mangroves. Every robot needs fuel, and in Kerala that’s a paper cone of crispy banana chips.</p>\n<p><img src=\"https://www.swiftbharat.org/2026/speakers/nikhil-nigade.webp\" alt=\"Nikhil Nigade\" width=\"196\" height=\"254\" /><img src=\"https://www.swiftbharat.org/2026/stickers/speakers/nikhil-nigade.webp\" alt=\"Rolled Mumbai newspaper with an RSS symbol in a paperboy bicycle carrier\" width=\"96\" height=\"96\" /><br /><strong>Nikhil Nigade</strong> — Indie iOS and macOS developer, designing delightful apps<br /><em>The original feed reader:</em> Nikhil builds Elytra, a lovingly crafted RSS reader. Mumbai’s original feed still arrives by bicycle at 6 AM, tied with string.</p>\n<p><img src=\"https://www.swiftbharat.org/2026/speakers/kanishka-chaudhry.webp\" alt=\"Kanishka Chaudhry\" width=\"196\" height=\"254\" /><img src=\"https://www.swiftbharat.org/2026/stickers/speakers/kanishka-chaudhry.webp\" alt=\"Kanishka in a scholar cap, holding a laptop and a diploma, as a Swift Student Challenge winner\" width=\"96\" height=\"96\" /><br /><strong>Kanishka Chaudhry</strong> — iOS engineer at Upstox and Apple Scholar<br /><em>Class of Swift:</em> Kanishka is a Swift Student Challenge winner and Apple Scholar. Scholar cap on, diploma up, code on screen: ready to ship.</p>\n<p><img src=\"https://www.swiftbharat.org/2026/speakers/josh-holtz.webp\" alt=\"Josh Holtz\" width=\"196\" height=\"254\" /><img src=\"https://www.swiftbharat.org/2026/stickers/speakers/josh-holtz.webp\" alt=\"Auto-rickshaw marked “Fast Lane” speeding with a deep-dish pizza on its roof\" width=\"96\" height=\"96\" /><br /><strong>Josh Holtz</strong> — Odd jobs at RevenueCat, lead maintainer of fastlane, and organizer of Deep Dish Swift<br /><em>Deep dish, fast lane:</em> Josh maintains fastlane and runs Deep Dish Swift in Chicago. Nothing beats Mumbai traffic like an auto-rickshaw, and this one’s delivering deep dish.</p>\n<p><img src=\"https://www.swiftbharat.org/2026/speakers/ratnesh-jain.webp\" alt=\"Ratnesh Jain\" width=\"196\" height=\"254\" /><img src=\"https://www.swiftbharat.org/2026/stickers/speakers/ratnesh-jain.webp\" alt=\"Vintage loudspeaker horn wired to a Raspberry Pi board, with colourful speech bubbles bursting out\" width=\"96\" height=\"96\" /><br /><strong>Ratnesh Jain</strong> — Indie developer building CommunityTalks<br /><em>Broadcasting from a Pi:</em> Ratnesh runs Swift on a Raspberry Pi (ask him at his talk) and his CommunityTalks app is powered by one. So: Mumbai’s lamp-post loudspeaker, wired straight into a Pi.</p>\n<p>The provisional schedule is available: Day 1 runs 9:00 AM–5:00 PM IST and Day 2 runs 10:00 AM–5:00 PM IST. Speaker names for each session and talk titles will be announced soon. Tickets start at ₹4,999 and include all keynote sessions, lunch and refreshments, conference materials, and the post-conference mixer. Tentative evening plans: Day 1 — mixer + BEST buses; Day 2 — indie app fair + dinner. Both start at 5 PM. Day 1 wraps by 8:30 PM; Day 2 wraps by 8:30 PM and is only for conference attendees with apps, with no outside guests. Details to come!</p>",
                imageURL: URL(string: "https://www.swiftbharat.org/og-image.jpg")!,
                tags: ["Swift", "iOS", "Apple development", "conference", "Mumbai", "speakers"],
                dateModified: Date(timeIntervalSince1970: 1790768474.092821)
            ),
            ConferencesFeedItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000513")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                feedID: "https://www.swiftbharat.org/#schedule-2026-11-19",
                url: URL(string: "https://www.swiftbharat.org/#schedule")!,
                title: "Day 1 schedule — 19 November 2026",
                summary: "Provisional Day 1 schedule: 9:00 AM–5:00 PM IST, including sessions, lunch, and Chai breaks. Tentative Post-conference mixer + BEST buses from 5 PM, wrapping by 8:30 PM at the latest.",
                contentText: "Swift Bharat 2026 Day 1 — Thursday, Nov 19, 2026\nYashwantrao Chavan Centre, Mumbai\nAll times in IST (UTC+05:30).\n\n9:00 AM–10:00 AM: Welcome & reception (60 min)\n10:00 AM–10:10 AM: Welcome & opening (10 min)\n10:10 AM–10:50 AM: Session 01 (40 min)\n10:50 AM–11:30 AM: Session 02 (40 min)\n11:30 AM–11:50 AM: Chai break (20 min)\n11:50 AM–12:30 PM: Session 03 (40 min)\n12:30 PM–12:50 PM: Session 04 (20 min)\n12:50 PM–12:55 PM: Buffer ¯\\_(ツ)_/¯ (5 min)\n12:55 PM–2:05 PM: Lunch (70 min)\n2:05 PM–2:45 PM: Session 05 (40 min)\n2:45 PM–3:25 PM: Session 06 (40 min)\n3:25 PM–3:55 PM: Chai break (30 min)\n3:55 PM–5:00 PM: Surprise \\( ^o^ )/ (65 min)\n5:00 PM–8:30 PM at the latest: Post-conference mixer + BEST buses (tentative)\nThe talks wrap. Mumbai takes over! Mingling, vada pav + iconic red BEST buses. Plans still cooking — 5 PM to 8:30 PM latest. Details soon!\n\nProvisional schedule · Subject to change. Session details will be announced soon.",
                contentHTML: "",
                imageURL: nil,
                tags: ["schedule", "day 1", "Swift Bharat 2026"],
                dateModified: Date(timeIntervalSince1970: 1789472665.164171)
            ),
            ConferencesFeedItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000514")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                feedID: "https://www.swiftbharat.org/#schedule-2026-11-20",
                url: URL(string: "https://www.swiftbharat.org/#schedule")!,
                title: "Day 2 schedule — 20 November 2026",
                summary: "Provisional Day 2 schedule: 10:00 AM–5:00 PM IST, including sessions, lunch, and Chai breaks. Tentative Indie app fair + dinner from 5 PM, wrapping by 8:30 PM at the latest. For conference attendees with apps only; no outside guests.",
                contentText: "Swift Bharat 2026 Day 2 — Friday, Nov 20, 2026\nYashwantrao Chavan Centre, Mumbai\nAll times in IST (UTC+05:30).\n\n10:00 AM–10:10 AM: Welcome back (10 min)\n10:10 AM–10:50 AM: Session 01 (40 min)\n10:50 AM–11:30 AM: Session 02 (40 min)\n11:30 AM–12:00 PM: Chai break (30 min)\n12:00 PM–12:40 PM: Session 03 (40 min)\n12:40 PM–1:00 PM: Session 04 (20 min)\n1:00 PM–1:05 PM: Buffer ¯\\_(ツ)_/¯ (5 min)\n1:05 PM–2:20 PM: Lunch (75 min)\n2:20 PM–3:00 PM: Session 05 (40 min)\n3:00 PM–3:20 PM: Session 06 (20 min)\n3:20 PM–3:45 PM: Chai break (25 min)\n3:45 PM–4:45 PM: Live podcast (60 min)\n4:45 PM–5:00 PM: Closing & goodbyes (15 min)\n5:00 PM–8:30 PM at the latest: Indie app fair + dinner (tentative)\nSmall apps. Big appetites. Show off your app, meet fellow makers + swap stories over dinner. Only for conference attendees with apps; no outside guests. Tentative: 5 PM–8:30 PM. Details soon!\n\nProvisional schedule · Subject to change. Session details will be announced soon.",
                contentHTML: "",
                imageURL: nil,
                tags: ["schedule", "day 2", "Swift Bharat 2026"],
                dateModified: Date(timeIntervalSince1970: 1789470861.042919)
            ),
        ]
    }
}
