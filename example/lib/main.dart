import 'package:flutter/material.dart';
import 'package:watchable/watchable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final counterWatchable = StateWatchable<int>(0);
  final textWatchable = StateWatchable<String>('');
  final eventWatchable = Watchable<String>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Watchable Demo')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WatchableBuilder<int>(
              watchable: counterWatchable,
              builder: (context, value, child) {
                return Text('Counter: $value',
                    style: const TextStyle(fontSize: 24));
              },
            ),
            ElevatedButton(
              onPressed: () =>
                  counterWatchable.emit(counterWatchable.value + 1),
              child: const Text('Increment'),
            ),
            const SizedBox(height: 20),
            WatchableBuilder<String>(
              watchable: textWatchable,
              builder: (context, value, child) {
                return Text('Text: $value',
                    style: const TextStyle(fontSize: 24));
              },
            ),
            TextField(
              onChanged: (value) => textWatchable.emit(value),
              decoration: const InputDecoration(labelText: 'Enter text'),
            ),
            const SizedBox(height: 20),
            WatchableConsumer<String>(
              watchable: eventWatchable,
              onEvent: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Event received: $value')),
                );
              },
              child: ElevatedButton(
                onPressed: () => eventWatchable.emit('Button pressed!'),
                child: const Text('Trigger Event'),
              ),
            ),
            const SizedBox(height: 20),
            WatchableBuilder.from2<int, String, String>(
              watchable1: counterWatchable,
              watchable2: textWatchable,
              combiner: (count, text) => 'Combined: Count=$count, Text="$text"',
              builder: (context, value, child) {
                return Text(value, style: const TextStyle(fontSize: 18));
              },
            ),
          ],
        ),
      ),
    );
  }
}
