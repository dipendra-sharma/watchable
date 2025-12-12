# Watchable

**The simplest Flutter state management. Ever.**

```dart
final counter = 0.watchable;        // Create
counter.value++;                // Update  
counter.build((count) => Text('$count'))  // UI
```

That's it. You just learned the entire library.

## 30-Second Start

```yaml
dependencies:
  watchable: ^6.0.0
```

```dart
import 'package:watchable/watchable.dart';

class CounterApp extends StatelessWidget {
  final counter = 0.watchable;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: counter.build((count) => Text('$count', style: TextStyle(fontSize: 48))),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => counter.value++,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

**Done.** Your app now has reactive state with automatic UI updates.

---

## Why Developers Love It

| Old Way (Provider/Bloc/GetX) | Watchable Way                   |
|------------------------------|---------------------------------|
| `notifyListeners()`          | `counter.value++`               |
| `Consumer<T>` widgets        | `counter.build()`               |
| Multiple concepts to learn   | **2 concepts total**            |
| Boilerplate code             | **Zero boilerplate**            |
| Manual stream operations     | `data.map().where().distinct()` |
| Complex state combinations   | `(a, b, c).build()`             |

---

## Real Examples

### Form Validation
```dart
final email = ''.watchable;
final password = ''.watchable;

// Multi-field validation in one line
(email, password).build((e, p) => ElevatedButton(
  onPressed: e.contains('@') && p.length >= 6 ? submit : null,
  child: Text('Login'),
))
```

### Shopping Cart
```dart
final price = 10.0.watchable;
final quantity = 1.watchable;

// Auto-calculated total
(price, quantity).build((p, q) => Text('Total: \$${p * q}'))

// Update anywhere
FloatingActionButton(
  onPressed: () => quantity.value++,
  child: Icon(Icons.add),
)
```

### Todo List
```dart
final todos = <String>[].watchable;

// Dynamic list
todos.build((list) => ListView(
  children: list.map((todo) => ListTile(title: Text(todo))).toList(),
))

// Add todo (deep equality prevents unnecessary rebuilds)
todos.value = [...todos.value, 'New todo'];

// Remove todo
todos.value = todos.value.where((todo) => todo != 'target').toList();
```

---

## All UI Patterns

```dart
// Text & Basic Widgets
message.build((msg) => Text(msg))

// Conditional Rendering  
isLoading.build((loading) => loading ? Spinner() : Content())

// Forms
(email, password).build((e, p) => LoginButton(valid: isValid(e, p)))

// Lists
items.build((list) => ListView.builder(...))

// Complex State
(user, settings, theme).build((u, s, t) => ProfilePage(...))
```

---

## Advanced Features

### O(1) Identical Comparison
```dart
// v6.0.0 uses identical() for maximum performance
final users = [User(name: 'John')].watchable;

// Only triggers rebuild when object reference changes
final sameList = users.value;
users.value = sameList;  // No rebuild - same reference

users.value = [User(name: 'John')];  // Rebuilds - new reference

// For deep equality comparison, use watchable_redux with deepEquals:
// final store = Store(initialState: state, reducer: r, equals: deepEquals);
```

### Smart Rebuilds (Performance)
```dart
// Only rebuild when value changes significantly
temperature.build(
  (temp) => ThermometerWidget(temp),
  shouldRebuild: (prev, curr) => (prev - curr).abs() > 1.0,
)
```

### Derived State
```dart
final firstName = 'John'.watchable;
final lastName = 'Doe'.watchable;

// Create computed state
final fullName = (firstName, lastName).combine((f, l) => '$f $l');

// Use everywhere
fullName.build((name) => Text(name))
appBar.build((name) => AppBar(title: Text(name)))
```

---

## Functional Transformations

Transform your reactive data streams with powerful functional programming operations:

### Map - Transform Values
```dart
// Transform types and formats
final counter = 0.watchable;
final displayText = counter.map((count) => 'Count: $count (${count.isEven ? 'Even' : 'Odd'})');

// Mathematical transformations
final celsius = 20.0.watchable;
final fahrenheit = celsius.map((c) => c * 9/5 + 32);

// Complex object transformations
final user = User(name: 'John', age: 25).watchable;
final summary = user.map((u) => '${u.name} is ${u.age} years old');
```

### Where - Filter Values
```dart
// Basic filtering
final input = 0.watchable;
final positiveOnly = input.where((value) => value >= 0);
final evenNumbers = input.where((value) => value.isEven);

// String validation
final email = ''.watchable;
final validEmails = email.where((e) => e.contains('@'));

// Complex conditions
final users = <User>[].watchable;
final hasAdults = users.where((list) => list.any((user) => user.age >= 18));
```

### Distinct - Remove Duplicates
```dart
// Remove consecutive duplicates
final input = ''.watchable;
final uniqueInput = input.distinct();

// Custom equality
final products = <Product>[].watchable;
final uniqueById = products.distinct((a, b) =>
  a.map((p) => p.id).toSet().equals(b.map((p) => p.id).toSet())
);

// Tolerance-based distinct for numbers
final measurements = 0.0.watchable;
final smoothed = measurements.distinct((a, b) => (a - b).abs() < 0.01);
```

### Chaining Transformations
```dart
// Build powerful data processing pipelines
final rawInput = ''.watchable;
final processed = rawInput
  .map((text) => text.trim())           // Clean whitespace
  .where((text) => text.isNotEmpty)     // Filter empty
  .map((text) => text.toLowerCase())    // Normalize case
  .distinct()                           // Remove duplicates
  .map((text) => text.replaceAll(' ', '_')); // Format

processed.build((result) => Text('Processed: $result'));

// Numeric processing pipeline
final numbers = 0.watchable;
final pipeline = numbers
  .map((n) => n * 2)                    // Double
  .where((n) => n > 0)                  // Positive only
  .distinct()                           // No duplicates
  .map((n) => 'Result: $n');            // Format
```

### Real-World Transformation Examples

#### Form Validation Pipeline
```dart
final email = ''.watchable;
final password = ''.watchable;

// Individual validation streams
final emailValid = email
  .map((e) => e.trim())
  .where((e) => e.isNotEmpty)
  .map((e) => e.contains('@') && e.contains('.'));

final passwordValid = password
  .where((p) => p.isNotEmpty)
  .map((p) => p.length >= 8);

// Combined validation
final formValid = (emailValid, passwordValid).combine((e, p) => e && p);

formValid.build((valid) => SubmitButton(enabled: valid));
```

#### Data Processing Stream
```dart
// Sensor data processing
final rawSensor = 0.0.watchable;

final processedData = rawSensor
  .distinct((a, b) => (a - b).abs() < 0.1)  // Filter noise
  .map((value) => value.clamp(0.0, 100.0))  // Clamp range
  .where((value) => value > 10.0)           // Minimum threshold
  .map((value) => 'Sensor: ${value.toStringAsFixed(1)}%');

processedData.build((data) => SensorDisplay(data));
```

#### State Machine Transformations
```dart
enum Status { idle, loading, success, error }

final currentStatus = Status.idle.watchable;

// Derive UI states from enum
final isLoading = currentStatus.map((s) => s == Status.loading);
final hasError = currentStatus.map((s) => s == Status.error);
final isSuccess = currentStatus.map((s) => s == Status.success);

// Reactive UI based on state
(isLoading, hasError, isSuccess).build((loading, error, success) {
  if (loading) return CircularProgressIndicator();
  if (error) return ErrorWidget('Something went wrong');
  if (success) return SuccessWidget('Operation completed');
  return IdleWidget();
});
```

---

## Architecture Example

```dart
class TodoApp {
  // State
  final todos = <Todo>[].watchable;
  final filter = 'all'.watchable;
  
  // Computed
  late final visibleTodos = (todos, filter).combine((list, f) => 
    f == 'active' ? list.where((t) => !t.done).toList() : list
  );
  
  // UI
  Widget build() => Column(children: [
    // Filter buttons
    filter.build((f) => FilterButtons(current: f)),
    
    // Todo list
    visibleTodos.build((todos) => TodoList(todos)),
    
    // Add button  
    FloatingActionButton(onPressed: addTodo),
  ]);
  
  void addTodo() => todos.value = [...todos.value, Todo('New')];
}
```

---

## Migration

### From GetX
```dart
// GetX
final counter = 0.obs;
counter.value++;
Obx(() => Text('${counter.value}'))

// Watchable (same syntax, better!)
final counter = 0.watchable;
counter.value++;
counter.build((count) => Text('$count'))
```

### From Provider
```dart
// Provider (verbose)
ChangeNotifierProvider(
  create: (_) => CounterNotifier(),
  child: Consumer<CounterNotifier>(
    builder: (context, counter, child) => Text('${counter.value}'),
  ),
)

// Watchable (simple)
final counter = 0.watchable;
counter.build((count) => Text('$count'))
```

---

## Why Switch?

- **Learn once, use everywhere** - Same pattern for all state
- **Zero boilerplate** - No providers, consumers, or notifiers
- **Automatic optimization** - Built-in performance features
- **Type safe** - Compile-time error catching
- **O(1) identical() comparison** - Maximum performance with immutable patterns
- **Functional transformations** - Built-in map, where, distinct operations
- **Multi-state combining** - Tuple syntax for 2-6 watchable
- **Type-specific shortcuts** - increment(), toggle(), add(), clear()
- **Bulletproof reliability** - 152 comprehensive tests, 100% success rate
- **Production ready** - Advanced error handling and memory management
- **Tiny size** - Single import, lightweight

---

## Tuple Operations & Advanced Patterns

### Multi-State Combining (2-6 watchable)
```dart
// Form validation with multiple fields
(email, password, confirmPassword).build((e, p, c) =>
  SubmitButton(
    enabled: isValidEmail(e) && p.length >= 8 && p == c,
    onPressed: () => register(e, p),
  )
)

// Shopping cart calculations
(price, quantity, tax, discount).build((p, q, t, d) {
  final subtotal = p * q;
  final discounted = subtotal * (1 - d);
  final total = discounted * (1 + t);
  return PriceDisplay(total: total);
})

// Real-time dashboard
(users, orders, revenue, alerts).build((u, o, r, a) =>
  Dashboard(
    userCount: u.length,
    orderCount: o.length,
    totalRevenue: r,
    hasAlerts: a.isNotEmpty,
  )
)
```

### Derive New State from Combinations
```dart
// Compute full name
final fullName = (firstName, lastName).combine((f, l) => '$f $l');

// Calculate BMI
final bmi = (weight, height).combine((w, h) => w / (h * h));

// Combine multiple filters
final filteredData = (searchTerm, category, sortOrder).combine((search, cat, sort) =>
  data.where((item) =>
    item.name.contains(search) &&
    item.category == cat
  ).toList()..sort(sort)
);
```

### Type-Specific Shortcuts
```dart
// Integer operations
final counter = 0.watchable;
counter.increment();      // counter.value++
counter.increment(5);     // counter.value += 5
counter.reset();          // counter.value = 0

// String operations
final text = 'hello'.watchable;
text.append(' world');    // text.value += ' world'
text.toUpperCase();       // text.value = text.value.toUpperCase()
text.clear();             // text.value = ''

// Boolean operations
final flag = false.watchable;
flag.toggle();            // flag.value = !flag.value
flag.setTrue();           // flag.value = true

// List operations
final items = <String>[].watchable;
items.add('item');        // Immutable add
items.remove('item');     // Immutable remove
items.clear();            // items.value = []

// Map operations
final config = <String, int>{}.watchable;
config.set('timeout', 30); // Immutable set
config.removeKey('old');    // Immutable remove
```

### Performance Optimization
```dart
// Control rebuild frequency
temperature.build(
  (temp) => ThermometerWidget(temp),
  shouldRebuild: (prev, curr) => (prev - curr).abs() > 1.0,
);

// Debounce rapid changes
searchInput
  .distinct()
  .where((query) => query.length >= 3)
  .build((query) => SearchResults(query));

// Only rebuild on significant list changes
items.build(
  (list) => ItemCount(list.length),
  shouldRebuild: (prev, curr) => prev.length != curr.length,
);
```

## Pro Tips

```dart
// Events (no special event type needed!)
final notification = ''.watchable;
notification.value = 'Hello!';  // Triggers UI update

// Multiple state updates
final user = User().watchable;
user.value = user.value.copyWith(name: 'New Name');

// Bulk operations
final items = <Item>[].watchable;
items.value = [...items.value, newItem];  // Add
items.value = items.value.where((i) => i.id != id).toList();  // Remove

// Force notifications even for identical values
final status = 'ready'.watchable;
status.alwaysNotify(enabled: true);
status.value = 'ready';  // Still triggers rebuild
status.refresh();        // Force one-time notification

// Chain transformations for data pipelines
final processed = rawData
  .map((data) => cleanData(data))
  .where((data) => isValid(data))
  .distinct()
  .map((data) => formatForUI(data));
```

---

**That's it!** You now know everything about Watchable. 

🚀 **Start building** - it really is this simple.

---

*Made with ❤️ for Flutter developers who value simplicity*