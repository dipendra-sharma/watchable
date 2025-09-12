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
    void watcher1(A value) =>
        emit(combiner(value, watchable2.value, watchable3.value));
    void watcher2(B value) =>
        emit(combiner(watchable1.value, value, watchable3.value));
    void watcher3(C value) =>
        emit(combiner(watchable1.value, watchable2.value, value));

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
  ) : super(combiner(watchable1.value, watchable2.value, watchable3.value,
            watchable4.value)) {
    void watcher1(A value) => emit(
        combiner(value, watchable2.value, watchable3.value, watchable4.value));
    void watcher2(B value) => emit(
        combiner(watchable1.value, value, watchable3.value, watchable4.value));
    void watcher3(C value) => emit(
        combiner(watchable1.value, watchable2.value, value, watchable4.value));
    void watcher4(D value) => emit(
        combiner(watchable1.value, watchable2.value, watchable3.value, value));

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
class _CombineLatest5Watchable<A, B, C, D, E, T>
    extends MutableStateWatchable<T> {
  final List<Function> _unwatchFunctions = [];

  _CombineLatest5Watchable(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    StateWatchable<E> watchable5,
    T Function(A, B, C, D, E) combiner,
  ) : super(combiner(watchable1.value, watchable2.value, watchable3.value,
            watchable4.value, watchable5.value)) {
    void watcher1(A value) => emit(combiner(value, watchable2.value,
        watchable3.value, watchable4.value, watchable5.value));
    void watcher2(B value) => emit(combiner(watchable1.value, value,
        watchable3.value, watchable4.value, watchable5.value));
    void watcher3(C value) => emit(combiner(watchable1.value, watchable2.value,
        value, watchable4.value, watchable5.value));
    void watcher4(D value) => emit(combiner(watchable1.value, watchable2.value,
        watchable3.value, value, watchable5.value));
    void watcher5(E value) => emit(combiner(watchable1.value, watchable2.value,
        watchable3.value, watchable4.value, value));

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

/// Type-safe combiner for 6 watchables
class _CombineLatest6Watchable<A, B, C, D, E, F, T>
    extends MutableStateWatchable<T> {
  final List<Function> _unwatchFunctions = [];

  _CombineLatest6Watchable(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    StateWatchable<E> watchable5,
    StateWatchable<F> watchable6,
    T Function(A, B, C, D, E, F) combiner,
  ) : super(combiner(watchable1.value, watchable2.value, watchable3.value,
            watchable4.value, watchable5.value, watchable6.value)) {
    void watcher1(A value) => emit(combiner(
        value,
        watchable2.value,
        watchable3.value,
        watchable4.value,
        watchable5.value,
        watchable6.value));
    void watcher2(B value) => emit(combiner(
        watchable1.value,
        value,
        watchable3.value,
        watchable4.value,
        watchable5.value,
        watchable6.value));
    void watcher3(C value) => emit(combiner(watchable1.value, watchable2.value,
        value, watchable4.value, watchable5.value, watchable6.value));
    void watcher4(D value) => emit(combiner(watchable1.value, watchable2.value,
        watchable3.value, value, watchable5.value, watchable6.value));
    void watcher5(E value) => emit(combiner(watchable1.value, watchable2.value,
        watchable3.value, watchable4.value, value, watchable6.value));
    void watcher6(F value) => emit(combiner(watchable1.value, watchable2.value,
        watchable3.value, watchable4.value, watchable5.value, value));

    watchable1.watch(watcher1);
    watchable2.watch(watcher2);
    watchable3.watch(watcher3);
    watchable4.watch(watcher4);
    watchable5.watch(watcher5);
    watchable6.watch(watcher6);
    _unwatchFunctions.add(() => watchable1.unwatch(watcher1));
    _unwatchFunctions.add(() => watchable2.unwatch(watcher2));
    _unwatchFunctions.add(() => watchable3.unwatch(watcher3));
    _unwatchFunctions.add(() => watchable4.unwatch(watcher4));
    _unwatchFunctions.add(() => watchable5.unwatch(watcher5));
    _unwatchFunctions.add(() => watchable6.unwatch(watcher6));
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
///
/// **DEPRECATED**: Use the extension API instead. Replace `WatchableBuilder<T>(watchable: w, builder: (context, value, child) => Widget)`
/// with `w.build((value) => Widget)` for 70% less code.
@Deprecated(
    'Use the extension API: watchable.build((value) => Widget) instead. Will be removed in v5.0.0')
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
  ///
  /// **DEPRECATED**: Use tuple syntax instead: `(watchable1, watchable2).build((a, b) => Widget)`
  /// or `Watch.build2(watchable1, watchable2, (a, b) => Widget)` for better readability.
  @Deprecated(
      'Use tuple syntax: (watchable1, watchable2).build((a, b) => Widget) instead. Will be removed in v5.0.0')
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
  ///
  /// **DEPRECATED**: Use tuple syntax instead: `(watchable1, watchable2, watchable3).build((a, b, c) => Widget)`
  /// or `Watch.build3(watchable1, watchable2, watchable3, (a, b, c) => Widget)` for better readability.
  @Deprecated(
      'Use tuple syntax: (watchable1, watchable2, watchable3).build((a, b, c) => Widget) instead. Will be removed in v5.0.0')
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
        watchable: _CombineLatest3Watchable(
            watchable1, watchable2, watchable3, combiner),
        builder: builder,
        child: child,
      );

  /// Creates a [WatchableBuilder] from four [StateWatchable] instances and a combiner function.
  ///
  /// **DEPRECATED**: Use tuple syntax instead: `(w1, w2, w3, w4).build((a, b, c, d) => Widget)`
  /// or `Watch.build4(w1, w2, w3, w4, (a, b, c, d) => Widget)` for better readability.
  @Deprecated(
      'Use tuple syntax: (w1, w2, w3, w4).build((a, b, c, d) => Widget) instead. Will be removed in v5.0.0')
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
        watchable: _CombineLatest4Watchable(
            watchable1, watchable2, watchable3, watchable4, combiner),
        builder: builder,
        child: child,
      );

  /// Creates a [WatchableBuilder] from five [StateWatchable] instances and a combiner function.
  ///
  /// **DEPRECATED**: Use tuple syntax instead: `(w1, w2, w3, w4, w5).build((a, b, c, d, e) => Widget)`
  /// or `Watch.build5(w1, w2, w3, w4, w5, (a, b, c, d, e) => Widget)` for better readability.
  @Deprecated(
      'Use tuple syntax: (w1, w2, w3, w4, w5).build((a, b, c, d, e) => Widget) instead. Will be removed in v5.0.0')
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
        watchable: _CombineLatest5Watchable(watchable1, watchable2, watchable3,
            watchable4, watchable5, combiner),
        builder: builder,
        child: child,
      );

  /// Creates a [WatchableBuilder] from six [StateWatchable] instances and a combiner function.
  ///
  /// **DEPRECATED**: Use tuple syntax instead: `(w1, w2, w3, w4, w5, w6).build((a, b, c, d, e, f) => Widget)`
  /// or `Watch.build6(w1, w2, w3, w4, w5, w6, (a, b, c, d, e, f) => Widget)` for better readability.
  @Deprecated(
      'Use tuple syntax: (w1, w2, w3, w4, w5, w6).build((a, b, c, d, e, f) => Widget) instead. Will be removed in v5.0.0')
  static WatchableBuilder from6<A, B, C, D, E, F, T>({
    Key? key,
    required StateWatchable<A> watchable1,
    required StateWatchable<B> watchable2,
    required StateWatchable<C> watchable3,
    required StateWatchable<D> watchable4,
    required StateWatchable<E> watchable5,
    required StateWatchable<F> watchable6,
    required T Function(A first, B second, C third, D fourth, E fifth, F sixth)
        combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        key: key,
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatest6Watchable(watchable1, watchable2, watchable3,
            watchable4, watchable5, watchable6, combiner),
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

  /// Sets the current value and emits it if changed.
  ///
  /// This is a convenience setter that calls [emit] internally.
  /// Allows for direct value assignment: `watchable.value = newValue`
  /// and compound assignments: `watchable.value += 1`
  ///
  /// Example:
  /// ```dart
  /// final counter = 0.watch;
  /// counter.value = 5;        // Direct assignment
  /// counter.value += 1;       // Compound assignment
  /// counter.value++;          // Increment (for numbers)
  /// ```
  set value(T newValue) => emit(newValue);

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
        debugPrint(
            'MutableStateWatchable compare function error: $error\n$stackTrace');
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
///
/// **DEPRECATED**: Use the extension API instead. Replace `WatchableConsumer<T>(watchable: w, onEvent: (value) => {}, child: Widget)`
/// with `w.consume(onEvent: (value) => {}, child: Widget)` for cleaner syntax.
@Deprecated(
    'Use the extension API: watchable.consume(onEvent: (value) => {}, child: Widget) instead. Will be removed in v5.0.0')
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

// ============================================================================
// DEVELOPER EXPERIENCE IMPROVEMENTS - Extension-based API
// ============================================================================

/// Type aliases for shorter, more developer-friendly names
/// State management (with current value)
typedef W<T> = MutableStateWatchable<T>;
typedef WInt = MutableStateWatchable<int>;
typedef WString = MutableStateWatchable<String>;
typedef WBool = MutableStateWatchable<bool>;
typedef WDouble = MutableStateWatchable<double>;
typedef WList<T> = MutableStateWatchable<List<T>>;
typedef WMap<K, V> = MutableStateWatchable<Map<K, V>>;

/// Event streams (no persistent value)
typedef WEvent<T> = MutableWatchable<T>;

/// Read-only variants
typedef WatchableState<T> = StateWatchable<T>;
typedef WatchableEvent<T> = Watchable<T>;

/// Extension methods to enable .watch syntax for any type
extension WatchableExtension<T> on T {
  /// Creates a MutableStateWatchable with this value as initial value
  ///
  /// Example:
  /// ```dart
  /// final counter = 0.watch;        // Creates WInt(0)
  /// final name = 'John'.watch;      // Creates WString('John')
  /// final user = User().watch;      // Creates W<User>(User())
  /// ```
  W<T> get watch => W<T>(this);
}

/// Type-specific extension for integers
extension WatchableIntExtension on int {
  /// Creates a WInt (MutableStateWatchable&lt;int&gt;) with this value
  ///
  /// Example:
  /// ```dart
  /// final counter = 0.watch;  // Creates WInt(0)
  /// counter.value++;          // Update value
  /// ```
  WInt get watch => WInt(this);
}

/// Type-specific extension for strings
extension WatchableStringExtension on String {
  /// Creates a WString (MutableStateWatchable&lt;String&gt;) with this value
  ///
  /// Example:
  /// ```dart
  /// final name = 'John'.watch;     // Creates WString('John')
  /// name.emit('Jane');             // Update value
  /// ```
  WString get watch => WString(this);
}

/// Type-specific extension for booleans
extension WatchableBoolExtension on bool {
  /// Creates a WBool (MutableStateWatchable&lt;bool&gt;) with this value
  ///
  /// Example:
  /// ```dart
  /// final isLoading = false.watch; // Creates WBool(false)
  /// isLoading.emit(true);          // Update value
  /// ```
  WBool get watch => WBool(this);
}

/// Type-specific extension for doubles
extension WatchableDoubleExtension on double {
  /// Creates a WDouble (MutableStateWatchable&lt;double&gt;) with this value
  ///
  /// Example:
  /// ```dart
  /// final price = 99.99.watch;     // Creates WDouble(99.99)
  /// price.emit(89.99);             // Update value
  /// ```
  WDouble get watch => WDouble(this);
}

/// Type-specific extension for lists
extension WatchableListExtension<T> on List<T> {
  /// Creates a WList (MutableStateWatchable&lt;List&lt;T&gt;&gt;) with this list
  ///
  /// Example:
  /// ```dart
  /// final items = <String>[].watch; // Creates WList<String>([])
  /// items.emit(['item1', 'item2']); // Update list
  /// ```
  WList<T> get watch => WList<T>(this);
}

/// Type-specific extension for maps
extension WatchableMapExtension<K, V> on Map<K, V> {
  /// Creates a WMap (MutableStateWatchable&lt;Map&lt;K,V&gt;&gt;) with this map
  ///
  /// Example:
  /// ```dart
  /// final config = <String, int>{}.watch; // Creates WMap<String, int>({})
  /// config.emit({'timeout': 30});         // Update map
  /// ```
  WMap<K, V> get watch => WMap<K, V>(this);
}

/// Widget builder extension for StateWatchable
extension StateWatchableWidgetExtension<T> on StateWatchable<T> {
  /// Creates a WatchableBuilder with a simplified builder function
  ///
  /// This is a shorthand for creating WatchableBuilder widgets.
  ///
  /// Example:
  /// ```dart
  /// final counter = 0.watch;
  ///
  /// // Instead of:
  /// WatchableBuilder<int>(
  ///   watchable: counter,
  ///   builder: (context, value, child) => Text('$value'),
  /// )
  ///
  /// // You can write:
  /// counter.build((value) => Text('$value'))
  /// ```
  Widget build(Widget Function(T value) builder,
      {bool Function(T previous, T current)? shouldRebuild}) {
    return WatchableBuilder<T>(
      watchable: this,
      shouldRebuild: shouldRebuild,
      builder: (context, value, child) => builder(value),
    );
  }
}

/// Widget consumer extension for Watchable (event streams)
extension WatchableWidgetExtension<T> on Watchable<T> {
  /// Creates a WatchableConsumer with a simplified event handler
  ///
  /// This is a shorthand for creating WatchableConsumer widgets.
  ///
  /// Example:
  /// ```dart
  /// final notifications = WEvent<String>();
  ///
  /// // Instead of:
  /// WatchableConsumer<String>(
  ///   watchable: notifications,
  ///   onEvent: (message) => showSnackBar(message),
  ///   child: MyWidget(),
  /// )
  ///
  /// // You can write:
  /// notifications.consume(
  ///   onEvent: (message) => showSnackBar(message),
  ///   child: MyWidget(),
  /// )
  /// ```
  Widget consume({
    required void Function(T value) onEvent,
    required Widget child,
  }) {
    return WatchableConsumer<T>(
      watchable: this,
      onEvent: onEvent,
      child: child,
    );
  }
}

// ============================================================================
// COMBINER EXTENSIONS - Multi-watchable support
// ============================================================================

/// Extension for combining 2 StateWatchable instances
extension StateWatchableCombiner2<A, B> on (
  StateWatchable<A>,
  StateWatchable<B>
) {
  /// Combines two StateWatchable instances into one
  ///
  /// Example:
  /// ```dart
  /// final name = 'John'.watch;
  /// final age = 25.watch;
  /// final combined = (name, age).combine((n, a) => 'Name: $n, Age: $a');
  ///
  /// combined.build((value) => Text(value))
  /// ```
  StateWatchable<R> combine<R>(R Function(A, B) combiner) {
    return _CombineLatest2Watchable($1, $2, combiner);
  }

  /// Creates a widget that builds from the combined values
  ///
  /// Example:
  /// ```dart
  /// final name = 'John'.watch;
  /// final age = 25.watch;
  ///
  /// (name, age).build((n, a) => Text('Name: $n, Age: $a'))
  /// ```
  Widget build(Widget Function(A, B) builder,
      {bool Function(Widget? previous, Widget current)? shouldRebuild}) {
    return WatchableBuilder.from2<A, B, Widget>(
      watchable1: $1,
      watchable2: $2,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }
}

/// Extension for combining 3 StateWatchable instances
extension StateWatchableCombiner3<A, B, C> on (
  StateWatchable<A>,
  StateWatchable<B>,
  StateWatchable<C>
) {
  /// Combines three StateWatchable instances into one
  ///
  /// Example:
  /// ```dart
  /// final first = 'John'.watch;
  /// final last = 'Doe'.watch;
  /// final age = 25.watch;
  /// final combined = (first, last, age).combine((f, l, a) => 'Full: $f $l ($a)');
  ///
  /// combined.build((value) => Text(value))
  /// ```
  StateWatchable<R> combine<R>(R Function(A, B, C) combiner) {
    return _CombineLatest3Watchable($1, $2, $3, combiner);
  }

  /// Creates a widget that builds from the combined values
  Widget build(Widget Function(A, B, C) builder,
      {bool Function(Widget? previous, Widget current)? shouldRebuild}) {
    return WatchableBuilder.from3<A, B, C, Widget>(
      watchable1: $1,
      watchable2: $2,
      watchable3: $3,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }
}

/// Extension for combining 4 StateWatchable instances
extension StateWatchableCombiner4<A, B, C, D> on (
  StateWatchable<A>,
  StateWatchable<B>,
  StateWatchable<C>,
  StateWatchable<D>
) {
  /// Combines four StateWatchable instances into one
  StateWatchable<R> combine<R>(R Function(A, B, C, D) combiner) {
    return _CombineLatest4Watchable($1, $2, $3, $4, combiner);
  }

  /// Creates a widget that builds from the combined values
  Widget build(Widget Function(A, B, C, D) builder,
      {bool Function(Widget? previous, Widget current)? shouldRebuild}) {
    return WatchableBuilder.from4<A, B, C, D, Widget>(
      watchable1: $1,
      watchable2: $2,
      watchable3: $3,
      watchable4: $4,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }
}

/// Extension for combining 5 StateWatchable instances
extension StateWatchableCombiner5<A, B, C, D, E> on (
  StateWatchable<A>,
  StateWatchable<B>,
  StateWatchable<C>,
  StateWatchable<D>,
  StateWatchable<E>
) {
  /// Combines five StateWatchable instances into one
  StateWatchable<R> combine<R>(R Function(A, B, C, D, E) combiner) {
    return _CombineLatest5Watchable($1, $2, $3, $4, $5, combiner);
  }

  /// Creates a widget that builds from the combined values
  Widget build(Widget Function(A, B, C, D, E) builder,
      {bool Function(Widget? previous, Widget current)? shouldRebuild}) {
    return WatchableBuilder.from5<A, B, C, D, E, Widget>(
      watchable1: $1,
      watchable2: $2,
      watchable3: $3,
      watchable4: $4,
      watchable5: $5,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }
}

/// Extension for combining 6 StateWatchable instances
extension StateWatchableCombiner6<A, B, C, D, E, F> on (
  StateWatchable<A>,
  StateWatchable<B>,
  StateWatchable<C>,
  StateWatchable<D>,
  StateWatchable<E>,
  StateWatchable<F>
) {
  /// Combines six StateWatchable instances into one
  ///
  /// Example:
  /// ```dart
  /// final firstName = 'John'.watch;
  /// final lastName = 'Doe'.watch;
  /// final age = 25.watch;
  /// final email = 'john@example.com'.watch;
  /// final isActive = true.watch;
  /// final score = 95.5.watch;
  ///
  /// final combined = (firstName, lastName, age, email, isActive, score).combine(
  ///   (first, last, a, e, active, s) =>
  ///     'User: $first $last ($a), Email: $e, Active: $active, Score: $s'
  /// );
  ///
  /// combined.build((value) => Text(value))
  /// ```
  StateWatchable<R> combine<R>(R Function(A, B, C, D, E, F) combiner) {
    return _CombineLatest6Watchable($1, $2, $3, $4, $5, $6, combiner);
  }

  /// Creates a widget that builds from the combined values
  ///
  /// Example:
  /// ```dart
  /// final firstName = 'John'.watch;
  /// final lastName = 'Doe'.watch;
  /// final age = 25.watch;
  /// final email = 'john@example.com'.watch;
  /// final isActive = true.watch;
  /// final score = 95.5.watch;
  ///
  /// (firstName, lastName, age, email, isActive, score).build(
  ///   (first, last, a, e, active, s) => Text('$first $last ($a)')
  /// )
  /// ```
  Widget build(Widget Function(A, B, C, D, E, F) builder,
      {bool Function(Widget? previous, Widget current)? shouldRebuild}) {
    return WatchableBuilder.from6<A, B, C, D, E, F, Widget>(
      watchable1: $1,
      watchable2: $2,
      watchable3: $3,
      watchable4: $4,
      watchable5: $5,
      watchable6: $6,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }
}

/// Utility class for creating combiners with extension API
class Watch {
  /// Combines 2 StateWatchable instances
  ///
  /// Example:
  /// ```dart
  /// final name = 'John'.watch;
  /// final age = 25.watch;
  ///
  /// // Create combined watchable
  /// final userInfo = Watch.combine2(name, age, (n, a) => 'Name: $n, Age: $a');
  /// userInfo.build((info) => Text(info))
  ///
  /// // Or build directly
  /// Watch.build2(name, age, (n, a) => Text('Name: $n, Age: $a'))
  /// ```
  static StateWatchable<R> combine2<A, B, R>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    R Function(A, B) combiner,
  ) {
    return _CombineLatest2Watchable(watchable1, watchable2, combiner);
  }

  /// Combines 3 StateWatchable instances
  static StateWatchable<R> combine3<A, B, C, R>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    R Function(A, B, C) combiner,
  ) {
    return _CombineLatest3Watchable(
        watchable1, watchable2, watchable3, combiner);
  }

  /// Combines 4 StateWatchable instances
  static StateWatchable<R> combine4<A, B, C, D, R>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    R Function(A, B, C, D) combiner,
  ) {
    return _CombineLatest4Watchable(
        watchable1, watchable2, watchable3, watchable4, combiner);
  }

  /// Combines 5 StateWatchable instances
  static StateWatchable<R> combine5<A, B, C, D, E, R>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    StateWatchable<E> watchable5,
    R Function(A, B, C, D, E) combiner,
  ) {
    return _CombineLatest5Watchable(
        watchable1, watchable2, watchable3, watchable4, watchable5, combiner);
  }

  /// Combines 6 StateWatchable instances
  ///
  /// Example:
  /// ```dart
  /// final firstName = 'John'.watch;
  /// final lastName = 'Doe'.watch;
  /// final age = 25.watch;
  /// final email = 'john@example.com'.watch;
  /// final isActive = true.watch;
  /// final score = 95.5.watch;
  ///
  /// final userProfile = Watch.combine6(
  ///   firstName, lastName, age, email, isActive, score,
  ///   (first, last, a, e, active, s) =>
  ///     'User: $first $last ($a), Email: $e, Active: $active, Score: $s'
  /// );
  ///
  /// userProfile.build((profile) => Text(profile))
  /// ```
  static StateWatchable<R> combine6<A, B, C, D, E, F, R>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    StateWatchable<E> watchable5,
    StateWatchable<F> watchable6,
    R Function(A, B, C, D, E, F) combiner,
  ) {
    return _CombineLatest6Watchable(watchable1, watchable2, watchable3,
        watchable4, watchable5, watchable6, combiner);
  }

  /// Builds a widget from 2 StateWatchable instances
  static Widget build2<A, B>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    Widget Function(A, B) builder, {
    bool Function(Widget? previous, Widget current)? shouldRebuild,
  }) {
    return WatchableBuilder.from2<A, B, Widget>(
      watchable1: watchable1,
      watchable2: watchable2,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }

  /// Builds a widget from 3 StateWatchable instances
  static Widget build3<A, B, C>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    Widget Function(A, B, C) builder, {
    bool Function(Widget? previous, Widget current)? shouldRebuild,
  }) {
    return WatchableBuilder.from3<A, B, C, Widget>(
      watchable1: watchable1,
      watchable2: watchable2,
      watchable3: watchable3,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }

  /// Builds a widget from 4 StateWatchable instances
  static Widget build4<A, B, C, D>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    Widget Function(A, B, C, D) builder, {
    bool Function(Widget? previous, Widget current)? shouldRebuild,
  }) {
    return WatchableBuilder.from4<A, B, C, D, Widget>(
      watchable1: watchable1,
      watchable2: watchable2,
      watchable3: watchable3,
      watchable4: watchable4,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }

  /// Builds a widget from 5 StateWatchable instances
  static Widget build5<A, B, C, D, E>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    StateWatchable<E> watchable5,
    Widget Function(A, B, C, D, E) builder, {
    bool Function(Widget? previous, Widget current)? shouldRebuild,
  }) {
    return WatchableBuilder.from5<A, B, C, D, E, Widget>(
      watchable1: watchable1,
      watchable2: watchable2,
      watchable3: watchable3,
      watchable4: watchable4,
      watchable5: watchable5,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }

  /// Builds a widget from 6 StateWatchable instances
  ///
  /// Example:
  /// ```dart
  /// final firstName = 'John'.watch;
  /// final lastName = 'Doe'.watch;
  /// final age = 25.watch;
  /// final email = 'john@example.com'.watch;
  /// final isActive = true.watch;
  /// final score = 95.5.watch;
  ///
  /// Watch.build6(firstName, lastName, age, email, isActive, score,
  ///   (first, last, a, e, active, s) => Card(
  ///     child: Column(
  ///       children: [
  ///         Text('$first $last ($a)'),
  ///         Text('Email: $e'),
  ///         Text('Status: ${active ? "Active" : "Inactive"}'),
  ///         Text('Score: $s'),
  ///       ],
  ///     ),
  ///   )
  /// )
  /// ```
  static Widget build6<A, B, C, D, E, F>(
    StateWatchable<A> watchable1,
    StateWatchable<B> watchable2,
    StateWatchable<C> watchable3,
    StateWatchable<D> watchable4,
    StateWatchable<E> watchable5,
    StateWatchable<F> watchable6,
    Widget Function(A, B, C, D, E, F) builder, {
    bool Function(Widget? previous, Widget current)? shouldRebuild,
  }) {
    return WatchableBuilder.from6<A, B, C, D, E, F, Widget>(
      watchable1: watchable1,
      watchable2: watchable2,
      watchable3: watchable3,
      watchable4: watchable4,
      watchable5: watchable5,
      watchable6: watchable6,
      combiner: builder,
      builder: (context, widget, child) => widget,
      shouldRebuild: shouldRebuild,
    );
  }
}
