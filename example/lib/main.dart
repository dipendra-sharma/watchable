import 'package:flutter/material.dart';
import 'package:watchable/watchable.dart';

void main() {
  runApp(const MaterialApp(
    home: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  // =======================================================================
  // NEW CONST-COMPATIBLE WATCHABLE API
  // =======================================================================

  // Basic const watchables - can be created as const!
  static const counter = Watchable(0);
  static const name = Watchable('John');
  static const isLoading = Watchable(false);
  static const price = Watchable(99.99);
  static const items = Watchable<List<String>>([]);

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // =======================================================================
  var extensionCounter = 42.watchable;

  var extensionName = 'Jane'.watchable;

  var extensionPrice = 149.99.watchable;

  var extensionItems = <String>['apple', 'banana'].watchable;

  var extensionFlags = <String, bool>{'dark_mode': false}.watchable;

  // Non-const watchables for different initial values
  final email = const Watchable('');

  final password = const Watchable('');

  final status = const Watchable('Ready');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Const-Compatible Watchable Demo'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('✨ NEW CONST-COMPATIBLE WATCHABLE API'),
            const SizedBox(height: 16),
            _buildSection(
              'Basic Counter Example',
              'Direct value modification with const watchables',
              [
                WatchableBuilder<int>(
                  watchable: MainPage.counter,
                  builder: (value) => Text(
                    'Counter: $value',
                    style: const TextStyle(fontSize: 24, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => MainPage.counter.value++,
                      child: const Text('Increment'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => MainPage.counter.value--,
                      child: const Text('Decrement'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => MainPage.counter.value = 0,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
            _buildSection(
              'Name Input Example',
              'String watchable with real-time updates',
              [
                WatchableBuilder<String>(
                  watchable: MainPage.name,
                  builder: (value) => Text(
                    'Hello, $value!',
                    style: const TextStyle(fontSize: 20, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => MainPage.name.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Enter your name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            _buildSection(
              'Loading State Example',
              'Boolean watchable for state management',
              [
                WatchableBuilder<bool>(
                  watchable: MainPage.isLoading,
                  builder: (loading) => loading
                      ? const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Loading...'),
                          ],
                        )
                      : const Text(
                          '✅ Ready!',
                          style: TextStyle(fontSize: 18, color: Colors.green),
                        ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      MainPage.isLoading.value = !MainPage.isLoading.value,
                  child: const Text('Toggle Loading'),
                ),
              ],
            ),
            _buildSection(
              'Price Calculator',
              'Double watchable with formatting',
              [
                WatchableBuilder<double>(
                  watchable: MainPage.price,
                  builder: (value) => Text(
                    'Price: \$${value.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => MainPage.price.value += 10,
                      child: const Text('+\$10'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => MainPage.price.value -= 10,
                      child: const Text('-\$10'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => MainPage.price.value = 99.99,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
            _buildHeader('🔄 TRANSFORMATION FUNCTIONS'),
            _buildSection(
              'Map Transformation',
              'Transform values with map() function',
              [
                WatchableBuilder<String>(
                  watchable: MainPage.counter.map((value) =>
                      'Count: $value (${value.isEven ? 'Even' : 'Odd'})'),
                  builder: (value) => Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.purple),
                  ),
                ),
              ],
            ),
            _buildSection(
              'Where Filter',
              'Filter values with where() function',
              [
                WatchableBuilder<int>(
                  watchable: MainPage.counter.where((value) => value >= 0),
                  builder: (value) => Text(
                    'Positive Counter: $value',
                    style: const TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                ),
              ],
            ),
            _buildSection(
              'Distinct Values',
              'Remove duplicates with distinct() function',
              [
                WatchableBuilder<int>(
                  watchable: MainPage.counter.distinct(),
                  builder: (value) => Text(
                    'Distinct Counter: $value',
                    style: const TextStyle(fontSize: 16, color: Colors.indigo),
                  ),
                ),
              ],
            ),
            _buildHeader('🎯 .watchable EXTENSION EXAMPLES'),
            _buildSection(
              'Extension Counter Example',
              'Using .watchable syntax with specialized methods',
              [
                WatchableBuilder<int>(
                  watchable: extensionCounter,
                  builder: (value) => Text(
                    'Extension Counter: $value',
                    style: const TextStyle(fontSize: 24, color: Colors.purple),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => extensionCounter.increment(),
                      child: const Text('++'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => extensionCounter.decrement(),
                      child: const Text('--'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => extensionCounter.value = 42,
                      child: const Text('Reset to 42'),
                    ),
                  ],
                ),
              ],
            ),
            _buildSection(
              'Extension Collections',
              'List and Map extensions with specialized methods',
              [
                WatchableBuilder<List<String>>(
                  watchable: extensionItems,
                  builder: (items) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items (${items.length}): ${items.join(', ')}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.indigo),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => extensionItems.add('orange'),
                            child: const Text('Add Orange'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => extensionItems.remove('apple'),
                            child: const Text('Remove Apple'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => extensionItems.clear(),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildSection(
              'Extension Map Example',
              'Map watchable with toggle functionality',
              [
                WatchableBuilder<Map<String, bool>>(
                  watchable: extensionFlags,
                  builder: (flags) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flags: ${flags.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.teal),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => extensionFlags.toggle('dark_mode'),
                            child: const Text('Toggle Dark Mode'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () =>
                                extensionFlags.add('notifications', true),
                            child: const Text('Add Notifications'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => extensionFlags.clear(),
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildHeader('🔗 COMBINER EXAMPLES'),
            _buildSection(
              'Two Watchables Combined',
              'Combine multiple watchables with WatchableCombined2',
              [
                WatchableBuilder<String>(
                  watchable: WatchableCombined2(MainPage.name, MainPage.counter,
                      (n, c) => '$n has clicked $c times'),
                  builder: (value) => Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.brown),
                  ),
                ),
              ],
            ),
            _buildSection(
              'Three Watchables Combined',
              'Advanced combination with multiple states',
              [
                WatchableBuilder<String>(
                  watchable: WatchableCombined3(
                      MainPage.name,
                      MainPage.counter,
                      MainPage.isLoading,
                      (n, c, loading) => loading
                          ? 'Loading...'
                          : '$n: $c clicks, Price: \$${MainPage.price.value.toStringAsFixed(2)}'),
                  builder: (value) => Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
            _buildHeader('🎯 FORM VALIDATION EXAMPLE'),
            _buildSection(
              'Login Form',
              'Real-world form validation with combined watchables',
              [
                TextField(
                  onChanged: (value) => email.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => password.value = value,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                WatchableBuilder<String>(
                  watchable: WatchableCombined2(
                    email,
                    password,
                    (e, p) {
                      if (e.isEmpty) return 'Please enter email';
                      if (!e.contains('@')) return 'Invalid email format';
                      if (p.isEmpty) return 'Please enter password';
                      if (p.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return 'Valid';
                    },
                  ),
                  builder: (validation) {
                    final isValid = validation == 'Valid';
                    return Column(
                      children: [
                        Text(
                          validation,
                          style: TextStyle(
                            color: isValid ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: isValid
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Login successful for ${email.value}!')),
                                  );
                                }
                              : null,
                          child: const Text('Login'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            _buildHeader('🔔 ALWAYS NOTIFY FEATURE'),
            _buildSection(
              'Force Notifications on Identical Values',
              'Control whether identical value assignments trigger listeners',
              [
                WatchableBuilder<String>(
                  watchable: status,
                  builder: (value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: $value',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.blue),
                      ),
                      Text(
                        'Always Notify: ${status.isAlwaysNotifying ? "ON" : "OFF"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: status.isAlwaysNotifying
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => status.value = 'Ready',
                      child: const Text('Set "Ready"'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => status.refresh(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => status.alwaysNotify(
                          enabled: !status.isAlwaysNotifying),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: status.isAlwaysNotifying
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(status.isAlwaysNotifying
                          ? 'Disable Always Notify'
                          : 'Enable Always Notify'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '💡 Try: Enable "Always Notify", then click "Set Ready" multiple times. '
                  'Each click will trigger a rebuild even with the same value!',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            _buildHeader('📊 shouldRebuild OPTIMIZATION'),
            _buildSection(
              'Optimized Rebuilds',
              'Using shouldRebuild to control when widgets update',
              [
                WatchableBuilder<int>(
                  watchable: MainPage.counter,
                  shouldRebuild: (previous, current) => current % 5 == 0,
                  builder: (value) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Only updates every 5 clicks: $value',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            _buildHeader('💡 API BENEFITS & COMPARISON'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ Const Watchable API Benefits:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                      '• const counter = Watchable(0) - compile-time optimization'),
                  Text('• Built on Flutter\'s proven ValueNotifier foundation'),
                  Text('• Direct value modification: counter.value++'),
                  Text('• Type-safe combiners and transformations'),
                  SizedBox(height: 12),
                  Text(
                    '🚀 Extension .watchable API Benefits:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• final counter = 0.watchable - even more concise'),
                  Text(
                      '• Specialized methods: increment(), toggle(), add(), clear()'),
                  Text('• Type inference: no need to specify <T>'),
                  Text('• Collection helpers: items.add(), flags.toggle()'),
                  SizedBox(height: 12),
                  Text(
                    '⚡ Overall Benefits:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                      '• 70% less boilerplate than traditional state management'),
                  Text('• shouldRebuild optimization for performance'),
                  Text('• alwaysNotify() for forced updates when needed'),
                  Text('• refresh() method for one-time forced notifications'),
                  Text('• Deep collection equality with smart comparison'),
                  Text('• No global state complexity'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Example of the CounterState pattern for encapsulated state management
class CounterState {
  static const _counter = Watchable(0);

  // Public read-only access
  AbstractWatchable<int> get counter => _counter;

  // State modification methods
  void increment() => _counter.value++;
  void decrement() => _counter.value--;
  void reset() => _counter.value = 0;
  void addValue(int value) => _counter.value += value;
}
