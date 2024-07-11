library watchable;

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

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
    if (widget.shouldRebuild?.call(_value, newValue) ?? true) {
      setState(() {
        _value = newValue;
      });
    } else {
      _value = newValue;
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
        shouldRebuild: shouldRebuild,
        watchable: CombineLatestWatchable([watchable1, watchable2],
            (values) => combiner(values[0] as A, values[1] as B)),
        builder: builder,
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
        shouldRebuild: shouldRebuild,
        watchable: CombineLatestWatchable(
            [watchable1, watchable2, watchable3],
            (values) =>
                combiner(values[0] as A, values[1] as B, values[2] as C)),
        builder: builder,
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
        shouldRebuild: shouldRebuild,
        watchable: CombineLatestWatchable(
            [watchable1, watchable2, watchable3, watchable4],
            (values) => combiner(values[0] as A, values[1] as B, values[2] as C,
                values[3] as D)),
        builder: builder,
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
        shouldRebuild: shouldRebuild,
        watchable: CombineLatestWatchable(
            [watchable1, watchable2, watchable3, watchable4, watchable5],
            (values) => combiner(values[0] as A, values[1] as B, values[2] as C,
                values[3] as D, values[4] as E)),
        builder: builder,
      );
}

/// A class that allows watching and emitting values.
abstract class Watchable<T> {
  /// Adds a watcher function.
  void watch(Function(T) watcher);

  /// Removes a watcher function.
  void unwatch(Function(T) watcher);

  /// Gets the replay cache as an unmodifiable list.
  List<T> get replayCache;

  /// Disposes the watchable by clearing watchers and replay cache.
  void dispose();
}

/// A class that allows watching and emitting values.
class MutableWatchable<T> implements Watchable<T> {
  /// List of watcher functions.
  final List<Function(T)> watchers = [];

  /// Size of the replay buffer.
  final int _bufferSize;

  /// Queue to store the replay cache.
  final Queue<T> _replayCache;

  /// Creates a MutableWatchable instance with an optional replay buffer size.
  MutableWatchable({int replay = 0})
      : _bufferSize = replay,
        _replayCache = Queue<T>();

  /// Emits a new value to all watchers.
  void emit(T value) {
    if (_bufferSize > 0) {
      _replayCache.addLast(value);
      if (_replayCache.length > _bufferSize) {
        _replayCache.removeFirst();
      }
    }
    for (var subscriber in watchers) {
      subscriber(value);
    }
  }

  /// Adds a watcher function.
  @override
  void watch(Function(T) watcher) {
    watchers.add(watcher);
    if (_bufferSize > 0) {
      for (var value in _replayCache) {
        watcher(value);
      }
    }
  }

  /// Removes a watcher function.
  @override
  void unwatch(Function(T) watcher) {
    watchers.remove(watcher);
  }

  /// Gets the replay cache as an unmodifiable list.
  @override
  List<T> get replayCache => List.unmodifiable(_replayCache);

  /// Disposes the watchable by clearing watchers and replay cache.
  @override
  void dispose() {
    watchers.clear();
    _replayCache.clear();
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
    emit(initial); // Ensure the initial value is in the replay cache
  }

  /// Gets the current value.
  @override
  T get value => _value;

  @override
  void emit(T value) {
    bool hasChanged = false;
    if (compare != null) {
      hasChanged = !compare!(_value, value);
    } else if (_value is List && value is List) {
      hasChanged = !const ListEquality().equals(_value as List, value);
    } else if (_value is Map && value is Map) {
      hasChanged = !const MapEquality().equals(_value as Map, value);
    } else {
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
    widget.onEvent(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
