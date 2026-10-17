import Dependencies
import Foundation
import SQLiteData

@Table
public struct ConferencesSpeaker: Equatable, Identifiable, Sendable {
    public let id: UUID

    public var eventID: ConferencesEvent.ID
    public var name = ""
    public var role = ""
    public var website: URL?
    public var x: URL?
    public var linkedin: URL?
    public var imageURL: URL?
    @Column(as: ConferencesSticker?.JSONRepresentation.self)
    public var sticker: ConferencesSticker?

    public init(
        id: UUID = { @Dependency(\.uuid) var uuid; return uuid() }(),
        eventID: ConferencesEvent.ID,
        name: String = "",
        role: String = "",
        website: URL? = nil,
        x: URL? = nil,
        linkedin: URL? = nil,
        imageURL: URL? = nil,
        sticker: ConferencesSticker? = nil
    ) {
        self.id = id
        self.eventID = eventID
        self.name = name
        self.role = role
        self.website = website
        self.x = x
        self.linkedin = linkedin
        self.imageURL = imageURL
        self.sticker = sticker
    }
}

extension ConferencesSpeaker {
    public static func migrate(using migrator: inout DatabaseMigrator) throws {
        migrator.registerMigration("Create 'conferencesSpeakers' table") { db in
            try #sql("""
                CREATE TABLE "conferencesSpeakers" (
                  "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                  "eventID" TEXT NOT NULL REFERENCES "conferencesEvents"("id") ON DELETE CASCADE,
                  "name" TEXT NOT NULL DEFAULT '',
                  "role" TEXT NOT NULL DEFAULT '',
                  "website" TEXT,
                  "x" TEXT,
                  "linkedin" TEXT,
                  "imageURL" TEXT,
                  "sticker" TEXT
                ) STRICT
                """)
                .execute(db)

            try #sql("""
                CREATE INDEX "index_conferencesSpeakers_on_eventID" ON "conferencesSpeakers"("eventID")
                """)
                .execute(db)
        }
    }
}

@Selection
public struct ConferencesSticker: Equatable, Codable, Sendable {
    public var imageURL: URL?
    public var title = ""
    public var summary = ""
    public var alt = ""

    public init(
        imageURL: URL? = nil,
        title: String = "",
        summary: String = "",
        alt: String = ""
    ) {
        self.imageURL = imageURL
        self.title = title
        self.summary = summary
        self.alt = alt
    }
}

extension ConferencesSpeaker {
    public static var seedData: [ConferencesSpeaker] {
        @Dependency(\.context) var context
        guard context != .live else { return [] }
        return [
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Donny Wals",
                role: "Indie Developer, Consultant, and Content Creator",
                website: URL(string: "https://www.donnywals.com")!,
                x: URL(string: "https://x.com/DonnyWals")!,
                linkedin: URL(string: "https://www.linkedin.com/in/donny-wals-33660014/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/donny-wals.webp")!,
                sticker: ConferencesSticker(imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/donny-wals.webp")!, title: "Dabbawala-grade await", summary: "Donny wrote the book on Swift Concurrency. Mumbai’s dabbawalas deliver lakhs of lunches a day without a data race: every tiffin awaited, none lost. Stroopwafel for the flight from the Netherlands.", alt: "Dabbawala steel tiffin carrier tagged “await” with a stroopwafel on the lid")
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Monika Mateska",
                role: "Software engineer at RevenueCat and conference organizer",
                website: nil,
                x: URL(string: "https://x.com/monika_mateska")!,
                linkedin: URL(string: "https://www.linkedin.com/in/monika-mateska-54796b185/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/monika-mateska.webp")!,
                sticker: ConferencesSticker(imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/monika-mateska.webp")!, title: "Tree pose, green build", summary: "Monika codes and does yoga, sometimes at the same time. Balanced on one leg, laptop in one hand, build passing: peak work–life balance.", alt: "Developer in yoga tree pose on a mat, balancing an open laptop full of code on one palm")
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000022")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Marcin Krzyzanowski",
                role: "Open source developer, building Notepad.exe, and senior engineer at Goodnotes",
                website: URL(string: "https://krzyzanowskim.com")!,
                x: URL(string: "https://x.com/krzyzanowskim")!,
                linkedin: URL(string: "https://www.linkedin.com/in/marcinkrzyzanowski/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/marcin-krzyzanowski.webp")!,
                sticker: ConferencesSticker(imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/marcin-krzyzanowski.webp")!, title: "Locked and noted", summary: "CryptoSwift keeps a lot of apps’ secrets safe, and now he’s building Notepad.exe. So: a trusty brass padlock on a notepad full of code.", alt: "Brass Indian padlock clamped onto a spiral notepad full of code")
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000023")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Hidde van der Ploeg",
                role: "Better than Mustafa at everything",
                website: URL(string: "https://hidde.design")!,
                x: URL(string: "https://x.com/hiddevdploeg")!,
                linkedin: URL(string: "https://www.linkedin.com/in/hiddevdploeg/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/hidde-van-der-ploeg.webp")!,
                sticker: ConferencesSticker(imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/hidde-van-der-ploeg.webp")!, title: "Mustafa’s Design Award", summary: "Hidde is the best at crafting delightful app experiences, and Mustafa’s favourite to win the design award (after a few others, obviously). So he gets the only cube that matters.", alt: "Brushed-aluminium award cube engraved “Mustafa’s Design Award”")
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000024")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Natasha The Robot",
                role: "Creator, writer, and community organizer",
                website: URL(string: "https://www.natashatherobot.com")!,
                x: URL(string: "https://x.com/natashatherobot")!,
                linkedin: URL(string: "https://www.linkedin.com/in/natashatherobot/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/natasha-the-robot.webp")!,
                sticker: ConferencesSticker(imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/natasha-the-robot.webp")!, title: "Powered by banana chips", summary: "Natasha has spent a good stretch of time in Kerala, out by the mangroves. Every robot needs fuel, and in Kerala that’s a paper cone of crispy banana chips.", alt: "Retro tin robot munching Kerala banana chips on a mangrove root")
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000025")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Nikhil Nigade",
                role: "Indie iOS and macOS developer, designing delightful apps",
                website: URL(string: "https://dezinezync.com")!,
                x: URL(string: "https://x.com/dezinezync")!,
                linkedin: URL(string: "https://www.linkedin.com/in/nikhil-nigade-4a395b358/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/nikhil-nigade.webp")!,
                sticker: ConferencesSticker(imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/nikhil-nigade.webp")!, title: "The original feed reader", summary: "Nikhil builds Elytra, a lovingly crafted RSS reader. Mumbai’s original feed still arrives by bicycle at 6 AM, tied with string.", alt: "Rolled Mumbai newspaper with an RSS symbol in a paperboy bicycle carrier")
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000026")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Kanishka Chaudhry",
                role: "iOS engineer at Upstox and Apple Scholar",
                website: nil,
                x: URL(string: "https://x.com/ralasi_")!,
                linkedin: URL(string: "https://www.linkedin.com/in/kanishka-c/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/kanishka-chaudhry.webp")!,
                sticker: ConferencesSticker(imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/kanishka-chaudhry.webp")!, title: "Class of Swift", summary: "Kanishka is a Swift Student Challenge winner and Apple Scholar. Scholar cap on, diploma up, code on screen: ready to ship.", alt: "Kanishka in a scholar cap, holding a laptop and a diploma, as a Swift Student Challenge winner")
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000027")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Josh Holtz",
                role: "Odd jobs at RevenueCat, lead maintainer of fastlane, and organizer of Deep Dish Swift",
                website: URL(string: "https://www.joshholtz.com")!,
                x: URL(string: "https://x.com/joshdholtz")!,
                linkedin: URL(string: "https://www.linkedin.com/in/josh-holtz-771b582a/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/josh-holtz.webp")!,
                sticker: ConferencesSticker(imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/josh-holtz.webp")!, title: "Deep dish, fast lane", summary: "Josh maintains fastlane and runs Deep Dish Swift in Chicago. Nothing beats Mumbai traffic like an auto-rickshaw, and this one’s delivering deep dish.", alt: "Auto-rickshaw marked “Fast Lane” speeding with a deep-dish pizza on its roof")
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000028")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Ratnesh Jain",
                role: "Indie developer building CommunityTalks",
                website: URL(string: "https://ratnesh-jain.github.io")!,
                x: URL(string: "https://x.com/ratneshjain1993")!,
                linkedin: URL(string: "https://www.linkedin.com/in/ratnesh-jain-7a2270146/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/ratnesh-jain.webp")!,
                sticker: ConferencesSticker(imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/ratnesh-jain.webp")!, title: "Broadcasting from a Pi", summary: "Ratnesh runs Swift on a Raspberry Pi (ask him at his talk) and his CommunityTalks app is powered by one. So: Mumbai’s lamp-post loudspeaker, wired straight into a Pi.", alt: "Vintage loudspeaker horn wired to a Raspberry Pi board, with colourful speech bubbles bursting out")
            ),
        ]
    }
}
