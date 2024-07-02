# Watchable

A lightweight, intuitive state management solution for Flutter applications. Watchable offers a simple API for managing state and efficiently rebuilding UI components when state changes.

## Features

- Simple and intuitive API for state management
- Efficient UI updates with fine-grained control
- Support for both mutable state and event streams
- Easy combination of multiple state objects
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

### Basic State Management

Use `StateWatchable` for managing mutable state:

```dart
final counterWatchable = StateWatchable<int>(0);

WatchableBuilder<int>(
  watchable: counterWatchable,
  builder: (context, value, child) {
    return Text('Counter: $value');
  },
)

// Update the state
counterWatchable.emit(counterWatchable.value + 1);
```

### Form Handling

Manage form state easily:

```dart
final nameWatchable = StateWatchable<String>('');
final emailWatchable = StateWatchable<String>('');

TextField(
  onChanged: (value) => nameWatchable.emit(value),
),
TextField(
  onChanged: (value) => emailWatchable.emit(value),
),

WatchableBuilder.from2<String, String, bool>(
  watchable1: nameWatchable,
  watchable2: emailWatchable,
  combiner: (name, email) => name.isNotEmpty && email.isNotEmpty,
  builder: (context, isValid, child) {
    return ElevatedButton(
      onPressed: isValid ? () => submitForm() : null,
      child: Text('Submit'),
    );
  },
)
```

### Handling Events

Use `Watchable` for event streams:

```dart
final notificationWatchable = Watchable<String>();

WatchableConsumer<String>(
  watchable: notificationWatchable,
  onEvent: (message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  },
  child: YourWidget(),
)

// Trigger an event
notificationWatchable.emit('New notification!');
```

### Combining Multiple States

Easily combine multiple state objects:

```dart
final userWatchable = StateWatchable<User?>(null);
final postsWatchable = StateWatchable<List<Post>>([]);

WatchableBuilder.from2<User?, List<Post>, Widget>(
  watchable1: userWatchable,
  watchable2: postsWatchable,
  combiner: (user, posts) {
    if (user == null) return LoginScreen();
    return PostList(user: user, posts: posts);
  },
  builder: (context, widget, child) => widget,
)
```

### Optimizing Rebuilds

Use `shouldRebuild` to control when the UI updates:

```dart
WatchableBuilder<List<Item>>(
  watchable: itemsWatchable,
  shouldRebuild: (previous, current) => previous.length != current.length,
  builder: (context, items, child) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemTile(item: items[index]),
    );
  },
)
```

### Managing Complex State

For more complex state, you can create a custom state class:

```dart
class AppState {
  final StateWatchable<User?> user = StateWatchable(null);
  final StateWatchable<List<Todo>> todos = StateWatchable([]);
  final Watchable<String> notifications = Watchable();

  void login(User user) => this.user.emit(user);
  void logout() => this.user.emit(null);
  void addTodo(Todo todo) => todos.emit([...todos.value, todo]);
  void notify(String message) => notifications.emit(message);
}

final appState = AppState();

// Usage
WatchableBuilder<User?>(
  watchable: appState.user,
  builder: (context, user, child) {
    return user != null ? HomeScreen() : LoginScreen();
  },
)
```

## Additional Information

For more detailed API information and advanced usage, please refer to the [API documentation](https://pub.dev/documentation/watchable/latest/).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for details.