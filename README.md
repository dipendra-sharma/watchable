# Watchable

A lightweight, intuitive state management solution for Flutter applications. Watchable offers a simple API for wrapping values and efficiently rebuilding UI components when state changes.

## Features

- Simple `Watchable<T>` class for wrapping values and notifying listeners of changes
- `WatchableBuilder` widget for efficiently rebuilding UI when state changes
- Combine multiple `Watchable` instances with ease
- Minimal boilerplate code
- Scalable from simple to complex state management scenarios

## Installation

Add `watchable` to your `pubspec.yaml`:

```yaml
dependencies:
  watchable: ^1.0.0
```

Then run `flutter pub get` to install the package.

## Usage

Here's a simple example of how to use `Watchable` and `WatchableBuilder`:

```dart
import 'package:flutter/material.dart';
import 'package:watchable/watchable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final counterWatchable = Watchable<int>(0);

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
          onPressed: () => counterWatchable.value++,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

## API Reference

### Watchable<T>

A class that holds a value of type `T` and notifies listeners when the value changes.

#### Constructor

- `Watchable(T initialValue)`: Creates a `Watchable` with an initial value.

#### Properties

- `T value`: Gets or sets the current value. Setting a new value notifies listeners if the value has changed.
- `T initial`: The initial value of the `Watchable`.

#### Methods

- `void reset()`: Resets the value to the initial value.

### WatchableBuilder<T>

A widget that rebuilds when the value of a `Watchable` changes.

#### Constructor

- `WatchableBuilder({required Watchable<T> watchable, required Widget Function(BuildContext, T, Widget?) builder, Widget? child})`: Creates a `WatchableBuilder` with the given `Watchable` and builder function.

#### Static Methods

- `WatchableBuilder<R> fromList<T>({required List<Watchable<T>> watchableList, required R Function(List<T>) combiner, required Widget Function(BuildContext, R, Widget?) builder, Widget? child})`: Creates a `WatchableBuilder` from a list of `Watchable` instances and a combiner function.

- `WatchableBuilder<R> from2<A, B, R>({required Watchable<A> watchable1, required Watchable<B> watchable2, required R Function(A, B) combiner, required Widget Function(BuildContext, R, Widget?) builder, Widget? child})`: Creates a `WatchableBuilder` from two `Watchable` instances and a combiner function.

- `WatchableBuilder<R> from3<A, B, C, R>({required Watchable<A> watchable1, required Watchable<B> watchable2, required Watchable<C> watchable3, required R Function(A, B, C) combiner, required Widget Function(BuildContext, R, Widget?) builder, Widget? child})`: Creates a `WatchableBuilder` from three `Watchable` instances and a combiner function.

- `WatchableBuilder<R> from4<A, B, C, D, R>({required Watchable<A> watchable1, required Watchable<B> watchable2, required Watchable<C> watchable3, required Watchable<D> watchable4, required R Function(A, B, C, D) combiner, required Widget Function(BuildContext, R, Widget?) builder, Widget? child})`: Creates a `WatchableBuilder` from four `Watchable` instances and a combiner function.

- `WatchableBuilder<R> from5<A, B, C, D, E, R>({required Watchable<A> watchable1, required Watchable<B> watchable2, required Watchable<C> watchable3, required Watchable<D> watchable4, required Watchable<E> watchable5, required R Function(A, B, C, D, E) combiner, required Widget Function(BuildContext, R, Widget?) builder, Widget? child})`: Creates a `WatchableBuilder` from five `Watchable` instances and a combiner function.

## Examples

For more advanced usage and examples, check out the [example](example) folder in the package repository.

## Additional Information

For more information on using this package, please refer to the [API documentation](https://pub.dev/documentation/watchable/latest/).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.