# Watchable

A lightweight, intuitive state management solution for Flutter applications. Watchable offers a
simple API for wrapping values and efficiently rebuilding UI components when state changes.

## Features

- `StateWatchable<T>` class for mutable state management with change notifications
- `Watchable<T>` class for event stream management
- `WatchableBuilder` widget for efficiently rebuilding UI when state changes
- `WatchableConsumer` widget for handling event streams
- Combine multiple `StateWatchable` instances with ease
- Minimal boilerplate code
- Scalable from simple to complex state management scenarios

## Installation

Add `watchable` to your `pubspec.yaml`:

```yaml
dependencies:
  watchable: any
```

Then run `flutter pub get` to install the package.

## Usage

Here's a simple example of how to use `StateWatchable` and `WatchableBuilder`:

```dart
import 'package:flutter/material.dart';
import 'package:watchable/watchable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final counterWatchable = StateWatchable<int>(0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Watchable Example')),
        body: Center(
          child: WatchableBuilder<int>(
            watchable: counterWatchable,
            builder: (context, value, child) {
              return Text('Counter: $value');
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => counterWatchable.emit(counterWatchable.value + 1),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

## API Reference

### StateWatchable<T>

A class that holds a mutable value of type `T` and notifies listeners when the value changes.

#### Constructor

- `StateWatchable(T initial, {bool Function(T old, T current)? compare})`: Creates
  a `StateWatchable` with an initial value and an optional comparison function.

#### Properties

- `T value`: Gets the current value.

#### Methods

- `void emit(T value)`: Sets a new value and notifies listeners if the value has changed.

### Watchable<T>

A class that represents an event stream of type `T`.

#### Constructor

- `Watchable({int replay = 0})`: Creates a `Watchable` with an optional replay cache size.

#### Methods

- `void emit(T value)`: Emits a new value to all subscribers.
- `void watch(Function(T) watcher)`: Adds a subscriber to the watchable.
- `void unwatch(Function(T) watcher)`: Removes a subscriber from the watchable.

### WatchableBuilder<T>

A widget that rebuilds when the value of a `StateWatchable` changes.

#### Constructor

- `WatchableBuilder({required StateWatchable<T> watchable, required Widget Function(BuildContext, T, Widget?) builder, bool Function(T previous, T current)? shouldRebuild, Widget? child})`:
  Creates a `WatchableBuilder` with the given `StateWatchable` and builder function.

#### Static Methods

- `WatchableBuilder<T> fromList<T>({required List<StateWatchable<T>> watchableList, required T Function(List values) combiner, required Widget Function(BuildContext, T, Widget?) builder, bool Function(T previous, T current)? shouldRebuild, Widget? child})`:
  Creates a `WatchableBuilder` from a list of `StateWatchable` instances and a combiner function.

- `WatchableBuilder<T> from2<A, B, T>({required StateWatchable<A> watchable1, required StateWatchable<B> watchable2, required T Function(A first, B second) combiner, required Widget Function(BuildContext, T, Widget?) builder, bool Function(T previous, T current)? shouldRebuild, Widget? child})`:
  Creates a `WatchableBuilder` from two `StateWatchable` instances and a combiner function.

- Similar methods exist for `from3`, `from4`, and `from5`, combining 3, 4, and 5 `StateWatchable`
  instances respectively.

### WatchableConsumer<T>

A widget that handles events from a `Watchable`.

#### Constructor

- `WatchableConsumer({required Watchable<T> watchable, required void Function(T value) onEvent, required Widget child})`:
  Creates a `WatchableConsumer` with the given `Watchable`, event handler, and child widget.

## Examples

For more advanced usage and examples, check out the [example](example) folder in the package
repository.

## Additional Information

For more information on using this package, please refer to
the [API documentation](https://pub.dev/documentation/watchable/latest/).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for
details.