# UniTune

A music-discovery Flutter app built for a university community radio, powered by the **iTunes Search API**.

---

## Architecture

UniTune follows a **Layered Architecture** with three main layers:

```
lib/
├── data/
│   └── services/
│       ├── itunes_service.dart       # iTunes Search API (http)
│       ├── database_service.dart     # SQLite playlist storage (sqflite)
│       └── preferences_service.dart  # Search settings (SharedPreferences)
├── domain/
│   ├── entities/
│   │   ├── song.dart                 # Song entity + iTunes/DB mapping
│   │   ├── artist.dart               # Artist entity
│   │   ├── album.dart                # Album entity + iTunes mapping
│   │   └── playlist.dart             # Playlist entity (name + song list)
│   └── repositories/
│       └── playlist_repository.dart  # Playlist contract
└── presentation/
    ├── providers/
    │   ├── search_provider.dart       # Search state (ChangeNotifier)
    │   ├── playlist_provider.dart     # Playlist CRUD state (ChangeNotifier)
    │   ├── now_playing_provider.dart  # Global audio playback state
    │   ├── recommendation_provider.dart # Album recommendations state
    │   └── theme_provider.dart        # Light/dark theme toggle
    ├── screens/
    │   ├── home_screen.dart           # Home with recommendations + playlist preview
    │   ├── search_screen.dart         # Search UI
    │   ├── details_screen.dart        # Track detail + 30s audio player
    │   ├── album_details_screen.dart  # Album detail + track listing + preview
    │   ├── playlist_screen.dart       # Local playlist management
    │   └── playlist_details_screen.dart # Individual playlist view
    ├── widgets/
    │   ├── mini_player_bar.dart       # Persistent now-playing bar
    │   ├── app_bottom_nav.dart        # Bottom navigation bar
    │   └── playlist_selection_dialog.dart # Dialog to pick playlist when saving a track
    └── theme/
        └── app_theme.dart             # Material 3 theme + header gradients
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
| Playlist IDs | `uuid` |

## Features

### Home Screen
- Persistent top bar with the app name
- Inline search field that navigates to the Search screen
- **"Recommended for Today"** — horizontal album carousel driven by the user's saved songs
- **"Top Playlists"** — preview of the first 6 saved tracks, tapping navigates to the Playlist screen
- Bottom navigation bar (Home / Search / Library)
- Floating action button as a shortcut to search
- **Mini Player Bar** visible above the bottom nav whenever a track is playing

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
- Add track to a local playlist via a selection dialog

### Album Details Screen
- Collapsible parallax header with album art and gradient background
- Metadata chips: genre, release date, track count, price
- Complete track listing fetched from the iTunes API
- Tap any track to toggle its 30-second audio preview, with a seek slider shown for the active track
- Light/dark theme toggle button in the app bar

### Playlist Screen
- All locally-saved playlists (SQLite)
- **"Suggest to radio"** checkbox per track (persisted)
- Delete individual tracks
- Tap any playlist to open its detail view

### Playlist Details Screen
- Collapsible parallax header with playlist art and gradient background
- Playlist name and track count
- Full track listing with artwork thumbnails
- Tap any track to open its Details screen
- Light/dark theme toggle button in the app bar

### Mini Player Bar
- Appears above the bottom navigation bar whenever a track is playing
- Shows album art thumbnail, track name, and artist name
- Play / pause button
- Thin progress bar at the bottom of the bar (tap to seek)

### Theme
- Light and dark mode support toggled from the Album Details and Playlist Details screens

## Installation

**Prerequisites:** Flutter SDK 3.0+ and an emulator or connected device.

```bash
# 1. Clone the repository
git clone https://github.com/marcusviniciusend/UniTune.git
cd UniTune

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

## Running Tests

```bash
flutter test
```
