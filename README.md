# UniTune

A music-discovery Flutter app built for a university community radio, powered by the **iTunes Search API**.

---

## Architecture

UniTune follows a **Layered Architecture** with three main layers:

```
lib/
├── data/
│   └── services/
│       ├── itunes_service.dart      # iTunes Search API (http)
│       ├── database_service.dart    # SQLite playlist storage (sqflite)
│       └── preferences_service.dart # Search settings (SharedPreferences)
├── domain/
│   ├── entities/
│   │   ├── song.dart                # Song entity + iTunes/DB mapping
│   │   └── artist.dart              # Artist entity
│   └── repositories/
│       └── playlist_repository.dart # Playlist contract
└── presentation/
    ├── providers/
    │   ├── search_provider.dart     # Search state (ChangeNotifier)
    │   └── playlist_provider.dart  # Playlist state (ChangeNotifier)
    └── screens/
        ├── search_screen.dart       # Search UI
        ├── details_screen.dart      # Track detail + 30s audio player
        └── playlist_screen.dart     # Local playlist management
```

## Tech Stack

| Concern | Package |
|---|---|
| UI | Flutter / Material 3 |
| HTTP | `http` |
| SQLite | `sqflite` + `path` |
| Preferences | `shared_preferences` |
| State Management | `provider` |
| Audio Player | `just_audio` |

## Features

### Search Screen
- Free-text search field with submit button
- **Radio buttons** to switch between *Song*, *Artist*, and *Album* search
- **Explicit switch** to filter out explicit content
- Settings are persisted via `SharedPreferences`
- Results displayed in a scrollable `ListView` of `Card` widgets

### Details Screen
- Large album art (300×300 from iTunes CDN)
- Track name, artist, album, genre, explicit badge
- **30-second audio preview** player with seek slider
- Add / remove from local playlist

### Playlist Screen
- All locally-saved tracks (SQLite)
- **"Suggest to radio"** checkbox per track (persisted)
- Delete individual tracks
- Tap any track to open its details

## Getting Started

```bash
flutter pub get
flutter run
```

## Running Tests

```bash
flutter test
```
