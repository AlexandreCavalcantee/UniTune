import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/now_playing_provider.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<NowPlayingProvider>(
      builder: (context, np, _) {
        final song = np.song;
        if (song == null) return const SizedBox.shrink();

        final dur = np.duration.inMilliseconds <= 0 ? null : np.duration;
        final pos = np.position;
        final progress = (dur == null || dur.inMilliseconds == 0)
            ? 0.0
            : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: SizedBox(
              height: 64,
              child: Material(
                color: const Color(0xFF18181B),
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black,
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: song.artworkUrl == null
                                  ? Icon(Icons.album_rounded,
                                      color:
                                          Colors.white.withValues(alpha: 0.45))
                                  : Image.network(
                                      song.artworkUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.album_rounded,
                                        color: Colors.white
                                            .withValues(alpha: 0.45),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    song.trackName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    song.artistName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.55),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (np.isLoading)
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary,
                                ),
                              )
                            else
                              IconButton(
                                tooltip: np.isPlaying ? 'Pause' : 'Play',
                                onPressed: () =>
                                    np.isPlaying ? np.pause() : np.resume(),
                                icon: Icon(
                                  np.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // progress (Spotify-like thin bar)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (d) {
                            if (dur == null) return;
                            final box =
                                context.findRenderObject() as RenderBox?;
                            if (box == null) return;
                            final local = box.globalToLocal(d.globalPosition);
                            final w = box.size.width;
                            final t = (local.dx / w).clamp(0.0, 1.0);
                            np.seek(Duration(
                                milliseconds:
                                    (dur.inMilliseconds * t).round()));
                          },
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 2,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.12),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(cs.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

