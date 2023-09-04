import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('My App');
    setWindowMinSize(const Size(400, 600));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: SafeArea(
          child: constraints.maxWidth < 450
              ? Column(
                  children: [
                    Expanded(
                        child: MainArea(
                      selectedIndex: selectedIndex ?? 0,
                    )),
                    BottomNavigationBar(
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home_filled), label: 'Home'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.favorite), label: 'Likes'),
                      ],
                      currentIndex: selectedIndex,
                      onTap: (index){
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    NavigationRail(
                      destinations: const [
                        NavigationRailDestination(
                            icon: Icon(Icons.home_filled), label: Text('Home')),
                        NavigationRailDestination(
                            icon: Icon(Icons.favorite), label: Text('Likes')),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (int index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      extended: constraints.maxWidth > 600,
                      useIndicator: true,
                    ),
                    Expanded(
                      child: MainArea(selectedIndex: selectedIndex),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

class MainArea extends StatelessWidget {
  const MainArea({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: selectedIndex == 0 ? const GeneratorPage() : const FavoritePage(),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    IconData icon = appState.favorites.contains(appState.current)
        ? Icons.favorite
        : Icons.favorite_border_outlined;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: appState.current),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                label: const Text('Like'),
                icon: Icon(icon),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium?.copyWith(
      color: Theme.of(context).colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

//create a favorite page
class FavoritePage extends StatelessWidget {
  const FavoritePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      return const Center(child: Text('No favorites yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: appState.favorites.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.favorite),
          title: Text(appState.favorites[index].asLowerCase),
        );
      },
    );
  }
}
