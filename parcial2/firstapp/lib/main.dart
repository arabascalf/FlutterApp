import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
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
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = '';
  int currentIndex = 0;
  double currentResult = 0.0;
  final List<String> phrases = ['Multiplicación', 'División', 'Suma', 'Resta'];

  void getNext() {
    currentIndex = (currentIndex + 1) % phrases.length;
    notifyListeners();
  }

  double getSum(a, b) {
    double value1 = double.tryParse(a) ?? 0;
    double value2 = double.tryParse(b) ?? 0;
    print("Function: $currentIndex -> $value1, $value2");
    switch(currentIndex) {
      case 0:
        currentResult = value1 * value2;
        notifyListeners();
        return currentResult;
      case 1:
        currentResult = value1 / value2;
        notifyListeners();
        return currentResult;
      case 2:
        currentResult = value1 + value2;
        notifyListeners();
        return currentResult;
      default:
        currentResult = value1 - value2;   
        notifyListeners();
        return currentResult;
    }
  } 

  var results = <double>[];

  void toggleFavorite() {
    if (results.contains(currentResult)) {
      results.remove(currentResult);
    } else {
      results.add(currentResult);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,  // ← Here.
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Calculadora'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.check_box),
                    label: Text('Resultados'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController firstNumerTextEditingController = TextEditingController();
  final TextEditingController secondNumerTextEditingController = TextEditingController();
  String first = '';
  String second = '';

  @override
  void dispose() {
    firstNumerTextEditingController.dispose();
    secondNumerTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var current = appState.phrases[appState.currentIndex];
    var result = 0.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: current),
          SizedBox(height: 10),
          TextField(
            controller: firstNumerTextEditingController,
            onChanged: (value) {
              setState(() {
                first = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Introduce primer número',
            ),
          ),
          TextField(
            controller: secondNumerTextEditingController,
            onChanged: (value) {
              setState(() {
                second = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Introduce segundo número',
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.toggleFavorite();
                },
                child: Text('Mi resultado'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Cambiar fórmula'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  result = appState.getSum(first, second);
                },
                child: Text('Calcular'),
              ),
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

  final String pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ↓ Add this.
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        // ↓ Make the following change.
        child: Text(
          pair,
          style: style,
          semanticsLabel: pair,
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.results.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have done '
              '${appState.results.length} operations:'),
        ),
        for (var pair in appState.results)
          ListTile(
            leading: Icon(Icons.check_box),
            title: Text(pair.toString()),
          ),
      ],
    );
  }
}