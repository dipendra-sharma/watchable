import 'package:flutter/material.dart';
import 'package:watchable/watchable.dart';

void main() {
  runApp(MaterialApp(
    home: MainPage(),
  ));
}

class MainPage extends StatelessWidget {
  // =======================================================================
  // TRADITIONAL API (Verbose but Explicit)
  // =======================================================================
  final _counterWatchable = MutableStateWatchable<int>(0);
  StateWatchable<int> get counterWatchable => _counterWatchable;
  
  final _textWatchable = MutableStateWatchable<String>('');
  StateWatchable<String> get textWatchable => _textWatchable;
  
  final _eventWatchable = MutableWatchable<String>();
  Watchable<String> get eventWatchable => _eventWatchable;

  // =======================================================================
  // NEW EXTENSION API (Concise and Developer-Friendly) 
  // =======================================================================
  final counter = 0.watch;           // WInt - 70% less code!
  final name = 'John'.watch;         // WString
  final isLoading = false.watch;     // WBool
  final price = 99.99.watch;         // WDouble
  final items = <String>[].watch;    // WList<String>
  final notifications = WEvent<String>();  // Event stream

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchable API Comparison')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔥 NEW EXTENSION API',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // New API - Counter
            counter.build((value) => Text(
              'Counter: $value',
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            )),
            ElevatedButton(
              onPressed: () => counter.emit(counter.value + 1),
              child: const Text('Increment (New API)'),
            ),
            const SizedBox(height: 16),
            
            // New API - Name
            name.build((value) => Text(
              'Name: $value',
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            )),
            TextField(
              onChanged: (value) => name.emit(value),
              decoration: const InputDecoration(
                labelText: 'Enter name (New API)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // New API - Loading State
            isLoading.build((loading) => loading 
              ? const CircularProgressIndicator()
              : const Text('Ready!', style: TextStyle(color: Colors.green))
            ),
            ElevatedButton(
              onPressed: () => isLoading.emit(!isLoading.value),
              child: const Text('Toggle Loading'),
            ),
            const SizedBox(height: 16),
            
            // New API - Price
            price.build((value) => Text(
              'Price: \$${value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            )),
            ElevatedButton(
              onPressed: () => price.emit(price.value - 10),
              child: const Text('Discount \$10'),
            ),
            
            const Divider(height: 40),
            const Text(
              '📚 TRADITIONAL API',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Traditional API - Counter
            WatchableBuilder<int>(
              watchable: counterWatchable,
              builder: (context, value, child) {
                return Text('Traditional Counter: $value',
                    style: const TextStyle(fontSize: 18, color: Colors.orange));
              },
            ),
            ElevatedButton(
              onPressed: () => _counterWatchable.emit(counterWatchable.value + 1),
              child: const Text('Increment (Traditional)'),
            ),
            const SizedBox(height: 16),
            
            // Traditional API - Text
            WatchableBuilder<String>(
              watchable: textWatchable,
              builder: (context, value, child) {
                return Text('Traditional Text: $value',
                    style: const TextStyle(fontSize: 16, color: Colors.orange));
              },
            ),
            TextField(
              onChanged: (value) => _textWatchable.emit(value),
              decoration: const InputDecoration(
                labelText: 'Enter text (Traditional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Event Consumer (Traditional)
            WatchableConsumer<String>(
              watchable: eventWatchable,
              onEvent: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Event: $value')),
                );
              },
              child: ElevatedButton(
                onPressed: () => _eventWatchable.emit('Traditional event!'),
                child: const Text('Trigger Event (Traditional)'),
              ),
            ),
            const SizedBox(height: 16),
            
            // Event Consumer (New API)
            notifications.consume(
              onEvent: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('New API Event: $value')),
                );
              },
              child: ElevatedButton(
                onPressed: () => notifications.emit('New API event!'),
                child: const Text('Trigger Event (New API)'),
              ),
            ),
            
            const Divider(height: 40),
            const Text(
              '🔗 COMBINING STATES',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Traditional combiner
            WatchableBuilder.from2<int, String, String>(
              watchable1: counterWatchable,
              watchable2: textWatchable,
              combiner: (count, text) => 'Traditional: Count=$count, Text="$text"',
              builder: (context, value, child) {
                return Text(value, style: const TextStyle(fontSize: 14));
              },
            ),
            
            const SizedBox(height: 16),
            
            const Divider(height: 40),
            const Text(
              '🔗 NEW COMBINER API',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Tuple combiner demo
            (name, isLoading).build((n, loading) => 
              loading 
                ? const Text('Loading...', style: TextStyle(color: Colors.orange))
                : Text('Hello $n!', style: const TextStyle(fontSize: 18, color: Colors.green))
            ),
            
            const SizedBox(height: 16),
            
            // Watch.build2 demo
            Watch.build2(counter, price, (c, p) => 
              Text('Items: $c, Total: \$${(c * p).toStringAsFixed(2)}')
            ),
            
            const SizedBox(height: 16),
            const Text('💡 Form Validation Example'),
            Watch.build2(name, counter, (n, c) {
              final isValid = n.isNotEmpty && c > 0;
              return ElevatedButton(
                onPressed: isValid ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Form valid! Name: $n, Count: $c')),
                  );
                } : null,
                child: Text(isValid ? 'Valid Form' : 'Invalid Form'),
              );
            }),
            
            const SizedBox(height: 16),
            const Text(
              '📊 CODE COMPARISON',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Traditional: WatchableBuilder.from2(...)',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'New API: (a, b).build(...) or Watch.build2(...)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('🎯 Custom classes and complex combinations supported!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
