library watchable;

import 'package:flutter/widgets.dart';

/// A class that holds a value of type [T] and notifies listeners when the value changes.
class Watchable<T> extends ChangeNotifier {
  T _value;
  final T initial;

  /// Creates a [Watchable] with an initial value.
  Watchable(this.initial) : _value = initial;

  /// Gets the current value.
  T get value => _value;

  /// Sets a new value and notifies listeners if the value has changed.
  set value(T newValue) {
    if (newValue != _value) {
      _value = newValue;
      notifyListeners();
    }
  }

  /// Resets the value to the initial value.
  void reset() {
    value = initial;
  }
}

/// A class that combines multiple [Watchable] instances into one, using a combiner function.
class _CombineLatestWatchable<T, R> extends Watchable<R> {
  /// Creates a [_CombineLatestWatchable] from a list of [Watchable] instances and a combiner function.
  _CombineLatestWatchable(
    Iterable<Watchable<T>> watchableList,
    R Function(List<T> values) combiner,
  ) : super(_initialValue(watchableList, combiner)) {
    for (final watchable in watchableList) {
      watchable.addListener(() {
        value = combiner(watchableList.map((b) => b.value).toList());
      });
    }
  }

  /// Computes the initial value using the combiner function.
  static R _initialValue<T, R>(
      Iterable<Watchable<T>> watchableList, R Function(List<T>) combiner) {
    if (watchableList.isEmpty) {
      throw ArgumentError('watchableList cannot be empty');
    }
    return combiner(watchableList.map((b) => b.value).toList());
  }
}

typedef WatchableWidgetBuilder<T> = Widget Function(
    BuildContext context, T value, Widget? child);

class _WatchableBuilderState<T> extends State<WatchableBuilder<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.watchable.value;
    widget.watchable.addListener(_handleValueChanged);
  }

  @override
  void didUpdateWidget(WatchableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.watchable != widget.watchable) {
      oldWidget.watchable.removeListener(_handleValueChanged);
      _value = widget.watchable.value;
      widget.watchable.addListener(_handleValueChanged);
    }
  }

  @override
  void dispose() {
    widget.watchable.removeListener(_handleValueChanged);
    super.dispose();
  }

  void _handleValueChanged() {
    final newValue = widget.watchable.value;
    if (widget.shouldRebuild?.call(_value, newValue) ?? _value != newValue) {
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

/// A widget that rebuilds when the value of a [Watchable] changes.
class WatchableBuilder<T> extends StatefulWidget {
  final Watchable<T> watchable;
  final WatchableWidgetBuilder<T> builder;
  final Widget? child;
  final bool Function(T previous, T current)? shouldRebuild;

  /// Creates a [WatchableBuilder] with the given [Watchable] and builder function.
  const WatchableBuilder({
    super.key,
    required this.watchable,
    required this.builder,
    this.child,
    this.shouldRebuild,
  });

  @override
  State<WatchableBuilder<T>> createState() => _WatchableBuilderState<T>();

  /// Creates a [WatchableBuilder] from a list of [Watchable] instances and a combiner function.
  static WatchableBuilder fromList<T>({
    Key? key,
    required List<Watchable<T>> watchableList,
    required T Function(List values) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatestWatchable(
            watchableList, (values) => combiner(values)),
        builder: builder,
      );

  /// Creates a [WatchableBuilder] from two [Watchable] instances and a combiner function.
  static WatchableBuilder from2<A, B, T>({
    Key? key,
    required Watchable<A> watchable1,
    required Watchable<B> watchable2,
    required T Function(A first, B second) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatestWatchable([watchable1, watchable2],
            (values) => combiner(values[0] as A, values[1] as B)),
        builder: builder,
      );

  /// Creates a [WatchableBuilder] from three [Watchable] instances and a combiner function.
  static WatchableBuilder from3<A, B, C, T>({
    Key? key,
    required Watchable<A> watchable1,
    required Watchable<B> watchable2,
    required Watchable<C> watchable3,
    required T Function(A first, B second, C third) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatestWatchable(
            [watchable1, watchable2, watchable3],
            (values) =>
                combiner(values[0] as A, values[1] as B, values[2] as C)),
        builder: builder,
      );

  /// Creates a [WatchableBuilder] from four [Watchable] instances and a combiner function.
  static WatchableBuilder from4<A, B, C, D, T>({
    Key? key,
    required Watchable<A> watchable1,
    required Watchable<B> watchable2,
    required Watchable<C> watchable3,
    required Watchable<D> watchable4,
    required T Function(A first, B second, C third, D fourth) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatestWatchable(
            [watchable1, watchable2, watchable3, watchable4],
            (values) => combiner(values[0] as A, values[1] as B, values[2] as C,
                values[3] as D)),
        builder: builder,
      );

  /// Creates a [WatchableBuilder] from five [Watchable] instances and a combiner function.
  static WatchableBuilder from5<A, B, C, D, E, T>({
    Key? key,
    required Watchable<A> watchable1,
    required Watchable<B> watchable2,
    required Watchable<C> watchable3,
    required Watchable<D> watchable4,
    required Watchable<E> watchable5,
    required T Function(A first, B second, C third, D fourth, E fifth) combiner,
    required WatchableWidgetBuilder<T> builder,
    bool Function(T previous, T current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<T>(
        shouldRebuild: shouldRebuild,
        watchable: _CombineLatestWatchable(
            [watchable1, watchable2, watchable3, watchable4, watchable5],
            (values) => combiner(values[0] as A, values[1] as B, values[2] as C,
                values[3] as D, values[4] as E)),
        builder: builder,
      );
}
