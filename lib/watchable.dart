import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

/// Type-safe combiner for 2 watchables
class _CombineLatest2Watchable<A, B, T> extends MutableStateWatchable<T> {
  final List<Function> _unwatchFunctions = [];

  _CombineLatest2Watchable(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    T Function(A, B) combiner,
  ) : super(combiner(watchable1.value, watchable2.value)) {
    void watcher1(A value) => emit(combiner(value, watchable2.value));
    void watcher2(B value) => emit(combiner(watchable1.value, value));

    watchable1.watch(watcher1);
    watchable2.watch(watcher2);
    _unwatchFunctions.add(() => watchable1.unwatch(watcher1));
    _unwatchFunctions.add(() => watchable2.unwatch(watcher2));
  }

  @override
  void dispose() {
    for (final unwatch in _unwatchFunctions) {
      unwatch();
    }
    super.dispose();
  }
}

/// Type-safe combiner for 3 watchables
class _CombineLatest3Watchable<A, B, C, T> extends MutableStateWatchable<T> {
  final List<Function> _unwatchFunctions = [];

  _CombineLatest3Watchable(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    T Function(A, B, C) combiner,
  ) : super(combiner(watchable1.value, watchable2.value, watchable3.value)) {
    void watcher1(A value) => emit(combiner(value, watchable2.value, watchable3.value));
    void watcher2(B value) => emit(combiner(watchable1.value, value, watchable3.value));
    void watcher3(C value) => emit(combiner(watchable1.value, watchable2.value, value));

    watchable1.watch(watcher1);
    watchable2.watch(watcher2);
    watchable3.watch(watcher3);
    _unwatchFunctions.add(() => watchable1.unwatch(watcher1));
    _unwatchFunctions.add(() => watchable2.unwatch(watcher2));
    _unwatchFunctions.add(() => watchable3.unwatch(watcher3));
  }

  @override
  void dispose() {
    for (final unwatch in _unwatchFunctions) {
      unwatch();
    }
    super.dispose();
  }
}

/// Type-safe combiner for 4 watchables
class _CombineLatest4Watchable<A, B, C, D, T> extends MutableStateWatchable<T> {
  final List<Function> _unwatchFunctions = [];

  _CombineLatest4Watchable(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    T Function(A, B, C, D) combiner,
  ) : super(combiner(watchable1.value, watchable2.value, watchable3.value, watchable4.value)) {
    void watcher1(A value) => emit(combiner(value, watchable2.value, watchable3.value, watchable4.value));
    void watcher2(B value) => emit(combiner(watchable1.value, value, watchable3.value, watchable4.value));
    void watcher3(C value) => emit(combiner(watchable1.value, watchable2.value, value, watchable4.value));
    void watcher4(D value) => emit(combiner(watchable1.value, watchable2.value, watchable3.value, value));

    watchable1.watch(watcher1);
    watchable2.watch(watcher2);
    watchable3.watch(watcher3);
    watchable4.watch(watcher4);
    _unwatchFunctions.add(() => watchable1.unwatch(watcher1));
    _unwatchFunctions.add(() => watchable2.unwatch(watcher2));
    _unwatchFunctions.add(() => watchable3.unwatch(watcher3));
    _unwatchFunctions.add(() => watchable4.unwatch(watcher4));
  }

  @override
  void dispose() {
    for (final unwatch in _unwatchFunctions) {
      unwatch();
    }
    super.dispose();
  }
}

/// Type-safe combiner for 5 watchables
class _CombineLatest5Watchable<A, B, C, D, E, T> extends MutableStateWatchable<T> {
  final List<Function> _unwatchFunctions = [];

  _CombineLatest5Watchable(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    StateWatchable<E> watchable5,
    T Function(A, B, C, D, E) combiner,
  ) : super(combiner(watchable1.value, watchable2.value, watchable3.value, watchable4.value, watchable5.value)) {
    void watcher1(A value) => emit(combiner(value, watchable2.value, watchable3.value, watchable4.value, watchable5.value));
    void watcher2(B value) => emit(combiner(watchable1.value, value, watchable3.value, watchable4.value, watchable5.value));
    void watcher3(C value) => emit(combiner(watchable1.value, watchable2.value, value, watchable4.value, watchable5.value));
    void watcher4(D value) => emit(combiner(watchable1.value, watchable2.value, watchable3.value, value, watchable5.value));
    void watcher5(E value) => emit(combiner(watchable1.value, watchable2.value, watchable3.value, watchable4.value, value));

    watchable1.watch(watcher1);
    watchable2.watch(watcher2);
    watchable3.watch(watcher3);
    watchable4.watch(watcher4);
    watchable5.watch(watcher5);
    _unwatchFunctions.add(() => watchable1.unwatch(watcher1));
    _unwatchFunctions.add(() => watchable2.unwatch(watcher2));
    _unwatchFunctions.add(() => watchable3.unwatch(watcher3));
    _unwatchFunctions.add(() => watchable4.unwatch(watcher4));
    _unwatchFunctions.add(() => watchable5.unwatch(watcher5));
  }

  @override
  void dispose() {
    for (final unwatch in _unwatchFunctions) {
      unwatch();
    }
    super.dispose();
  }
}

/// A class that combines multiple StateWatchable instances and emits a combined value.
class CombineLatestWatchable<T, R> extends MutableStateWatchable<R> {
  /// List of functions to unwatch the watchables.
  final List<Function> _unwatchFunctions = [];

  /// Creates a CombineLatestWatchable instance.
  ///
  /// [watchableList] is the list of StateWatchable instances to combine.
  /// [combiner] is the function that combines the values from the watchableList.
  CombineLatestWatchable(
    Iterable<StateWatchable<T>> watchableList,
    R Function(List<T> values) combiner,
  ) : super(_initialValue(watchableList, combiner)) {
    for (final watchable in watchableList) {
      // Watcher function to handle emitted values
      watcher(emittedValue) {
        final data = combiner(watchableList.map((b) => b.value).toList());
        emit(data);
      }

      // Start watching each watchable
      watchable.watch(watcher);
      _unwatchFunctions.add(() => watchable.unwatch(watcher));
    }
  }

  /// Computes the initial combined value from the watchable list.
  static R _initialValue<T, R>(
      Iterable<StateWatchable<T>> watchableList, R Function(List<T>) combiner) {
    if (watchableList.isEmpty) {
      throw ArgumentError('watchableList cannot be empty');
    }
    return combiner(watchableList.map((b) => b.value).toList());
  }

  @override
  void dispose() {
    // Unwatch all watchables when disposing
    for (final unwatch in _unwatchFunctions) {
      unwatch();
    }
    super.dispose();
  }
}

typedef WatchableWidgetBuilder<T> = Widget Function(
    BuildContext context, T value, Widget? child);

/// State class for WatchableBuilder widget.
class _WatchableBuilderState<T> extends State<WatchableBuilder<T>> {
  /// Current value of the watchable.
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.watchable.value;
    widget.watchable.watch(_handleValueChanged);
  }

  @override
  void didUpdateWidget(WatchableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.watchable != widget.watchable) {
      oldWidget.watchable.unwatch(_handleValueChanged);
      _value = widget.watchable.value;
      widget.watchable.watch(_handleValueChanged);
    }
  }

  @override
  void dispose() {
    widget.watchable.unwatch(_handleValueChanged);
    super.dispose();
  }

  /// Handles value changes and updates the state accordingly.
  void _handleValueChanged(T newValue) {
    bool shouldRebuild = true;
    try {
      shouldRebuild = widget.shouldRebuild?.call(_value, newValue) ?? true;
    } catch (error, stackTrace) {
      // Log error in debug mode, default to rebuilding
      assert(() {
        debugPrint('WatchableBuilder shouldRebuild error: $error\n$stackTrace');
        return true;
      }());
      shouldRebuild = true; // Default to rebuilding on error
    }
    
    _value = newValue; // Always update the internal value
    
    if (shouldRebuild) {
      // Only trigger setState (and rebuild) if shouldRebuild returns true
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value, widget.child);
  }
}

/// A widget that rebuilds itself based on the value of a StateWatchable.
class WatchableBuilder<T> extends StatefulWidget {
  /// The watchable whose value changes will trigger rebuilds.
  final StateWatchable<T> watchable;

  /// The builder function to create the widget tree.
  final WatchableWidgetBuilder<T> builder;

  /// An optional child widget.
  final Widget? child;

  /// An optional function to determine whether to rebuild on value change.
  final bool Function(T previous, T current)? shouldRebuild;

  const WatchableBuilder({
    super.key,
    required this.watchable,
    required this.builder,
    this.child,
    this.shouldRebuild,
  });

  @override
  State<WatchableBuilder<T>> createState() => _WatchableBuilderState<T>();

  /// Creates a [WatchableBuilder] from a list of [StateWatchable] instances and a combiner function.
  static WatchableBuilder fromList<T>({
    Key? key,
    required List<StateWatchable<T>> watchableList,
    required T Function(List values) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        key: key,
        shouldRebuild: shouldRebuild,
        watchable:
            CombineLatestWatchable(watchableList, (values) => combiner(values)),
        builder: builder,
        child: child,
      );

  /// Creates a [WatchableBuilder] from two [StateWatchable] instances and a combiner function.
  static WatchableBuilder from2<A, B, T>({
    Key? key,
    required StateWatchable<A> watchable1,
    required StateWatchable<B> watchable2,
    required T Function(A first, B second) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        key: key,
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatest2Watchable(watchable1, watchable2, combiner),
        builder: builder,
        child: child,
      );

  /// Creates a [WatchableBuilder] from three [StateWatchable] instances and a combiner function.
  static WatchableBuilder from3<A, B, C, T>({
    Key? key,
    required StateWatchable<A> watchable1,
    required StateWatchable<B> watchable2,
    required StateWatchable<C> watchable3,
    required T Function(A first, B second, C third) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        key: key,
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatest3Watchable(watchable1, watchable2, watchable3, combiner),
        builder: builder,
        child: child,
      );

  /// Creates a [WatchableBuilder] from four [StateWatchable] instances and a combiner function.
  static WatchableBuilder from4<A, B, C, D, T>({
    Key? key,
    required StateWatchable<A> watchable1,
    required StateWatchable<B> watchable2,
    required StateWatchable<C> watchable3,
    required StateWatchable<D> watchable4,
    required T Function(A first, B second, C third, D fourth) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        key: key,
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatest4Watchable(watchable1, watchable2, watchable3, watchable4, combiner),
        builder: builder,
        child: child,
      );

  /// Creates a [WatchableBuilder] from five [StateWatchable] instances and a combiner function.
  static WatchableBuilder from5<A, B, C, D, E, T>({
    Key? key,
    required StateWatchable<A> watchable1,
    required StateWatchable<B> watchable2,
    required StateWatchable<C> watchable3,
    required StateWatchable<D> watchable4,
    required StateWatchable<E> watchable5,
    required T Function(A first, B second, C third, D fourth, E fifth) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        key: key,
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatest5Watchable(watchable1, watchable2, watchable3, watchable4, watchable5, combiner),
        builder: builder,
        child: child,
      );
}

/// A class that allows watching and emitting values.
/// 
/// This is the base interface for all watchable objects that can be observed
/// for changes and maintain a replay cache of emitted values.
abstract class Watchable<T> {
  /// Adds a watcher function that will be called whenever a new value is emitted.
  /// 
  /// The [watcher] function must not be null and will receive the emitted value
  /// of type [T] whenever [emit] is called.
  void watch(void Function(T) watcher);

  /// Removes a previously added watcher function.
  /// 
  /// The [watcher] must be the exact same function reference that was passed
  /// to [watch]. If the watcher is not found, this operation is a no-op.
  void unwatch(void Function(T) watcher);

  /// Gets the replay cache as an unmodifiable list.
  /// 
  /// Returns a list containing the most recently emitted values, limited by
  /// the replay buffer size specified during construction.
  List<T> get replayCache;

  /// Disposes the watchable by clearing watchers and replay cache.
  /// 
  /// After calling dispose, this watchable should not be used anymore.
  /// All watchers will be removed and the replay cache will be cleared.
  void dispose();
}

/// A concrete implementation of [Watchable] that allows emitting values.
/// 
/// This class provides a mutable watchable that can emit values to subscribed
/// watchers and maintains an optional replay buffer for late subscribers.
class MutableWatchable<T> implements Watchable<T> {
  /// Set of watcher functions for O(1) add/remove operations.
  final Set<void Function(T)> _watchers = <void Function(T)>{};

  /// Size of the replay buffer.
  final int _bufferSize;

  /// Queue to store the replay cache.
  final Queue<T> _replayCache;

  /// Whether this watchable has been disposed.
  bool _isDisposed = false;

  /// Creates a [MutableWatchable] instance with an optional replay buffer size.
  /// 
  /// The [replay] parameter specifies how many of the most recent values
  /// should be kept in the replay cache. When a new watcher is added,
  /// it will immediately receive all values in the replay cache.
  /// Defaults to 0 (no replay buffer).
  MutableWatchable({int replay = 0})
      : assert(replay >= 0, 'Replay buffer size must be non-negative'),
        _bufferSize = replay,
        _replayCache = Queue<T>();

  /// Emits a new value to all registered watchers.
  /// 
  /// The [value] will be added to the replay cache (if enabled) and then
  /// sent to all currently registered watchers. If any watcher throws an
  /// exception, it will be logged in debug mode but won't affect other watchers.
  void emit(T value) {
    if (_bufferSize > 0) {
      _replayCache.addLast(value);
      if (_replayCache.length > _bufferSize) {
        _replayCache.removeFirst();
      }
    }
    // Create a copy to avoid concurrent modification issues
    for (var subscriber in Set.from(_watchers)) {
      try {
        subscriber(value);
      } catch (error, stackTrace) {
        // Log error in debug mode, continue execution in release mode
        assert(() {
          debugPrint('Watchable subscriber error: $error\n$stackTrace');
          return true;
        }());
        // In release mode, silently continue to prevent app crashes
      }
    }
  }

  /// Adds a watcher function that will be called on value changes.
  /// 
  /// The [watcher] will be called immediately with any values in the replay
  /// cache, then will receive future emitted values. The same watcher function
  /// can only be registered once - duplicate registrations are ignored.
  /// 
  /// Throws [StateError] if this watchable has been disposed.
  @override
  void watch(void Function(T) watcher) {
    if (_isDisposed) {
      throw StateError('Cannot watch a disposed Watchable');
    }
    _watchers.add(watcher);
    if (_bufferSize > 0) {
      for (var value in _replayCache) {
        try {
          watcher(value);
        } catch (error, stackTrace) {
          // Log error in debug mode, continue execution in release mode
          assert(() {
            debugPrint('Watchable replay error: $error\n$stackTrace');
            return true;
          }());
          // In release mode, silently continue to prevent app crashes
        }
      }
    }
  }

  /// Removes a previously registered watcher function.
  /// 
  /// The [watcher] must be the exact same function reference that was passed
  /// to [watch]. If the watcher is not found or this watchable has been 
  /// disposed, this operation is a no-op.
  @override
  void unwatch(void Function(T) watcher) {
    if (!_isDisposed) {
      _watchers.remove(watcher);
    }
  }

  /// Gets the replay cache as an unmodifiable list.
  @override
  List<T> get replayCache => List.unmodifiable(_replayCache);

  /// Gets the number of active watchers. Used for testing.
  @visibleForTesting
  int get watcherCount => _watchers.length;

  /// Disposes the watchable by clearing watchers and replay cache.
  /// 
  /// After calling dispose, this watchable should not be used anymore.
  /// All watchers will be removed and the replay cache will be cleared.
  /// Subsequent calls to [watch] will throw a [StateError].
  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _watchers.clear();
      _replayCache.clear();
    }
  }
}

/// A class that extends Watchable to maintain a stateful value.
abstract class StateWatchable<T> extends Watchable<T> {
  T get value;
}

/// A class that extends Watchable to maintain a stateful value.
class MutableStateWatchable<T> extends MutableWatchable<T>
    implements StateWatchable<T> {
  /// Current value of the watchable.
  T _value;

  /// Optional comparison function to determine value changes.
  final bool Function(T old, T current)? compare;

  /// Creates a MutableStateWatchable instance with an initial value and an optional comparison function.
  MutableStateWatchable(T initial, {this.compare})
      : _value = initial,
        super(replay: 1) {
    // Ensure the initial value is in the replay cache by calling parent emit directly
    super.emit(initial);
  }

  /// Gets the current value.
  @override
  T get value => _value;

  @override
  void emit(T value) {
    bool hasChanged = false;
    try {
      if (compare != null) {
        hasChanged = !compare!(_value, value);
      } else if (_value is List && value is List) {
        hasChanged = !const ListEquality().equals(_value as List, value);
      } else if (_value is Map && value is Map) {
        hasChanged = !const MapEquality().equals(_value as Map, value);
      } else {
        hasChanged = value != _value;
      }
    } catch (error, stackTrace) {
      // If comparison throws, fallback to default comparison
      assert(() {
        debugPrint('MutableStateWatchable compare function error: $error\n$stackTrace');
        return true;
      }());
      hasChanged = value != _value;
    }
    
    if (hasChanged) {
      _value = value;
      super.emit(value);
    }
  }
}

/// A widget that consumes values from a Watchable and triggers an event.
class WatchableConsumer<T> extends StatefulWidget {
  /// The watchable to consume values from.
  final Watchable<T> watchable;

  /// The event to trigger on value change.
  final void Function(T value) onEvent;

  /// The child widget to display.
  final Widget child;

  const WatchableConsumer({
    super.key,
    required this.watchable,
    required this.onEvent,
    required this.child,
  });

  @override
  State<WatchableConsumer<T>> createState() => _WatchableConsumerState<T>();
}

/// State class for WatchableConsumer widget.
class _WatchableConsumerState<T> extends State<WatchableConsumer<T>> {
  @override
  void initState() {
    super.initState();
    widget.watchable.watch(_handleValueChanged);
  }

  @override
  void didUpdateWidget(WatchableConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.watchable != widget.watchable) {
      oldWidget.watchable.unwatch(_handleValueChanged);
      widget.watchable.watch(_handleValueChanged);
    }
  }

  @override
  void dispose() {
    widget.watchable.unwatch(_handleValueChanged);
    super.dispose();
  }

  /// Handles value changes and triggers the onEvent callback.
  void _handleValueChanged(T newValue) {
    try {
      widget.onEvent(newValue);
    } catch (error, stackTrace) {
      // Log error in debug mode, continue execution in release mode
      assert(() {
        debugPrint('WatchableConsumer onEvent error: $error\n$stackTrace');
        return true;
      }());
      // In release mode, silently continue to prevent app crashes
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
