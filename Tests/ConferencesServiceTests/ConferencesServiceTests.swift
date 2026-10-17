import ConferenceModels
import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import SQLiteDataTestSupport
import SnapshotTesting
import Testing
@testable import ConferencesService

@Suite(
  .serialized,
  .dependencies {
    $0.conferencesService = .live(fetchData: { url in
      let year = url.deletingLastPathComponent().lastPathComponent
      let resourceName = "swiftbharat-\(year)"
      let fileURL = Bundle.module.url(forResource: resourceName, withExtension: "json")
        ?? Bundle.module.url(forResource: "swiftbharat-2026", withExtension: "json")
      guard let fileURL else {
        throw ConferencesServiceError(invalidFeedURL: url.absoluteString)
      }
      return try Data(contentsOf: fileURL)
    })
    $0.uuid = .incrementing
    $0.defaultDatabase = try conferencesTestDatabase()
  },
  .snapshots(record: .missing)
)
struct ConferencesServiceTests {
  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func event() async throws {
    _ = try await service().fetchSwiftBharat(year: 2026)

    assertQuery(
      ConferencesEvent.all
    ) {
      """
      ┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
      │ ConferencesEvent(                                                                                    │
      │   id: UUID(E5E08E39-D571-5633-8D94-77930CF620A3),                                                    │
      │   name: "Swift Bharat 2026",                                                                         │
      │   summary: "Speakers, talks, schedule, tickets, and event updates for Swift Bharat 2026 in Mumbai.", │
      │   language: "en-IN",                                                                                 │
      │   version: "https://jsonfeed.org/version/1.1",                                                       │
      │   homePageURL: URL(https://www.swiftbharat.org/),                                                    │
      │   feedURL: URL(https://www.swiftbharat.org/2026/feed.json),                                          │
      │   iconURL: URL(https://www.swiftbharat.org/favicon.ico),                                             │
      │   startDate: Date(2026-11-19T00:00:00.000Z),                                                         │
      │   endDate: Date(2026-11-20T00:00:00.000Z),                                                           │
      │   timezone: "Asia/Kolkata",                                                                          │
      │   venue: ConferencesVenue(                                                                           │
      │     name: "Yashwantrao Chavan Centre",                                                               │
      │     city: "Mumbai",                                                                                  │
      │     region: "Maharashtra",                                                                           │
      │     country: "IN"                                                                                    │
      │   ),                                                                                                 │
      │   authors: [                                                                                         │
      │     [0]: ConferencesAuthor(                                                                          │
      │       name: "Swift Bharat",                                                                          │
      │       url: URL(https://www.swiftbharat.org/)                                                         │
      │     )                                                                                                │
      │   ]                                                                                                  │
      │ )                                                                                                    │
      └──────────────────────────────────────────────────────────────────────────────────────────────────────┘
      """
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func tickets() async throws {
    _ = try await service().fetchSwiftBharat(year: 2026)

    assertQuery(
      ConferencesTicket.all
        .order(by: \.price)
    ) {
      """
      ┌────────────────────────────────────────────────────────┐
      │ ConferencesTicket(                                     │
      │   id: UUID(031A54DE-9B14-5724-B7B6-EF8004078156),      │
      │   eventID: UUID(E5E08E39-D571-5633-8D94-77930CF620A3), │
      │   name: "Super Early Bird",                            │
      │   price: 4999,                                         │
      │   currency: "INR",                                     │
      │   url: URL(https://www.swiftbharat.org/#tickets)       │
      │ )                                                      │
      ├────────────────────────────────────────────────────────┤
      │ ConferencesTicket(                                     │
      │   id: UUID(AF7A8D66-0EEB-5C11-A9C7-DF140B6A0B76),      │
      │   eventID: UUID(E5E08E39-D571-5633-8D94-77930CF620A3), │
      │   name: "Regular Ticket",                              │
      │   price: 5999,                                         │
      │   currency: "INR",                                     │
      │   url: URL(https://www.swiftbharat.org/#tickets)       │
      │ )                                                      │
      └────────────────────────────────────────────────────────┘
      """
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func speakers() async throws {
    _ = try await service().fetchSwiftBharat(year: 2026)

    assertQuery(
      ConferencesSpeaker.all
        .order(by: \.name)
        .select {
          (
            $0.name,
            $0.role,
            $0.website,
            $0.x,
            $0.linkedin,
            $0.imageURL,
            $0.sticker
          )
        }
    ) {
      """
      ┌───────────────────────┬─────────────────────────────────────────────────────────────────────────────────────────┬──────────────────────────────────────┬────────────────────────────────────┬────────────────────────────────────────────────────────────┬─────────────────────────────────────────────────────────────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
      │ "Donny Wals"          │ "Indie Developer, Consultant, and Content Creator"                                      │ URL(https://www.donnywals.com)       │ URL(https://x.com/DonnyWals)       │ URL(https://www.linkedin.com/in/donny-wals-33660014/)      │ URL(https://www.swiftbharat.org/2026/speakers/donny-wals.webp)          │ ConferencesSticker(                                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   imageURL: URL(https://www.swiftbharat.org/2026/stickers/speakers/donny-wals.webp),                                                                                                                               │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   title: "Dabbawala-grade await",                                                                                                                                                                                  │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   summary: "Donny wrote the book on Swift Concurrency. Mumbai’s dabbawalas deliver lakhs of lunches a day without a data race: every tiffin awaited, none lost. Stroopwafel for the flight from the Netherlands.", │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   alt: "Dabbawala steel tiffin carrier tagged “await” with a stroopwafel on the lid"                                                                                                                               │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │ )                                                                                                                                                                                                                  │
      ├───────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┼────────────────────────────────────┼────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
      │ "Hidde van der Ploeg" │ "Better than Mustafa at everything"                                                     │ URL(https://hidde.design)            │ URL(https://x.com/hiddevdploeg)    │ URL(https://www.linkedin.com/in/hiddevdploeg/)             │ URL(https://www.swiftbharat.org/2026/speakers/hidde-van-der-ploeg.webp) │ ConferencesSticker(                                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   imageURL: URL(https://www.swiftbharat.org/2026/stickers/speakers/hidde-van-der-ploeg.webp),                                                                                                                      │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   title: "Mustafa’s Design Award",                                                                                                                                                                                 │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   summary: "Hidde is the best at crafting delightful app experiences, and Mustafa’s favourite to win the design award (after a few others, obviously). So he gets the only cube that matters.",                    │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   alt: "Brushed-aluminium award cube engraved “Mustafa’s Design Award”"                                                                                                                                            │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │ )                                                                                                                                                                                                                  │
      ├───────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┼────────────────────────────────────┼────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
      │ "Josh Holtz"          │ "Odd jobs at RevenueCat, lead maintainer of fastlane, and organizer of Deep Dish Swift" │ URL(https://www.joshholtz.com)       │ URL(https://x.com/joshdholtz)      │ URL(https://www.linkedin.com/in/josh-holtz-771b582a/)      │ URL(https://www.swiftbharat.org/2026/speakers/josh-holtz.webp)          │ ConferencesSticker(                                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   imageURL: URL(https://www.swiftbharat.org/2026/stickers/speakers/josh-holtz.webp),                                                                                                                               │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   title: "Deep dish, fast lane",                                                                                                                                                                                   │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   summary: "Josh maintains fastlane and runs Deep Dish Swift in Chicago. Nothing beats Mumbai traffic like an auto-rickshaw, and this one’s delivering deep dish.",                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   alt: "Auto-rickshaw marked “Fast Lane” speeding with a deep-dish pizza on its roof"                                                                                                                              │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │ )                                                                                                                                                                                                                  │
      ├───────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┼────────────────────────────────────┼────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
      │ "Kanishka Chaudhry"   │ "iOS engineer at Upstox and Apple Scholar"                                              │ nil                                  │ URL(https://x.com/ralasi_)         │ URL(https://www.linkedin.com/in/kanishka-c/)               │ URL(https://www.swiftbharat.org/2026/speakers/kanishka-chaudhry.webp)   │ ConferencesSticker(                                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   imageURL: URL(https://www.swiftbharat.org/2026/stickers/speakers/kanishka-chaudhry.webp),                                                                                                                        │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   title: "Class of Swift",                                                                                                                                                                                         │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   summary: "Kanishka is a Swift Student Challenge winner and Apple Scholar. Scholar cap on, diploma up, code on screen: ready to ship.",                                                                           │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   alt: "Kanishka in a scholar cap, holding a laptop and a diploma, as a Swift Student Challenge winner"                                                                                                            │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │ )                                                                                                                                                                                                                  │
      ├───────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┼────────────────────────────────────┼────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
      │ "Marcin Krzyzanowski" │ "Open source developer, building Notepad.exe, and senior engineer at Goodnotes"         │ URL(https://krzyzanowskim.com)       │ URL(https://x.com/krzyzanowskim)   │ URL(https://www.linkedin.com/in/marcinkrzyzanowski/)       │ URL(https://www.swiftbharat.org/2026/speakers/marcin-krzyzanowski.webp) │ ConferencesSticker(                                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   imageURL: URL(https://www.swiftbharat.org/2026/stickers/speakers/marcin-krzyzanowski.webp),                                                                                                                      │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   title: "Locked and noted",                                                                                                                                                                                       │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   summary: "CryptoSwift keeps a lot of apps’ secrets safe, and now he’s building Notepad.exe. So: a trusty brass padlock on a notepad full of code.",                                                              │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   alt: "Brass Indian padlock clamped onto a spiral notepad full of code"                                                                                                                                           │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │ )                                                                                                                                                                                                                  │
      ├───────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┼────────────────────────────────────┼────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
      │ "Monika Mateska"      │ "Software engineer at RevenueCat and conference organizer"                              │ nil                                  │ URL(https://x.com/monika_mateska)  │ URL(https://www.linkedin.com/in/monika-mateska-54796b185/) │ URL(https://www.swiftbharat.org/2026/speakers/monika-mateska.webp)      │ ConferencesSticker(                                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   imageURL: URL(https://www.swiftbharat.org/2026/stickers/speakers/monika-mateska.webp),                                                                                                                           │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   title: "Tree pose, green build",                                                                                                                                                                                 │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   summary: "Monika codes and does yoga, sometimes at the same time. Balanced on one leg, laptop in one hand, build passing: peak work–life balance.",                                                              │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   alt: "Developer in yoga tree pose on a mat, balancing an open laptop full of code on one palm"                                                                                                                   │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │ )                                                                                                                                                                                                                  │
      ├───────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┼────────────────────────────────────┼────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
      │ "Natasha The Robot"   │ "Creator, writer, and community organizer"                                              │ URL(https://www.natashatherobot.com) │ URL(https://x.com/natashatherobot) │ URL(https://www.linkedin.com/in/natashatherobot/)          │ URL(https://www.swiftbharat.org/2026/speakers/natasha-the-robot.webp)   │ ConferencesSticker(                                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   imageURL: URL(https://www.swiftbharat.org/2026/stickers/speakers/natasha-the-robot.webp),                                                                                                                        │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   title: "Powered by banana chips",                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   summary: "Natasha has spent a good stretch of time in Kerala, out by the mangroves. Every robot needs fuel, and in Kerala that’s a paper cone of crispy banana chips.",                                          │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   alt: "Retro tin robot munching Kerala banana chips on a mangrove root"                                                                                                                                           │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │ )                                                                                                                                                                                                                  │
      ├───────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┼────────────────────────────────────┼────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
      │ "Nikhil Nigade"       │ "Indie iOS and macOS developer, designing delightful apps"                              │ URL(https://dezinezync.com)          │ URL(https://x.com/dezinezync)      │ URL(https://www.linkedin.com/in/nikhil-nigade-4a395b358/)  │ URL(https://www.swiftbharat.org/2026/speakers/nikhil-nigade.webp)       │ ConferencesSticker(                                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   imageURL: URL(https://www.swiftbharat.org/2026/stickers/speakers/nikhil-nigade.webp),                                                                                                                            │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   title: "The original feed reader",                                                                                                                                                                               │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   summary: "Nikhil builds Elytra, a lovingly crafted RSS reader. Mumbai’s original feed still arrives by bicycle at 6 AM, tied with string.",                                                                      │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   alt: "Rolled Mumbai newspaper with an RSS symbol in a paperboy bicycle carrier"                                                                                                                                  │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │ )                                                                                                                                                                                                                  │
      ├───────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────────┼────────────────────────────────────┼────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
      │ "Ratnesh Jain"        │ "Indie developer building CommunityTalks"                                               │ URL(https://ratnesh-jain.github.io)  │ URL(https://x.com/ratneshjain1993) │ URL(https://www.linkedin.com/in/ratnesh-jain-7a2270146/)   │ URL(https://www.swiftbharat.org/2026/speakers/ratnesh-jain.webp)        │ ConferencesSticker(                                                                                                                                                                                                │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   imageURL: URL(https://www.swiftbharat.org/2026/stickers/speakers/ratnesh-jain.webp),                                                                                                                             │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   title: "Broadcasting from a Pi",                                                                                                                                                                                 │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   summary: "Ratnesh runs Swift on a Raspberry Pi (ask him at his talk) and his CommunityTalks app is powered by one. So: Mumbai’s lamp-post loudspeaker, wired straight into a Pi.",                               │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │   alt: "Vintage loudspeaker horn wired to a Raspberry Pi board, with colourful speech bubbles bursting out"                                                                                                        │
      │                       │                                                                                         │                                      │                                    │                                                            │                                                                         │ )                                                                                                                                                                                                                  │
      └───────────────────────┴─────────────────────────────────────────────────────────────────────────────────────────┴──────────────────────────────────────┴────────────────────────────────────┴────────────────────────────────────────────────────────────┴─────────────────────────────────────────────────────────────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
      """
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func scheduleDays() async throws {
    _ = try await service().fetchSwiftBharat(year: 2026)

    assertQuery(
      ConferencesScheduleDay.all
        .order(by: \.date)
        .select { ($0.date, $0.status) }
    ) {
      """
      ┌────────────────────────────────┬──────────────┐
      │ Date(2026-11-19T00:00:00.000Z) │ .provisional │
      │ Date(2026-11-20T00:00:00.000Z) │ .provisional │
      └────────────────────────────────┴──────────────┘
      """
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func sessions() async throws {
    _ = try await service().fetchSwiftBharat(year: 2026)

    assertQuery(
      ConferencesSession.all
        .order(by: \.startTime)
        .select {
          (
            $0.scheduleDayID,
            $0.title,
            $0.startTime,
            $0.endTime,
            $0.durationMinutes,
            $0.status,
            $0.endTimeIsLatest
          )
        }
    ) {
      #"""
      ┌────────────────────────────────────────────┬──────────────────────────────────────┬────────────────────────────────┬────────────────────────────────┬────┬────────────┬───────┐
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Welcome & reception"                │ Date(2026-11-19T03:30:00.000Z) │ Date(2026-11-19T04:30:00.000Z) │ 60 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Welcome & opening"                  │ Date(2026-11-19T04:30:00.000Z) │ Date(2026-11-19T04:40:00.000Z) │ 10 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Session 01"                         │ Date(2026-11-19T04:40:00.000Z) │ Date(2026-11-19T05:20:00.000Z) │ 40 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Session 02"                         │ Date(2026-11-19T05:20:00.000Z) │ Date(2026-11-19T06:00:00.000Z) │ 40 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Chai break"                         │ Date(2026-11-19T06:00:00.000Z) │ Date(2026-11-19T06:20:00.000Z) │ 20 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Session 03"                         │ Date(2026-11-19T06:20:00.000Z) │ Date(2026-11-19T07:00:00.000Z) │ 40 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Session 04"                         │ Date(2026-11-19T07:00:00.000Z) │ Date(2026-11-19T07:20:00.000Z) │ 20 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ #"Buffer ¯\_(ツ)_/¯"#                 │ Date(2026-11-19T07:20:00.000Z) │ Date(2026-11-19T07:25:00.000Z) │ 5  │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Lunch"                              │ Date(2026-11-19T07:25:00.000Z) │ Date(2026-11-19T08:35:00.000Z) │ 70 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Session 05"                         │ Date(2026-11-19T08:35:00.000Z) │ Date(2026-11-19T09:15:00.000Z) │ 40 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Session 06"                         │ Date(2026-11-19T09:15:00.000Z) │ Date(2026-11-19T09:55:00.000Z) │ 40 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Chai break"                         │ Date(2026-11-19T09:55:00.000Z) │ Date(2026-11-19T10:25:00.000Z) │ 30 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ #"Surprise \( ^o^ )/"#               │ Date(2026-11-19T10:25:00.000Z) │ Date(2026-11-19T11:30:00.000Z) │ 65 │ nil        │ false │
      │ UUID(3D7D6504-390D-52D9-B8B4-C7BAE5991634) │ "Post-conference mixer + BEST buses" │ Date(2026-11-19T11:30:00.000Z) │ Date(2026-11-19T15:00:00.000Z) │ 0  │ .tentative │ true  │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Welcome back"                       │ Date(2026-11-20T04:30:00.000Z) │ Date(2026-11-20T04:40:00.000Z) │ 10 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Session 01"                         │ Date(2026-11-20T04:40:00.000Z) │ Date(2026-11-20T05:20:00.000Z) │ 40 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Session 02"                         │ Date(2026-11-20T05:20:00.000Z) │ Date(2026-11-20T06:00:00.000Z) │ 40 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Chai break"                         │ Date(2026-11-20T06:00:00.000Z) │ Date(2026-11-20T06:30:00.000Z) │ 30 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Session 03"                         │ Date(2026-11-20T06:30:00.000Z) │ Date(2026-11-20T07:10:00.000Z) │ 40 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Session 04"                         │ Date(2026-11-20T07:10:00.000Z) │ Date(2026-11-20T07:30:00.000Z) │ 20 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ #"Buffer ¯\_(ツ)_/¯"#                 │ Date(2026-11-20T07:30:00.000Z) │ Date(2026-11-20T07:35:00.000Z) │ 5  │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Lunch"                              │ Date(2026-11-20T07:35:00.000Z) │ Date(2026-11-20T08:50:00.000Z) │ 75 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Session 05"                         │ Date(2026-11-20T08:50:00.000Z) │ Date(2026-11-20T09:30:00.000Z) │ 40 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Session 06"                         │ Date(2026-11-20T09:30:00.000Z) │ Date(2026-11-20T09:50:00.000Z) │ 20 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Chai break"                         │ Date(2026-11-20T09:50:00.000Z) │ Date(2026-11-20T10:15:00.000Z) │ 25 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Live podcast"                       │ Date(2026-11-20T10:15:00.000Z) │ Date(2026-11-20T11:15:00.000Z) │ 60 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Closing & goodbyes"                 │ Date(2026-11-20T11:15:00.000Z) │ Date(2026-11-20T11:30:00.000Z) │ 15 │ nil        │ false │
      │ UUID(EA8C2D56-9C57-52E8-9238-FFC652E7BD2D) │ "Indie app fair + dinner"            │ Date(2026-11-20T11:30:00.000Z) │ Date(2026-11-20T15:00:00.000Z) │ 0  │ .tentative │ true  │
      └────────────────────────────────────────────┴──────────────────────────────────────┴────────────────────────────────┴────────────────────────────────┴────┴────────────┴───────┘
      """#
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func sessionsWithImageryAndDescriptions() async throws {
    _ = try await service().fetchSwiftBharat(year: 2026)

    assertQuery(
      ConferencesSession.all
        .where { $0.imageURL.isNot(nil) || $0.summary.neq("") || $0.audience.isNot(nil) }
        .order(by: \.startTime)
        .select { ($0.title, $0.imageURL, $0.summary, $0.audience) }
    ) {
      """
      ┌──────────────────────────────────────┬────────────────────────────────────────────────────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬───────────────────────────────────────────────────────────┐
      │ "Chai break"                         │ URL(https://www.swiftbharat.org/2026/stickers/chai-snacks.png)         │ ""                                                                                                                                                                                                │ nil                                                       │
      │ "Lunch"                              │ URL(https://www.swiftbharat.org/2026/stickers/maharashtrian-thali.png) │ ""                                                                                                                                                                                                │ nil                                                       │
      │ "Chai break"                         │ URL(https://www.swiftbharat.org/2026/stickers/chai-snacks.png)         │ ""                                                                                                                                                                                                │ nil                                                       │
      │ "Post-conference mixer + BEST buses" │ nil                                                                    │ "The talks wrap. Mumbai takes over! Mingling, vada pav + iconic red BEST buses. Plans still cooking — 5 PM to 8:30 PM latest. Details soon!"                                                      │ nil                                                       │
      │ "Chai break"                         │ URL(https://www.swiftbharat.org/2026/stickers/chai-snacks.png)         │ ""                                                                                                                                                                                                │ nil                                                       │
      │ "Lunch"                              │ URL(https://www.swiftbharat.org/2026/stickers/maharashtrian-thali.png) │ ""                                                                                                                                                                                                │ nil                                                       │
      │ "Chai break"                         │ URL(https://www.swiftbharat.org/2026/stickers/chai-snacks.png)         │ ""                                                                                                                                                                                                │ nil                                                       │
      │ "Indie app fair + dinner"            │ nil                                                                    │ "Small apps. Big appetites. Show off your app, meet fellow makers + swap stories over dinner. Only for conference attendees with apps; no outside guests. Tentative: 5 PM–8:30 PM. Details soon!" │ "Conference attendees with apps only; no outside guests." │
      └──────────────────────────────────────┴────────────────────────────────────────────────────────────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴───────────────────────────────────────────────────────────┘
      """
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func feedItems() async throws {
    _ = try await service().fetchSwiftBharat(year: 2026)

    assertQuery(
      ConferencesFeedItem.all
        .order(by: \.title)
        .select { ($0.title, $0.feedID, $0.url, $0.tags, $0.dateModified) }
    ) {
      """
      ┌─────────────────────────────────────┬────────────────────────────────────────────────────┬────────────────────────────────────────────┬─────────────────────────────┬────────────────────────────────┐
      │ "Day 1 schedule — 19 November 2026" │ "https://www.swiftbharat.org/#schedule-2026-11-19" │ URL(https://www.swiftbharat.org/#schedule) │ [                           │ Date(2026-09-15T11:44:25.164Z) │
      │                                     │                                                    │                                            │   [0]: "schedule",          │                                │
      │                                     │                                                    │                                            │   [1]: "day 1",             │                                │
      │                                     │                                                    │                                            │   [2]: "Swift Bharat 2026"  │                                │
      │                                     │                                                    │                                            │ ]                           │                                │
      ├─────────────────────────────────────┼────────────────────────────────────────────────────┼────────────────────────────────────────────┼─────────────────────────────┼────────────────────────────────┤
      │ "Day 2 schedule — 20 November 2026" │ "https://www.swiftbharat.org/#schedule-2026-11-20" │ URL(https://www.swiftbharat.org/#schedule) │ [                           │ Date(2026-09-15T11:14:21.042Z) │
      │                                     │                                                    │                                            │   [0]: "schedule",          │                                │
      │                                     │                                                    │                                            │   [1]: "day 2",             │                                │
      │                                     │                                                    │                                            │   [2]: "Swift Bharat 2026"  │                                │
      │                                     │                                                    │                                            │ ]                           │                                │
      ├─────────────────────────────────────┼────────────────────────────────────────────────────┼────────────────────────────────────────────┼─────────────────────────────┼────────────────────────────────┤
      │ "Swift Bharat 2026 event guide"     │ "https://www.swiftbharat.org/#event-guide"         │ URL(https://www.swiftbharat.org/)          │ [                           │ Date(2026-09-30T11:41:14.092Z) │
      │                                     │                                                    │                                            │   [0]: "Swift",             │                                │
      │                                     │                                                    │                                            │   [1]: "iOS",               │                                │
      │                                     │                                                    │                                            │   [2]: "Apple development", │                                │
      │                                     │                                                    │                                            │   [3]: "conference",        │                                │
      │                                     │                                                    │                                            │   [4]: "Mumbai",            │                                │
      │                                     │                                                    │                                            │   [5]: "speakers"           │                                │
      │                                     │                                                    │                                            │ ]                           │                                │
      └─────────────────────────────────────┴────────────────────────────────────────────────────┴────────────────────────────────────────────┴─────────────────────────────┴────────────────────────────────┘
      """
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func sessionsPerScheduleDay() async throws {
    _ = try await service().fetchSwiftBharat(year: 2026)

    assertQuery(
      ConferencesScheduleDay.all
        .order(by: \.date)
        .group(by: \.id)
        .leftJoin(ConferencesSession.all) { $0.id.eq($1.scheduleDayID) }
        .select { ($0.date, $1.id.count()) }
    ) {
      """
      ┌────────────────────────────────┬────┐
      │ Date(2026-11-19T00:00:00.000Z) │ 14 │
      │ Date(2026-11-20T00:00:00.000Z) │ 14 │
      └────────────────────────────────┴────┘
      """
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func refetchingReplacesExistingEvent() async throws {
    let result1 = try await service().fetchSwiftBharat(year: 2026)
    #expect(result1.isFirstSync == true)
    #expect(result1.hasChanges == true)
    #expect(result1.tickets.added.count == 2)
    #expect(result1.speakers.added.count == 9)
    #expect(result1.scheduleDays.added.count == 2)
    #expect(result1.sessions.added.count == 28)
    #expect(result1.feedItems.added.count == 3)

    let result2 = try await service().fetchSwiftBharat(year: 2026)
    #expect(result2.isFirstSync == false)
    #expect(result2.hasChanges == false)
    #expect(result2.tickets.added.isEmpty)
    #expect(result2.speakers.added.isEmpty)
    #expect(result2.scheduleDays.added.isEmpty)
    #expect(result2.sessions.added.isEmpty)
    #expect(result2.feedItems.added.isEmpty)

    assertRowCounts()
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func cascadingDeleteRemovesChildRows() async throws {
    _ = try await service().fetchSwiftBharat(year: 2026)

    try await database().write { db in
      try ConferencesEvent.delete().execute(db)
    }

    assertEmptyRowCounts()
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  @Test
  func syncDetectsModifications() async throws {
    let result1 = try await service().fetchSwiftBharat(year: 2026)
    #expect(result1.isFirstSync)
    #expect(result1.tickets.added.count == 2)

    let fileURL = Bundle.module.url(forResource: "swiftbharat-2026", withExtension: "json")!
    var jsonString = try String(contentsOf: fileURL, encoding: .utf8)
    jsonString = jsonString.replacingOccurrences(of: "\"price\": 4999", with: "\"price\": 4499")
    let modifiedData = Data(jsonString.utf8)

    let modifiedService = ConferencesService.live(fetchData: { _ in modifiedData })
    let result2 = try await modifiedService.fetchSwiftBharat(year: 2026)
    #expect(!result2.isFirstSync)
    #expect(result2.hasChanges)
    #expect(result2.tickets.modified.count == 1)
    #expect(result2.tickets.modified[0].old.price == 4999)
    #expect(result2.tickets.modified[0].new.price == 4499)
    #expect(result2.tickets.added.isEmpty)
    #expect(result2.tickets.removed.isEmpty)
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  private func assertRowCounts() {
    assertQuery(ConferencesEvent.count()) {
      """
      ┌───┐
      │ 1 │
      └───┘
      """
    }
    assertQuery(ConferencesTicket.count()) {
      """
      ┌───┐
      │ 2 │
      └───┘
      """
    }
    assertQuery(ConferencesSpeaker.count()) {
      """
      ┌───┐
      │ 9 │
      └───┘
      """
    }
    assertQuery(ConferencesScheduleDay.count()) {
      """
      ┌───┐
      │ 2 │
      └───┘
      """
    }
    assertQuery(ConferencesSession.count()) {
      """
      ┌────┐
      │ 28 │
      └────┘
      """
    }
    assertQuery(ConferencesFeedItem.count()) {
      """
      ┌───┐
      │ 3 │
      └───┘
      """
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  private func assertEmptyRowCounts() {
    assertQuery(ConferencesEvent.count()) {
      """
      ┌───┐
      │ 0 │
      └───┘
      """
    }
    assertQuery(ConferencesTicket.count()) {
      """
      ┌───┐
      │ 0 │
      └───┘
      """
    }
    assertQuery(ConferencesSpeaker.count()) {
      """
      ┌───┐
      │ 0 │
      └───┘
      """
    }
    assertQuery(ConferencesScheduleDay.count()) {
      """
      ┌───┐
      │ 0 │
      └───┘
      """
    }
    assertQuery(ConferencesSession.count()) {
      """
      ┌───┐
      │ 0 │
      └───┘
      """
    }
    assertQuery(ConferencesFeedItem.count()) {
      """
      ┌───┐
      │ 0 │
      └───┘
      """
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  private func service() -> ConferencesService {
    @Dependency(\.conferencesService) var service
    return service
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  private func database() -> any DatabaseWriter {
    @Dependency(\.defaultDatabase) var database
    return database
  }
}

private func conferencesTestDatabase() throws -> any DatabaseWriter {
  var migrator = DatabaseMigrator()
  try ConferencesEvent.migrate(using: &migrator)
  try ConferencesTicket.migrate(using: &migrator)
  try ConferencesSpeaker.migrate(using: &migrator)
  try ConferencesScheduleDay.migrate(using: &migrator)
  try ConferencesSession.migrate(using: &migrator)
  try ConferencesFeedItem.migrate(using: &migrator)

  let database = try DatabaseQueue()
  try migrator.migrate(database)
  return database
}
