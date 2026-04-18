import '../entities/song.dart';

/// Contract for playlist persistence operations.
abstract class PlaylistRepository {
  /// Returns all saved songs in the local playlist.
  Future<List<Song>> getAllSongs();

  /// Inserts [song] into the local playlist.
  /// Returns the new row id.
  Future<int> insertSong(Song song);

  /// Removes the song identified by [id] from the local playlist.
  Future<void> deleteSong(int id);

  /// Updates the [suggestToRadio] flag for the song with the given [id].
  Future<void> updateSuggestToRadio(int id, {required bool suggest});
}
