import 'package:flutter/material.dart';
import 'package:watchable/watchable.dart';

void main() => runApp(const MaterialApp(home: WatchableDemo()));

// Global state using Watchable constructor
final counter = Watchable(0);
final name = Watchable('John');
final isLoading = Watchable(false);
final price = Watchable(99.99);
final items = Watchable<List<String>>([]);

// Global state using .watchable extension
final extCounter = 42.watchable;
final extItems = <String>['apple', 'banana'].watchable;
final extFlags = <String, bool>{'dark_mode': false}.watchable;

class WatchableDemo extends StatefulWidget {
  const WatchableDemo({super.key});

  @override
  State<WatchableDemo> createState() => _WatchableDemoState();
}

class _WatchableDemoState extends State<WatchableDemo> {
  final email = Watchable('');
  final password = Watchable('');
  final status = Watchable('Ready');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchable Demo'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCounterSection(),
          _buildNameSection(),
          _buildLoadingSection(),
          _buildPriceSection(),
          _buildTransformationSection(),
          _buildExtensionSection(),
          _buildCombinerSection(),
          _buildFormValidationSection(),
          _buildAlwaysNotifySection(),
          _buildShouldRebuildSection(),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  // 1. Basic Counter
  Widget _buildCounterSection() {
    return _section('Basic Counter', [
      counter.build(
          (v) => Text('Count: $v', style: const TextStyle(fontSize: 24))),
      const SizedBox(height: 8),
      Row(children: [
        ElevatedButton(
            onPressed: () => counter.value++, child: const Text('+')),
        const SizedBox(width: 8),
        ElevatedButton(
            onPressed: () => counter.value--, child: const Text('-')),
        const SizedBox(width: 8),
        ElevatedButton(
            onPressed: () => counter.value = 0, child: const Text('Reset')),
      ]),
    ]);
  }

  // 2. Name Input
  Widget _buildNameSection() {
    return _section('Name Input', [
      name.build(
          (v) => Text('Hello, $v!', style: const TextStyle(fontSize: 20))),
      const SizedBox(height: 8),
      TextField(
        onChanged: (v) => name.value = v,
        decoration: const InputDecoration(
            labelText: 'Enter name', border: OutlineInputBorder()),
      ),
    ]);
  }

  // 3. Loading State
  Widget _buildLoadingSection() {
    return _section('Loading State', [
      isLoading.build((loading) => loading
          ? const Row(children: [
              CircularProgressIndicator(),
              SizedBox(width: 8),
              Text('Loading...')
            ])
          : const Text('Ready',
              style: TextStyle(color: Colors.green, fontSize: 18))),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: () => isLoading.value = !isLoading.value,
        child: const Text('Toggle Loading'),
      ),
    ]);
  }

  // 4. Price Calculator
  Widget _buildPriceSection() {
    return _section('Price Calculator', [
      price.build((v) => Text('\$${v.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 24, color: Colors.orange))),
      const SizedBox(height: 8),
      Row(children: [
        ElevatedButton(
            onPressed: () => price.value += 10, child: const Text('+\$10')),
        const SizedBox(width: 8),
        ElevatedButton(
            onPressed: () => price.value -= 10, child: const Text('-\$10')),
      ]),
    ]);
  }

  // 5. Transformations (map, where, distinct)
  Widget _buildTransformationSection() {
    return _section('Transformations', [
      const Text('map():', style: TextStyle(fontWeight: FontWeight.bold)),
      counter
          .map((v) => 'Count $v is ${v.isEven ? "Even" : "Odd"}')
          .build((v) => Text(v, style: const TextStyle(color: Colors.purple))),
      const SizedBox(height: 8),
      const Text('where():', style: TextStyle(fontWeight: FontWeight.bold)),
      counter.where((v) => v >= 0).build((v) =>
          Text('Positive: $v', style: const TextStyle(color: Colors.teal))),
      const SizedBox(height: 8),
      const Text('distinct():', style: TextStyle(fontWeight: FontWeight.bold)),
      counter.distinct().build((v) =>
          Text('Distinct: $v', style: const TextStyle(color: Colors.indigo))),
    ]);
  }

  // 6. Extension API (.watchable)
  Widget _buildExtensionSection() {
    return _section('.watchable Extension API', [
      // Int extension
      extCounter.build((v) => Text('Counter: $v')),
      Row(children: [
        ElevatedButton(
            onPressed: () => extCounter.increment(), child: const Text('++')),
        const SizedBox(width: 8),
        ElevatedButton(
            onPressed: () => extCounter.decrement(), child: const Text('--')),
      ]),
      const SizedBox(height: 12),

      // List extension
      extItems.build((items) => Text('Items: ${items.join(", ")}')),
      Row(children: [
        ElevatedButton(
            onPressed: () => extItems.add('orange'), child: const Text('Add')),
        const SizedBox(width: 8),
        ElevatedButton(
            onPressed: () => extItems.clear(), child: const Text('Clear')),
      ]),
      const SizedBox(height: 12),

      // Map extension
      extFlags.build((flags) => Text(
          'Flags: ${flags.entries.map((e) => "${e.key}: ${e.value}").join(", ")}')),
      ElevatedButton(
        onPressed: () => extFlags.toggle('dark_mode'),
        child: const Text('Toggle Dark Mode'),
      ),
    ]);
  }

  // 7. Combiners
  Widget _buildCombinerSection() {
    return _section('Combiners', [
      const Text('WatchableCombined2:',
          style: TextStyle(fontWeight: FontWeight.bold)),
      WatchableCombined2(name, counter, (n, c) => '$n clicked $c times')
          .build((v) => Text(v, style: const TextStyle(color: Colors.brown))),
      const SizedBox(height: 8),
      const Text('WatchableCombined3:',
          style: TextStyle(fontWeight: FontWeight.bold)),
      WatchableCombined3(
        name,
        counter,
        isLoading,
        (n, c, l) => l ? 'Loading...' : '$n: $c clicks',
      ).build((v) => Text(v, style: const TextStyle(color: Colors.red))),
    ]);
  }

  // 8. Form Validation
  Widget _buildFormValidationSection() {
    return _section('Form Validation', [
      TextField(
        onChanged: (v) => email.value = v,
        decoration: const InputDecoration(
            labelText: 'Email', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 8),
      TextField(
        onChanged: (v) => password.value = v,
        obscureText: true,
        decoration: const InputDecoration(
            labelText: 'Password', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      WatchableCombined2(email, password, (e, p) {
        if (e.isEmpty) return 'Enter email';
        if (!e.contains('@')) return 'Invalid email';
        if (p.isEmpty) return 'Enter password';
        if (p.length < 6) return 'Password too short';
        return 'Valid';
      }).build((validation) {
        final isValid = validation == 'Valid';
        return Row(children: [
          Icon(isValid ? Icons.check_circle : Icons.error,
              color: isValid ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text(validation,
              style: TextStyle(color: isValid ? Colors.green : Colors.red)),
        ]);
      }),
    ]);
  }

  // 9. Always Notify
  Widget _buildAlwaysNotifySection() {
    return _section('alwaysNotify() & refresh()', [
      status.build((v) => Text('Status: $v')),
      Text('Always Notify: ${status.isAlwaysNotifying ? "ON" : "OFF"}',
          style: TextStyle(
              color: status.isAlwaysNotifying ? Colors.green : Colors.grey)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ElevatedButton(
            onPressed: () => status.value = 'Ready',
            child: const Text('Set "Ready"')),
        ElevatedButton(
            onPressed: () => status.refresh(), child: const Text('refresh()')),
        ElevatedButton(
          onPressed: () =>
              status.alwaysNotify(enabled: !status.isAlwaysNotifying),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                status.isAlwaysNotifying ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(status.isAlwaysNotifying ? 'Disable' : 'Enable'),
        ),
      ]),
    ]);
  }

  // 10. shouldRebuild Optimization
  Widget _buildShouldRebuildSection() {
    return _section('shouldRebuild Optimization', [
      WatchableBuilder<int>(
        watchable: counter,
        shouldRebuild: (prev, curr) => curr % 5 == 0,
        builder: (v) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('Updates every 5 clicks: $v',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }
}
