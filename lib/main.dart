import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/playlist_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/now_playing_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/playlist_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(const UniTuneApp());
}

class UniTuneApp extends StatelessWidget {
  const UniTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => NowPlayingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'UniTune',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.mode,
            initialRoute: '/',
            routes: {
              '/': (_) => const HomeScreen(),
              '/search': (_) => const SearchScreen(),
              '/playlist': (_) => const PlaylistScreen(),
            },
          );
        },
      ),
    );
  }
}
