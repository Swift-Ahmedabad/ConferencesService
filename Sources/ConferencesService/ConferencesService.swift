//
//  File.swift
//  ConferencesService
//
//  Created by Ratnesh Jain on 01/10/26.
//

import ConferenceModels
import Dependencies
import DependenciesMacros
import Foundation
import SQLiteData
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct ConferencesServiceError: Error {
    public var invalidFeedURL: String

    public init(invalidFeedURL: String) {
        self.invalidFeedURL = invalidFeedURL
    }
}

@DependencyClient
public struct ConferencesService: Sendable {
    public var migrate: @Sendable (_ migrator: inout DatabaseMigrator) throws -> Void
    public var fetchSwiftBharat: @Sendable (_ year: Int) async throws -> ConferencesSyncResult
}

extension ConferencesService: DependencyKey {
    public static var liveValue: ConferencesService {
        .live()
    }

    public static func live(
        fetchData: @Sendable @escaping (_ url: URL) async throws -> Data = { url in
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
    ) -> ConferencesService {
        ConferencesService { migrator in
            try ConferencesEvent.migrate(using: &migrator)
            try ConferencesFeedItem.migrate(using: &migrator)
            try ConferencesScheduleDay.migrate(using: &migrator)
            try ConferencesSession.migrate(using: &migrator)
            try ConferencesSpeaker.migrate(using: &migrator)
            try ConferencesTicket.migrate(using: &migrator)
        } fetchSwiftBharat: { year in
            @Dependency(\.defaultDatabase) var database

            let urlString = "https://swiftbharat.org/\(year)/feed.json"
            guard let url = URL(string: urlString) else {
                throw ConferencesServiceError(invalidFeedURL: urlString)
            }
            let data = try await fetchData(url)
            let feed = try JSONDecoder.conferencesSwiftBharat.decode(SwiftBharatFeed.self, from: data)
            guard let payload = feed.swiftBharat?.event else {
                return ConferencesSyncResult()
            }

            let event = feed.conferencesEvent(payload: payload)
            let tickets = (payload.tickets ?? []).map { $0.conferencesTicket(eventID: event.id) }
            let speakers = (payload.speakers ?? []).map { $0.conferencesSpeaker(eventID: event.id) }
            let scheduleDays = (payload.schedule ?? []).map { $0.conferencesScheduleDay(eventID: event.id) }
            let sessions = zip(payload.schedule ?? [], scheduleDays)
                .flatMap { day, scheduleDay in
                    (day.sessions ?? []).map { $0.conferencesSession(eventID: event.id, scheduleDayID: scheduleDay.id) }
                }
            let feedItems = feed.items.map { $0.conferencesFeedItem(eventID: event.id) }

            return try await database.write { db in
                let existingEvent = try ConferencesEvent.where { $0.id.eq(event.id) }.fetchOne(db)
                let isFirstSync = (existingEvent == nil)
                var eventDiff: (old: ConferencesEvent, new: ConferencesEvent)? = nil
                if let existingEvent, existingEvent != event {
                    eventDiff = (old: existingEvent, new: event)
                }
                try ConferencesEvent.upsert { [event] }.execute(db)

                // Reconcile tickets
                let existingTickets = try ConferencesTicket.where { $0.eventID.eq(event.id) }.fetchAll(db)
                let (ticketsDiff, removedTicketIDs) = diffRecords(existing: existingTickets, incoming: tickets)
                if !removedTicketIDs.isEmpty {
                    try ConferencesTicket.where { $0.id.in(removedTicketIDs) }.delete().execute(db)
                }
                if !tickets.isEmpty {
                    try ConferencesTicket.upsert { tickets }.execute(db)
                }

                // Reconcile speakers
                let existingSpeakers = try ConferencesSpeaker.where { $0.eventID.eq(event.id) }.fetchAll(db)
                let (speakersDiff, removedSpeakerIDs) = diffRecords(existing: existingSpeakers, incoming: speakers)
                if !removedSpeakerIDs.isEmpty {
                    try ConferencesSpeaker.where { $0.id.in(removedSpeakerIDs) }.delete().execute(db)
                }
                if !speakers.isEmpty {
                    try ConferencesSpeaker.upsert { speakers }.execute(db)
                }

                // Reconcile schedule days
                let existingDays = try ConferencesScheduleDay.where { $0.eventID.eq(event.id) }.fetchAll(db)
                let (daysDiff, removedDayIDs) = diffRecords(existing: existingDays, incoming: scheduleDays)
                if !removedDayIDs.isEmpty {
                    try ConferencesScheduleDay.where { $0.id.in(removedDayIDs) }.delete().execute(db)
                }
                if !scheduleDays.isEmpty {
                    try ConferencesScheduleDay.upsert { scheduleDays }.execute(db)
                }

                // Reconcile sessions
                let existingSessions = try ConferencesSession.where { $0.eventID.eq(event.id) }.fetchAll(db)
                let (sessionsDiff, removedSessionIDs) = diffRecords(existing: existingSessions, incoming: sessions)
                if !removedSessionIDs.isEmpty {
                    try ConferencesSession.where { $0.id.in(removedSessionIDs) }.delete().execute(db)
                }
                if !sessions.isEmpty {
                    try ConferencesSession.upsert { sessions }.execute(db)
                }

                // Reconcile feed items
                let existingFeedItems = try ConferencesFeedItem.where { $0.eventID.eq(event.id) }.fetchAll(db)
                let (feedItemsDiff, removedFeedItemIDs) = diffRecords(existing: existingFeedItems, incoming: feedItems)
                if !removedFeedItemIDs.isEmpty {
                    try ConferencesFeedItem.where { $0.id.in(removedFeedItemIDs) }.delete().execute(db)
                }
                if !feedItems.isEmpty {
                    try ConferencesFeedItem.upsert { feedItems }.execute(db)
                }

                return ConferencesSyncResult(
                    event: eventDiff,
                    isFirstSync: isFirstSync,
                    tickets: ticketsDiff,
                    speakers: speakersDiff,
                    scheduleDays: daysDiff,
                    sessions: sessionsDiff,
                    feedItems: feedItemsDiff
                )
            }
        }
    }
}

private func diffRecords<T: Table & Equatable & Identifiable>(
    existing: [T],
    incoming: [T]
) -> (changeSet: ChangeSet<T>, removedIDs: [T.ID]) where T.ID: Hashable {
    let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
    let incomingByID = Dictionary(uniqueKeysWithValues: incoming.map { ($0.id, $0) })

    var added: [T] = []
    var modified: [(old: T, new: T)] = []
    var removed: [T] = []
    var removedIDs: [T.ID] = []

    for item in incoming {
        if let old = existingByID[item.id] {
            if old != item {
                modified.append((old: old, new: item))
            }
        } else {
            added.append(item)
        }
    }

    for old in existing {
        if incomingByID[old.id] == nil {
            removed.append(old)
            removedIDs.append(old.id)
        }
    }

    return (ChangeSet(added: added, modified: modified, removed: removed), removedIDs)
}

extension DependencyValues {
    public var conferencesService: ConferencesService {
        get { self[ConferencesService.self] }
        set { self[ConferencesService.self] = newValue }
    }
}
