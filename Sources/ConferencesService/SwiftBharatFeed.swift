import ConferenceModels
import Foundation

let conferencesISO8601WithFractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
let conferencesISO8601 = Date.ISO8601FormatStyle(includingFractionalSeconds: false)
let conferencesDay = Date.ISO8601FormatStyle(dateSeparator: .dash, timeSeparator: .colon, timeZoneSeparator: .omitted).year().month().day()

extension Date {
    var sqliteNormalized: Date {
        Date(timeIntervalSinceReferenceDate: (timeIntervalSinceReferenceDate * 1000).rounded(.down) / 1000)
    }
}

extension String {
    var conferencesDate: Date? {
        if let date = try? Date(self, strategy: conferencesISO8601WithFractionalSeconds) {
            return date.sqliteNormalized
        }
        if let date = try? Date(self, strategy: conferencesISO8601) {
            return date.sqliteNormalized
        }
        return (try? Date(self, strategy: conferencesDay)).map(\.sqliteNormalized)
    }
}

extension JSONDecoder {
    static var conferencesSwiftBharat: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = string.conferencesDate
            else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unrecognized Swift Bharat date format: \(string)"
                )
            }
            return date
        }
        return decoder
    }
}

struct SwiftBharatFeed: Decodable {
    var version = ""
    var title = ""
    var homePageURL: URL?
    var feedURL: URL?
    var summary: String?
    var language: String?
    var iconURL: URL?
    var authors: [Author]?
    var items: [Item] = []
    var swiftBharat: SwiftBharatPayload?

    enum CodingKeys: String, CodingKey {
        case version
        case title
        case summary = "description"
        case language
        case authors
        case items
        case homePageURL = "home_page_url"
        case feedURL = "feed_url"
        case iconURL = "icon"
        case swiftBharat = "_swift_bharat"
    }

    struct Author: Decodable {
        var name: String?
        var url: URL?

        enum CodingKeys: String, CodingKey {
            case name
            case url
        }
    }

    struct Item: Decodable {
        var id: String?
        var url: URL?
        var title: String?
        var summary: String?
        var contentText: String?
        var contentHTML: String?
        var imageURL: URL?
        var tags: [String]?
        var dateModified: Date?

        enum CodingKeys: String, CodingKey {
            case id
            case url
            case title
            case summary
            case contentText = "content_text"
            case contentHTML = "content_html"
            case imageURL = "image"
            case tags
            case dateModified = "date_modified"
        }
    }

    struct SwiftBharatPayload: Decodable {
        var event: Event?

        enum CodingKeys: String, CodingKey {
            case event
        }
    }

    struct Event: Decodable {
        var startDate: Date?
        var endDate: Date?
        var timezone: String?
        var venue: Venue?
        var tickets: [Ticket]?
        var speakers: [Speaker]?
        var schedule: [ScheduleDay]?

        enum CodingKeys: String, CodingKey {
            case timezone
            case venue
            case tickets
            case speakers
            case schedule
            case startDate = "start_date"
            case endDate = "end_date"
        }

        struct Venue: Decodable {
            var name: String?
            var city: String?
            var region: String?
            var country: String?

            enum CodingKeys: String, CodingKey {
                case name
                case city
                case region
                case country
            }
        }

        struct Ticket: Decodable {
            var name: String?
            var price: Int?
            var currency: String?
            var url: URL?

            enum CodingKeys: String, CodingKey {
                case name
                case price
                case currency
                case url
            }
        }

        struct Speaker: Decodable {
            var name: String?
            var role: String?
            var website: URL?
            var x: URL?
            var linkedin: URL?
            var imageURL: URL?
            var sticker: Sticker?

            enum CodingKeys: String, CodingKey {
                case name
                case role
                case website
                case x
                case linkedin
                case imageURL = "image"
                case sticker
            }

            struct Sticker: Decodable {
                var imageURL: URL?
                var title: String?
                var summary: String?
                var alt: String?

                enum CodingKeys: String, CodingKey {
                    case title
                    case alt
                    case imageURL = "image"
                    case summary = "description"
                }
            }
        }

        struct ScheduleDay: Decodable {
            var date: Date?
            var status: String?
            var sessions: [Session]?

            enum CodingKeys: String, CodingKey {
                case status
                case date
                case sessions
            }
        }

        struct Session: Decodable {
            var title: String?
            var startTime: Date?
            var endTime: Date?
            var durationMinutes: Int?
            var imageURL: URL?
            var endTimeIsLatest: Bool?
            var status: String?
            var summary: String?
            var audience: String?

            enum CodingKeys: String, CodingKey {
                case title
                case status
                case summary = "description"
                case audience
                case startTime = "start_time"
                case endTime = "end_time"
                case durationMinutes = "duration_minutes"
                case imageURL = "image"
                case endTimeIsLatest = "end_time_is_latest"
            }
        }
    }
}

// MARK: - CoreModels Conversions

extension SwiftBharatFeed {
    func conferencesEvent(payload: SwiftBharatFeed.Event) -> ConferencesEvent {
        let eventID: UUID
        if let feedURL {
            eventID = UUID.deterministic(components: "event", feedURL.absoluteString)
        } else {
            eventID = UUID.deterministic(components: "event", title)
        }
        return ConferencesEvent(
            id: eventID,
            name: title,
            summary: summary ?? "",
            language: language ?? "",
            version: version,
            homePageURL: homePageURL,
            feedURL: feedURL,
            iconURL: iconURL,
            startDate: payload.startDate ?? .now,
            endDate: payload.endDate ?? .now,
            timezone: payload.timezone ?? "",
            venue: payload.venue?.conferencesVenue ?? .init(name: "", city: "", region: "", country: ""),
            authors: (authors ?? []).map(\.conferencesAuthor)
        )
    }
}

extension SwiftBharatFeed.Author {
    var conferencesAuthor: ConferencesAuthor {
        .init(name: name ?? "", url: url)
    }
}

extension SwiftBharatFeed.Event.Venue {
    var conferencesVenue: ConferencesVenue {
        .init(
            name: name ?? "",
            city: city ?? "",
            region: region ?? "",
            country: country ?? ""
        )
    }
}

extension SwiftBharatFeed.Event.Ticket {
    func conferencesTicket(eventID: ConferencesEvent.ID) -> ConferencesTicket {
        let ticketName = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let ticketID = UUID.deterministic(components: "ticket", eventID.uuidString, ticketName.lowercased())
        return ConferencesTicket(
            id: ticketID,
            eventID: eventID,
            name: ticketName,
            price: price ?? 0,
            currency: currency ?? "",
            url: url
        )
    }
}

extension SwiftBharatFeed.Event.Speaker.Sticker {
    var conferencesSticker: ConferencesSticker {
        .init(
            imageURL: imageURL,
            title: title ?? "",
            summary: summary ?? "",
            alt: alt ?? ""
        )
    }
}

extension SwiftBharatFeed.Event.Speaker {
    var primaryHandleOrSlug: String {
        if let x = x?.absoluteString.lowercased(), !x.isEmpty {
            return x
        }
        if let linkedin = linkedin?.absoluteString.lowercased(), !linkedin.isEmpty {
            return linkedin
        }
        if let website = website?.absoluteString.lowercased(), !website.isEmpty {
            return website
        }
        if let imageURL {
            let slug = imageURL.deletingPathExtension().lastPathComponent.lowercased()
            if !slug.isEmpty {
                return slug
            }
        }
        return ""
    }

    func conferencesSpeaker(eventID: ConferencesEvent.ID) -> ConferencesSpeaker {
        let speakerName = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let speakerID = UUID.deterministic(
            components: "speaker",
            eventID.uuidString,
            speakerName.lowercased(),
            primaryHandleOrSlug
        )
        return ConferencesSpeaker(
            id: speakerID,
            eventID: eventID,
            name: speakerName,
            role: role ?? "",
            website: website,
            x: x,
            linkedin: linkedin,
            imageURL: imageURL,
            sticker: sticker?.conferencesSticker
        )
    }
}

extension SwiftBharatFeed.Event.ScheduleDay {
    func conferencesScheduleDay(eventID: ConferencesEvent.ID) -> ConferencesScheduleDay {
        let dayDate = date ?? .now
        let dayKey = String(Int(dayDate.timeIntervalSince1970))
        let dayID = UUID.deterministic(components: "day", eventID.uuidString, dayKey)
        return ConferencesScheduleDay(
            id: dayID,
            eventID: eventID,
            date: dayDate,
            status: status.flatMap(ConferencesScheduleStatus.init(rawValue:))
        )
    }
}

extension SwiftBharatFeed.Event.Session {
    func conferencesSession(
        eventID: ConferencesEvent.ID,
        scheduleDayID: ConferencesScheduleDay.ID
    ) -> ConferencesSession {
        let sessionStartTime = startTime ?? .now
        let sessionKey = String(Int(sessionStartTime.timeIntervalSince1970))
        let sessionID = UUID.deterministic(components: "session", scheduleDayID.uuidString, sessionKey)
        return ConferencesSession(
            id: sessionID,
            eventID: eventID,
            scheduleDayID: scheduleDayID,
            title: title ?? "",
            startTime: sessionStartTime,
            endTime: endTime ?? .now,
            durationMinutes: durationMinutes ?? 0,
            imageURL: imageURL,
            endTimeIsLatest: endTimeIsLatest ?? false,
            status: status.flatMap(ConferencesSessionStatus.init(rawValue:)),
            summary: summary ?? "",
            audience: audience
        )
    }
}

extension SwiftBharatFeed.Item {
    func conferencesFeedItem(eventID: ConferencesEvent.ID) -> ConferencesFeedItem {
        let feedKey = id ?? url?.absoluteString ?? (title ?? "")
        let itemID = UUID.deterministic(components: "feedItem", eventID.uuidString, feedKey)
        return ConferencesFeedItem(
            id: itemID,
            eventID: eventID,
            feedID: id ?? "",
            url: url,
            title: title ?? "",
            summary: summary ?? "",
            contentText: contentText ?? "",
            contentHTML: contentHTML ?? "",
            imageURL: imageURL,
            tags: tags ?? [],
            dateModified: dateModified ?? .now
        )
    }
}

