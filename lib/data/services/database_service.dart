import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/song.dart';
import '../../domain/repositories/playlist_repository.dart';

/// SQLite-backed implementation of [PlaylistRepository].
class DatabaseService implements PlaylistRepository {
  static const String _dbName = 'unitune.db';
  static const int _dbVersion = 2;
  static const String _table = 'playlist';
  static const String _historyTable = 'recent_history';

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            track_id       TEXT    NOT NULL,
            track_name     TEXT    NOT NULL,
            artist_name    TEXT    NOT NULL,
            album_name     TEXT    NOT NULL,
            artwork_url    TEXT,
            preview_url    TEXT,
            genre          TEXT,
            is_explicit    INTEGER NOT NULL DEFAULT 0,
            suggest_to_radio INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await _createHistoryTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createHistoryTable(db);
        }
      },
    );
  }

  Future<void> _createHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_historyTable (
        track_id    TEXT    PRIMARY KEY,
        track_name  TEXT    NOT NULL,
        artist_name TEXT    NOT NULL,
        album_name  TEXT    NOT NULL,
        artwork_url TEXT,
        preview_url TEXT,
        genre       TEXT,
        is_explicit INTEGER NOT NULL DEFAULT 0,
        accessed_at INTEGER NOT NULL
      )
    ''');
  }

  // ── Playlist ──────────────────────────────────────────────────────────────

  @override
  Future<List<Song>> getAllSongs() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'id DESC');
    return rows.map(Song.fromMap).toList();
  }

  @override
  Future<int> insertSong(Song song) async {
    final db = await _database;
    return db.insert(
      _table,
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteSong(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> updateSuggestToRadio(int id, {required bool suggest}) async {
    final db = await _database;
    await db.update(
      _table,
      {'suggest_to_radio': suggest ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Recent History ────────────────────────────────────────────────────────

  /// Inserts or replaces [song] in history, updating its timestamp.
  Future<void> upsertRecentSong(Song song) async {
    final db = await _database;
    await db.insert(
      _historyTable,
      {
        'track_id': song.trackId,
        'track_name': song.trackName,
        'artist_name': song.artistName,
        'album_name': song.albumName,
        'artwork_url': song.artworkUrl,
        'preview_url': song.previewUrl,
        'genre': song.genre,
        'is_explicit': song.isExplicit ? 1 : 0,
        'accessed_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns the most recently accessed songs, newest first.
  Future<List<Song>> getRecentSongs({int limit = 30}) async {
    final db = await _database;
    final rows = await db.query(
      _historyTable,
      orderBy: 'accessed_at DESC',
      limit: limit,
    );
    return rows.map((row) {
      final map = Map<String, dynamic>.from(row)..remove('accessed_at');
      return Song.fromMap(map);
    }).toList();
  }

  Future<void> close() async {
    final db = await _database;
    await db.close();
    _db = null;
  }
}
