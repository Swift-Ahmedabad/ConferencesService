# ConferencesService

A Swift package for fetching, decoding, and storing conference data from JSON
Feeds. It currently supports the [Swift Bharat](https://swiftbharat.org) feed
and persists events, tickets, speakers, schedule days, sessions, and feed items
into a SQLite database via [SQLiteData](https://github.com/pointfreeco/sqlite-data).

## Overview

The package is split into two libraries:

| Product | Description |
| --- | --- |
| `ConferenceModels` | `@Table` models for events, tickets, speakers, schedule days, sessions, and feed items, plus deterministic UUID generation. |
| `ConferencesService` | A [`@DependencyClient`](https://github.com/pointfreeco/swift-dependencies) that migrates the schema and syncs conference feeds. |

## Requirements

- Swift 6.4+
- iOS 18 / macOS 15 / tvOS 18 / watchOS 11

## Installation

Add the package to your `Package.swift`:

```swift
.package(url: "https://github.com/ratnesh-jain/ConferencesService", branch: "main")
```

Then add the products to your target's dependencies:

```swift
.target(
    name: "MyFeature",
    dependencies: [
        .product(name: "ConferencesService", package: "ConferencesService"),
        .product(name: "ConferenceModels", package: "ConferencesService"),
    ]
)
```

## Usage

### Register the dependency

`ConferencesService` is a dependency client. Register it at app launch:

```swift
import ConferencesService
import Dependencies

try withDependencies {
    $0.conferencesService = .liveValue
} operation: {
    // ...
}
```

### Migrate the database

Apply the models' migrations to your `defaultDatabase` migrator:

```swift
import ConferencesService
import SQLiteData

var migrator = DatabaseMigrator()
@Dependency(\.conferencesService) var conferencesService
try conferenceService.migrate(&migrator)
```

### Sync a feed

```swift
@Dependency(\.conferencesService) var conferencesService

let result = try await conferencesService.fetchSwiftBharat(year: 2026)
if result.isFirstSync {
    // First time this event has been synced.
}
```

The sync upserts the event and reconciles its tickets, speakers, schedule days,
sessions, and feed items, removing any records that no longer appear in the
feed. It returns a `ConferencesSyncResult` describing the changes.

### Testing

Access the dependency through `@Dependency` and override it with the
`.dependencies` test trait, supplying feed data from a local resource or stub:

```swift
import DependenciesTestSupport
import Testing
@testable import ConferencesService

@Suite(
    .dependencies {
        $0.conferencesService = .live { url in
            try Data(contentsOf: localFeedURL)
        }
    }
)
struct ConferencesServiceTests {
    @Dependency(\.conferencesService) var service

    @Test
    func fetchSwiftBharat() async throws {
        let result = try await service.fetchSwiftBharat(year: 2026)
        #expect(result.hasChanges)
    }
}
```

The `.dependencies` trait requires linking the `DependenciesTestSupport` product
to your test target.

## License

This package is available under the MIT license. See [LICENSE](LICENSE) for details.
