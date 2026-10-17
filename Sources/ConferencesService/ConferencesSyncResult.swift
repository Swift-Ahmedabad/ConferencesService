//
//  ConferencesSyncResult.swift
//  ConferencesService
//

import ConferenceModels
import Foundation

public struct ChangeSet<T: Equatable & Sendable>: Equatable, Sendable {
    public var added: [T] = []
    public var modified: [(old: T, new: T)] = []
    public var removed: [T] = []

    public init(
        added: [T] = [],
        modified: [(old: T, new: T)] = [],
        removed: [T] = []
    ) {
        self.added = added
        self.modified = modified
        self.removed = removed
    }

    public var hasChanges: Bool {
        !added.isEmpty || !modified.isEmpty || !removed.isEmpty
    }

    public static func == (lhs: ChangeSet<T>, rhs: ChangeSet<T>) -> Bool {
        guard lhs.added == rhs.added, lhs.removed == rhs.removed else { return false }
        guard lhs.modified.count == rhs.modified.count else { return false }
        for (l, r) in zip(lhs.modified, rhs.modified) {
            if l.old != r.old || l.new != r.new { return false }
        }
        return true
    }
}

public struct ConferencesSyncResult: Equatable, Sendable {
    public var event: (old: ConferencesEvent, new: ConferencesEvent)?
    public var isFirstSync: Bool = false
    public var tickets: ChangeSet<ConferencesTicket> = .init()
    public var speakers: ChangeSet<ConferencesSpeaker> = .init()
    public var scheduleDays: ChangeSet<ConferencesScheduleDay> = .init()
    public var sessions: ChangeSet<ConferencesSession> = .init()
    public var feedItems: ChangeSet<ConferencesFeedItem> = .init()

    public init(
        event: (old: ConferencesEvent, new: ConferencesEvent)? = nil,
        isFirstSync: Bool = false,
        tickets: ChangeSet<ConferencesTicket> = .init(),
        speakers: ChangeSet<ConferencesSpeaker> = .init(),
        scheduleDays: ChangeSet<ConferencesScheduleDay> = .init(),
        sessions: ChangeSet<ConferencesSession> = .init(),
        feedItems: ChangeSet<ConferencesFeedItem> = .init()
    ) {
        self.event = event
        self.isFirstSync = isFirstSync
        self.tickets = tickets
        self.speakers = speakers
        self.scheduleDays = scheduleDays
        self.sessions = sessions
        self.feedItems = feedItems
    }

    public var hasChanges: Bool {
        event != nil || tickets.hasChanges || speakers.hasChanges ||
        scheduleDays.hasChanges || sessions.hasChanges || feedItems.hasChanges
    }

    public static func == (lhs: ConferencesSyncResult, rhs: ConferencesSyncResult) -> Bool {
        if let le = lhs.event, let re = rhs.event {
            guard le.old == re.old && le.new == re.new else { return false }
        } else if (lhs.event == nil) != (rhs.event == nil) {
            return false
        }
        return lhs.isFirstSync == rhs.isFirstSync
            && lhs.tickets == rhs.tickets
            && lhs.speakers == rhs.speakers
            && lhs.scheduleDays == rhs.scheduleDays
            && lhs.sessions == rhs.sessions
            && lhs.feedItems == rhs.feedItems
    }
}
