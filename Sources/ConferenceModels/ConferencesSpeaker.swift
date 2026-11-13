import Dependencies
import Foundation
import SQLiteData

@Table
public struct ConferencesSpeaker: Codable, Equatable, Identifiable, Sendable {
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
                name: "Opening guest",
                role: "A special guest to start things off. Revealed live on stage.",
                website: nil,
                x: nil,
                linkedin: nil,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/opening-guest.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/opening-guest.webp")!,
                    title: "The first spark",
                    summary: "Every great gathering starts with a spark. A little light, a swift taking flight, and a special guest to set the day in motion.",
                    alt: "Brass inauguration lamp with a flame shaped like a swift taking flight"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Donny Wals",
                role: "Indie Developer, Consultant, and Content Creator",
                website: URL(string: "https://www.donnywals.com")!,
                x: URL(string: "https://x.com/DonnyWals")!,
                linkedin: URL(string: "https://www.linkedin.com/in/donny-wals-33660014/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/donny-wals.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/donny-wals.webp")!,
                    title: "Dabbawala-grade await",
                    summary: "Donny wrote the book on Swift Concurrency. Mumbai’s dabbawalas deliver lakhs of lunches a day without a data race: every tiffin awaited, none lost. Stroopwafel for the flight from the Netherlands.",
                    alt: "Dabbawala steel tiffin carrier tagged “await” with a stroopwafel on the lid"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000022")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Monika Sardjoska",
                role: "Software engineer at RevenueCat & Conference organizer",
                website: nil,
                x: URL(string: "https://x.com/monika_mateska")!,
                linkedin: URL(string: "https://www.linkedin.com/in/monika-mateska-54796b185/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/monika-mateska.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/monika-mateska.webp")!,
                    title: "Tree pose, green build",
                    summary: "Monika codes and does yoga, sometimes at the same time. Balanced on one leg, laptop in one hand, build passing: peak work–life balance.",
                    alt: "Developer in yoga tree pose on a mat, balancing an open laptop full of code on one palm"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000023")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Marcin Krzyzanowski",
                role: "Open Source, building Notepad.exe & senior engineer GoodNotes",
                website: URL(string: "https://krzyzanowskim.com")!,
                x: URL(string: "https://x.com/krzyzanowskim")!,
                linkedin: URL(string: "https://www.linkedin.com/in/marcinkrzyzanowski/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/marcin-krzyzanowski.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/marcin-krzyzanowski.webp")!,
                    title: "Locked and noted",
                    summary: "CryptoSwift keeps a lot of apps’ secrets safe, and now he’s building Notepad.exe. So: a trusty brass padlock on a notepad full of code.",
                    alt: "Brass Indian padlock clamped onto a spiral notepad full of code"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000024")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Hidde van der Ploeg",
                role: "Better than Mustafa at everything",
                website: URL(string: "https://hidde.design")!,
                x: URL(string: "https://x.com/hiddevdploeg")!,
                linkedin: URL(string: "https://www.linkedin.com/in/hiddevdploeg/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/hidde-van-der-ploeg.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/hidde-van-der-ploeg.webp")!,
                    title: "Mustafa’s Design Award",
                    summary: "Hidde is the best at crafting delightful app experiences, and Mustafa’s favourite to win the design award (after a few others, obviously). So he gets the only cube that matters.",
                    alt: "Brushed-aluminium award cube engraved “Mustafa’s Design Award”"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000025")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Natasha The Robot",
                role: "Creator, Writer, Community Organizer",
                website: URL(string: "https://www.natashatherobot.com")!,
                x: URL(string: "https://x.com/natashatherobot")!,
                linkedin: URL(string: "https://www.linkedin.com/in/natashatherobot/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/natasha-the-robot.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/natasha-the-robot.webp")!,
                    title: "Powered by banana chips",
                    summary: "Natasha has spent a good stretch of time in Kerala, out by the mangroves. Every robot needs fuel, and in Kerala that’s a paper cone of crispy banana chips.",
                    alt: "Retro tin robot munching Kerala banana chips on a mangrove root"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000026")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Nikhil Nigade",
                role: "Indie iOS & macOS Developer, designing delightful apps",
                website: URL(string: "https://dezinezync.com")!,
                x: URL(string: "https://x.com/dezinezync")!,
                linkedin: URL(string: "https://www.linkedin.com/in/nikhil-nigade-4a395b358/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/nikhil-nigade.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/nikhil-nigade.webp")!,
                    title: "The original feed reader",
                    summary: "Nikhil builds Elytra, a lovingly crafted RSS reader. Mumbai’s original feed still arrives by bicycle at 6 AM, tied with string.",
                    alt: "Rolled Mumbai newspaper with an RSS symbol in a paperboy bicycle carrier"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000027")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Kanishka Chaudhry",
                role: "iOS engineer at Upstox and Apple Scholar",
                website: nil,
                x: URL(string: "https://x.com/ralasi_")!,
                linkedin: URL(string: "https://www.linkedin.com/in/kanishka-c/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/kanishka-chaudhry.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/kanishka-chaudhry.webp")!,
                    title: "Class of Swift",
                    summary: "Kanishka is a Swift Student Challenge winner and Apple Scholar. Scholar cap on, diploma up, code on screen: ready to ship.",
                    alt: "Kanishka in a scholar cap, holding a laptop and a diploma, as a Swift Student Challenge winner"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000028")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Josh Holtz",
                role: "Odd jobs at RevenueCat, Lead maintainer of fastlane & Organizer of Deep Dish Swift",
                website: URL(string: "https://www.joshholtz.com")!,
                x: URL(string: "https://x.com/joshdholtz")!,
                linkedin: URL(string: "https://www.linkedin.com/in/josh-holtz-771b582a/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/josh-holtz.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/josh-holtz.webp")!,
                    title: "Deep dish, fast lane",
                    summary: "Josh maintains fastlane and runs Deep Dish Swift in Chicago. Nothing beats Mumbai traffic like an auto-rickshaw, and this one’s delivering deep dish.",
                    alt: "Auto-rickshaw marked “Fast Lane” speeding with a deep-dish pizza on its roof"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000029")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Ratnesh Jain",
                role: "Indie Developer | Building CommunityTalks",
                website: URL(string: "https://ratnesh-jain.github.io")!,
                x: URL(string: "https://x.com/ratneshjain1993")!,
                linkedin: URL(string: "https://www.linkedin.com/in/ratnesh-jain-7a2270146/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/ratnesh-jain.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/ratnesh-jain.webp")!,
                    title: "Broadcasting from a Pi",
                    summary: "Ratnesh runs Swift on a Raspberry Pi (ask him at his talk) and his CommunityTalks app is powered by one. So: Mumbai’s lamp-post loudspeaker, wired straight into a Pi.",
                    alt: "Vintage loudspeaker horn wired to a Raspberry Pi board, with colourful speech bubbles bursting out"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Sabesh Bharathi",
                role: "Researcher + Engineer at Conscious Engines & MLX India organizer",
                website: URL(string: "https://sabesh.space")!,
                x: URL(string: "https://x.com/sabeshbharathi")!,
                linkedin: URL(string: "https://www.linkedin.com/in/sabeshbharathi/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/sabesh-bharathi.png")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/sabesh-bharathi.webp")!,
                    title: "Local Intelligence",
                    summary: "Sabesh researches and builds at Conscious Engines and brings the MLX India community together. So his Mumbai local runs on a different kind of engine: a little silicon, a lot of curiosity, and room for everyone building what comes next.",
                    alt: "Mumbai local train with a glowing microchip engine and teal circuit traces"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Ashutosh Vashishtha",
                role: "Design Evangelist at Apple",
                website: nil,
                x: nil,
                linkedin: URL(string: "https://www.linkedin.com/in/ashutosh-vashishtha-81aa74153")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/ashutosh-vashishtha.png")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/ashutosh-vashishtha.webp")!,
                    title: "Mind the Details",
                    summary: "A ticket. A button. A few words in the right place. Ashutosh’s sticker celebrates the small decisions that make design feel considered, even when you’re rushing to catch the next local.",
                    alt: "Brass magnifying glass over a Mumbai train ticket, revealing aligned type and a rounded teal button"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000032")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Charlie Chapman",
                role: "Developer Advocate at RevenueCat, host of the Launched podcast, and creator of Dark Noise",
                website: URL(string: "https://charliemchapman.com")!,
                x: URL(string: "https://x.com/_chuckyc")!,
                linkedin: URL(string: "https://www.linkedin.com/in/charliemchapman/")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/charlie-chapman.png")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/charlie-chapman.webp")!,
                    title: "Launched after dark",
                    summary: "Charlie helps developers at RevenueCat, hosts Launched, and created Dark Noise. A microphone, a launch, and a little nighttime ambience: three parts of his world, ready for liftoff.",
                    alt: "Podcast microphone rocket taking off beside a crescent moon with soft blue sound waves for exhaust"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000033")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Kabir Oberai",
                role: "Founder, building an AI-native mobile development stack | Creator of xtool.sh",
                website: URL(string: "https://ober.ai")!,
                x: URL(string: "https://x.com/kabiroberai")!,
                linkedin: URL(string: "https://www.linkedin.com/in/kabiroberai")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/kabir-oberai.png")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/kabir-oberai.webp")!,
                    title: "The pocket workshop",
                    summary: "Kabir created xtool.sh and is building an AI-native mobile development stack. His sticker is a pocket workshop for making apps: tools within reach, ideas on the bench, and something new taking shape.",
                    alt: "Open red metal toolbox labelled xtool containing a smartphone, terminal window, and steel spanner"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000034")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Aarshad Devani",
                role: "Senior AI Architect - Cobweb MENA FZ",
                website: nil,
                x: nil,
                linkedin: URL(string: "https://www.linkedin.com/in/aarshaddevani")!,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/aarshad-devani.webp")!,
                sticker: ConferencesSticker(
                    imageURL: URL(string: "https://www.swiftbharat.org/2026/stickers/speakers/aarshad-devani.webp")!,
                    title: "Smooth sailing with AI",
                    summary: "Aarshad shows how he uses Logitech devices to move through AI workflows and get more done. A mouse, a keyboard, and a little wind in the sails.",
                    alt: "Logitech-style mouse resting on a keyboard with a small AI sail"
                )
            ),
            ConferencesSpeaker(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000035")!,
                eventID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Manoj Kumar",
                role: "Engineering Manager at Zoho",
                website: nil,
                x: URL(string: "https://x.com/manoj_ios")!,
                linkedin: nil,
                imageURL: URL(string: "https://www.swiftbharat.org/2026/speakers/manoj-kumar.webp")!,
                sticker: nil
            ),
        ]
    }
}
