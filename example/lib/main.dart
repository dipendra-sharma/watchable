import 'package:flutter/material.dart';
import 'package:watchable/watchable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watchable Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final counterWatchable = Watchable<int>(0);
  final textWatchable = Watchable<String>('');
  final boolWatchable = Watchable<bool>(false);
  final listWatchable = Watchable<List<String>>([]);

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchable Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Basic Watchable Usage:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            WatchableBuilder<int>(
              watchable: counterWatchable,
              builder: (context, value, child) =>
                  Text('Counter: $value', style: const TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () => counterWatchable.value++,
              child: const Text('Increment Counter'),
            ),
            const SizedBox(height: 20),
            const Text('Text Watchable:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              onChanged: (value) => textWatchable.value = value,
              decoration: const InputDecoration(labelText: 'Enter text'),
            ),
            WatchableBuilder<String>(
              watchable: textWatchable,
              builder: (context, value, child) => Text('Entered text: $value',
                  style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            const Text('Boolean Watchable:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            WatchableBuilder<bool>(
              watchable: boolWatchable,
              builder: (context, value, child) => Switch(
                value: value,
                onChanged: (newValue) => boolWatchable.value = newValue,
              ),
            ),
            WatchableBuilder<bool>(
              watchable: boolWatchable,
              builder: (context, value, child) => Text(
                  'Switch is ${value ? 'ON' : 'OFF'}',
                  style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            const Text('List Watchable:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () => listWatchable.value = [
                ...listWatchable.value,
                'Item ${listWatchable.value.length + 1}'
              ],
              child: const Text('Add Item'),
            ),
            WatchableBuilder<List<String>>(
              watchable: listWatchable,
              builder: (context, value, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var item in value)
                    Text(item, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Combining Watchables:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            WatchableBuilder.from2<int, String, String>(
              watchable1: counterWatchable,
              watchable2: textWatchable,
              combiner: (count, text) => 'Counter: $count, Text: $text',
              builder: (context, value, child) =>
                  Text(value, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            const Text('Reset Functionality:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {
                counterWatchable.reset();
                textWatchable.reset();
                boolWatchable.reset();
                listWatchable.reset();
              },
              child: const Text('Reset All Watchables'),
            ),
          ],
        ),
      ),
    );
  }
}
