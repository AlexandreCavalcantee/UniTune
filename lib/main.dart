import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/playlist_provider.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/playlist_screen.dart';

void main() {
  runApp(const UniTuneApp());
}

class UniTuneApp extends StatelessWidget {
  const UniTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
      ],
      child: MaterialApp(
        title: 'UniTune',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const SearchScreen(),
          '/playlist': (_) => const PlaylistScreen(),
        },
      ),
    );
  }
}
