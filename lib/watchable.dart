import 'package:flutter/widgets.dart';

// ============================================================================
// TYPE ALIASES FOR CONVENIENCE
// ============================================================================

/// Generic watchable alias for shorter syntax
typedef W<T> = Watchable<T>;

/// Int watchable alias
typedef WInt = Watchable<int>;

/// String watchable alias
typedef WString = Watchable<String>;

/// Bool watchable alias
typedef WBool = Watchable<bool>;

/// Double watchable alias
typedef WDouble = Watchable<double>;

/// List watchable alias
typedef WList<T> = Watchable<List<T>>;

/// Map watchable alias
typedef WMap<K, V> = Watchable<Map<K, V>>;

/// Set watchable alias
typedef WSet<T> = Watchable<Set<T>>;

/// Event watchable alias (for event streams)
typedef WEvent<T> = Watchable<T>;

/// A ValueNotifier that can be forced to notify even for identical values
class _ForceNotifyValueNotifier<T> extends ValueNotifier<T> {
  _ForceNotifyValueNotifier(super.value);

  /// Force notify listeners even if value hasn't changed
  void forceNotify() {
    notifyListeners();
  }
}

/// Base interface for all watchable objects
abstract class AbstractWatchable<T> {
  const AbstractWatchable();

  /// Gets the underlying ValueNotifier
  ValueNotifier<T> get notifier;

  /// Gets the current value_
  T get value => notifier.value;

  /// Maps this watchable to another type
  AbstractWatchable<R> map<R>(R Function(T) mapper) =>
      _MappedWatchable(this, mapper);

  /// Filters values based on a predicate+
  AbstractWatchable<T> where(bool Function(T) predicate) =>
      _FilteredWatchable(this, predicate);

  /// Creates distinct values only (removes duplicates)
  AbstractWatchable<T> distinct([bool Function(T, T)? equals]) =>
      _DistinctWatchable(this, equals);
}

/// High-performance reactive state container with direct field storage.
///
/// [Watchable] provides O(1) updates using `identical()` comparison,
/// optimized for immutable state patterns like Redux.
///
/// Example:
/// ```dart
/// final counter = Watchable<int>(0);
/// final name = 'John'.watchable;
///
/// counter.value = 1;  // Direct field access, no Map lookup
/// counter.build((v) => Text('$v'));
/// ```
class Watchable<T> extends AbstractWatchable<T> {
  final _ForceNotifyValueNotifier<T> _notifier;
  bool _alwaysNotify = false;

  Watchable(T initialValue)
      : _notifier = _ForceNotifyValueNotifier<T>(initialValue);

  @override
  @pragma('vm:prefer-inline')
  ValueNotifier<T> get notifier => _notifier;

  @override
  @pragma('vm:prefer-inline')
  T get value => _notifier.value;

  @pragma('vm:prefer-inline')
  set value(T newValue) {
    if (identical(_notifier.value, newValue)) {
      if (_alwaysNotify) _notifier.forceNotify();
      return;
    }
    _notifier.value = newValue;
  }

  void emit(T newValue) => value = newValue;

  /// Configure this watchable to always notify listeners, even when setting identical values
  /// This is useful for cases where you need to trigger updates regardless of value equality
  /// (e.g., refresh operations, forced rebuilds, etc.)
  void alwaysNotify({required bool enabled}) => _alwaysNotify = enabled;

  /// Force emit the current value, triggering all listeners regardless of equality
  /// This is a one-time operation and doesn't change the ongoing notification behavior
  void refresh() => _notifier.forceNotify();

  /// Check if this watchable is configured to always notify on value changes
  bool get isAlwaysNotifying => _alwaysNotify;
}

// ============================================================================
// TRANSFORMATION IMPLEMENTATIONS
// ============================================================================

/// Helper class for shouldRebuild filtering
class _FilteredNotifier<T> extends ValueNotifier<T> {
  final ValueNotifier<T> _source;
  final bool Function(T prev, T curr) _shouldUpdate;

  _FilteredNotifier(this._source, this._shouldUpdate) : super(_source.value) {
    _source.addListener(_onSourceChanged);
  }

  void _onSourceChanged() {
    final newValue = _source.value;
    if (_shouldUpdate(value, newValue)) {
      value = newValue;
    }
  }

  @override
  void dispose() {
    _source.removeListener(_onSourceChanged);
    super.dispose();
  }
}

/// Mapped watchable implementation
class _MappedWatchable<T, R> extends AbstractWatchable<R> {
  final AbstractWatchable<T> _source;
  final R Function(T) _mapper;
  ValueNotifier<R>? _notifier;

  _MappedWatchable(this._source, this._mapper);

  @override
  ValueNotifier<R> get notifier {
    if (_notifier == null) {
      _notifier = ValueNotifier(_mapper(_source.value));
      _source.notifier.addListener(() {
        _notifier!.value = _mapper(_source.value);
      });
    }
    return _notifier!;
  }
}

/// Filtered watchable implementation
class _FilteredWatchable<T> extends AbstractWatchable<T> {
  final AbstractWatchable<T> _source;
  final bool Function(T) _predicate;
  ValueNotifier<T>? _notifier;

  _FilteredWatchable(this._source, this._predicate);

  @override
  ValueNotifier<T> get notifier {
    if (_notifier == null) {
      _notifier = ValueNotifier(_source.value);
      _source.notifier.addListener(() {
        final newValue = _source.value;
        if (_predicate(newValue)) {
          _notifier!.value = newValue;
        }
      });
    }
    return _notifier!;
  }
}

/// Distinct watchable implementation
class _DistinctWatchable<T> extends AbstractWatchable<T> {
  final AbstractWatchable<T> _source;
  final bool Function(T, T)? _equals;
  ValueNotifier<T>? _notifier;

  _DistinctWatchable(this._source, this._equals);

  @override
  ValueNotifier<T> get notifier {
    if (_notifier == null) {
      _notifier = ValueNotifier(_source.value);
      _source.notifier.addListener(() {
        final newValue = _source.value;
        final equals = _equals ?? (a, b) => a == b;
        if (!equals(_notifier!.value, newValue)) {
          _notifier!.value = newValue;
        }
      });
    }
    return _notifier!;
  }
}

/// Combiner for 2 watchables
class WatchableCombined2<A, B, R> extends AbstractWatchable<R> {
  final AbstractWatchable<A> _watchable1;
  final AbstractWatchable<B> _watchable2;
  final R Function(A, B) _combiner;
  ValueNotifier<R>? _notifier;

  WatchableCombined2(this._watchable1, this._watchable2, this._combiner);

  @override
  ValueNotifier<R> get notifier {
    if (_notifier == null) {
      _notifier =
          ValueNotifier(_combiner(_watchable1.value, _watchable2.value));

      void updateCombined() {
        _notifier!.value = _combiner(_watchable1.value, _watchable2.value);
      }

      _watchable1.notifier.addListener(updateCombined);
      _watchable2.notifier.addListener(updateCombined);
    }
    return _notifier!;
  }
}

/// Combiner for 3 watchables
class WatchableCombined3<A, B, C, R> extends AbstractWatchable<R> {
  final AbstractWatchable<A> _watchable1;
  final AbstractWatchable<B> _watchable2;
  final AbstractWatchable<C> _watchable3;
  final R Function(A, B, C) _combiner;
  ValueNotifier<R>? _notifier;

  WatchableCombined3(
      this._watchable1, this._watchable2, this._watchable3, this._combiner);

  @override
  ValueNotifier<R> get notifier {
    if (_notifier == null) {
      _notifier = ValueNotifier(
          _combiner(_watchable1.value, _watchable2.value, _watchable3.value));

      void updateCombined() {
        _notifier!.value =
            _combiner(_watchable1.value, _watchable2.value, _watchable3.value);
      }

      _watchable1.notifier.addListener(updateCombined);
      _watchable2.notifier.addListener(updateCombined);
      _watchable3.notifier.addListener(updateCombined);
    }
    return _notifier!;
  }
}

/// Combiner for 4 watchables
class WatchableCombined4<A, B, C, D, R> extends AbstractWatchable<R> {
  final AbstractWatchable<A> _watchable1;
  final AbstractWatchable<B> _watchable2;
  final AbstractWatchable<C> _watchable3;
  final AbstractWatchable<D> _watchable4;
  final R Function(A, B, C, D) _combiner;
  ValueNotifier<R>? _notifier;

  WatchableCombined4(this._watchable1, this._watchable2, this._watchable3,
      this._watchable4, this._combiner);

  @override
  ValueNotifier<R> get notifier {
    if (_notifier == null) {
      _notifier = ValueNotifier(_combiner(_watchable1.value, _watchable2.value,
          _watchable3.value, _watchable4.value));

      void updateCombined() {
        _notifier!.value = _combiner(_watchable1.value, _watchable2.value,
            _watchable3.value, _watchable4.value);
      }

      _watchable1.notifier.addListener(updateCombined);
      _watchable2.notifier.addListener(updateCombined);
      _watchable3.notifier.addListener(updateCombined);
      _watchable4.notifier.addListener(updateCombined);
    }
    return _notifier!;
  }
}

/// Combiner for 5 watchables
class WatchableCombined5<A, B, C, D, E, R> extends AbstractWatchable<R> {
  final AbstractWatchable<A> _watchable1;
  final AbstractWatchable<B> _watchable2;
  final AbstractWatchable<C> _watchable3;
  final AbstractWatchable<D> _watchable4;
  final AbstractWatchable<E> _watchable5;
  final R Function(A, B, C, D, E) _combiner;
  ValueNotifier<R>? _notifier;

  WatchableCombined5(this._watchable1, this._watchable2, this._watchable3,
      this._watchable4, this._watchable5, this._combiner);

  @override
  ValueNotifier<R> get notifier {
    if (_notifier == null) {
      _notifier = ValueNotifier(_combiner(_watchable1.value, _watchable2.value,
          _watchable3.value, _watchable4.value, _watchable5.value));

      void updateCombined() {
        _notifier!.value = _combiner(_watchable1.value, _watchable2.value,
            _watchable3.value, _watchable4.value, _watchable5.value);
      }

      _watchable1.notifier.addListener(updateCombined);
      _watchable2.notifier.addListener(updateCombined);
      _watchable3.notifier.addListener(updateCombined);
      _watchable4.notifier.addListener(updateCombined);
      _watchable5.notifier.addListener(updateCombined);
    }
    return _notifier!;
  }
}

/// Combiner for 6 watchables
class WatchableCombined6<A, B, C, D, E, F, R> extends AbstractWatchable<R> {
  final AbstractWatchable<A> _watchable1;
  final AbstractWatchable<B> _watchable2;
  final AbstractWatchable<C> _watchable3;
  final AbstractWatchable<D> _watchable4;
  final AbstractWatchable<E> _watchable5;
  final AbstractWatchable<F> _watchable6;
  final R Function(A, B, C, D, E, F) _combiner;
  ValueNotifier<R>? _notifier;

  WatchableCombined6(this._watchable1, this._watchable2, this._watchable3,
      this._watchable4, this._watchable5, this._watchable6, this._combiner);

  @override
  ValueNotifier<R> get notifier {
    if (_notifier == null) {
      _notifier = ValueNotifier(_combiner(
          _watchable1.value,
          _watchable2.value,
          _watchable3.value,
          _watchable4.value,
          _watchable5.value,
          _watchable6.value));

      void updateCombined() {
        _notifier!.value = _combiner(
            _watchable1.value,
            _watchable2.value,
            _watchable3.value,
            _watchable4.value,
            _watchable5.value,
            _watchable6.value);
      }

      _watchable1.notifier.addListener(updateCombined);
      _watchable2.notifier.addListener(updateCombined);
      _watchable3.notifier.addListener(updateCombined);
      _watchable4.notifier.addListener(updateCombined);
      _watchable5.notifier.addListener(updateCombined);
      _watchable6.notifier.addListener(updateCombined);
    }
    return _notifier!;
  }
}

/// Ultra-minimal WatchableBuilder extending ValueListenableBuilder
class WatchableBuilder<T> extends ValueListenableBuilder<T> {
  WatchableBuilder({
    super.key,
    required AbstractWatchable<T> watchable,
    required Widget Function(T value) builder,
    bool Function(T previous, T current)? shouldRebuild,
    super.child,
  }) : super(
          valueListenable: shouldRebuild != null
              ? _FilteredNotifier(watchable.notifier, shouldRebuild)
              : watchable.notifier,
          builder: (context, value, child) => builder(value),
        );

  /// Creates a [WatchableBuilder] from two [AbstractWatchable] instances and a combiner function.
  static WatchableBuilder<R> from2<A, B, R>({
    Key? key,
    required AbstractWatchable<A> watchable1,
    required AbstractWatchable<B> watchable2,
    required R Function(A, B) combiner,
    required Widget Function(R value) builder,
    bool Function(R previous, R current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<R>(
        key: key,
        watchable: WatchableCombined2(watchable1, watchable2, combiner),
        builder: builder,
        shouldRebuild: shouldRebuild,
      );

  /// Creates a [WatchableBuilder] from three [AbstractWatchable] instances and a combiner function.
  static WatchableBuilder<R> from3<A, B, C, R>({
    Key? key,
    required AbstractWatchable<A> watchable1,
    required AbstractWatchable<B> watchable2,
    required AbstractWatchable<C> watchable3,
    required R Function(A, B, C) combiner,
    required Widget Function(R value) builder,
    bool Function(R previous, R current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<R>(
        key: key,
        watchable:
            WatchableCombined3(watchable1, watchable2, watchable3, combiner),
        builder: builder,
        shouldRebuild: shouldRebuild,
      );

  /// Creates a [WatchableBuilder] from four [AbstractWatchable] instances and a combiner function.
  static WatchableBuilder<R> from4<A, B, C, D, R>({
    Key? key,
    required AbstractWatchable<A> watchable1,
    required AbstractWatchable<B> watchable2,
    required AbstractWatchable<C> watchable3,
    required AbstractWatchable<D> watchable4,
    required R Function(A, B, C, D) combiner,
    required Widget Function(R value) builder,
    bool Function(R previous, R current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<R>(
        key: key,
        watchable: WatchableCombined4(
            watchable1, watchable2, watchable3, watchable4, combiner),
        builder: builder,
        shouldRebuild: shouldRebuild,
      );

  /// Creates a [WatchableBuilder] from five [AbstractWatchable] instances and a combiner function.
  static WatchableBuilder<R> from5<A, B, C, D, E, R>({
    Key? key,
    required AbstractWatchable<A> watchable1,
    required AbstractWatchable<B> watchable2,
    required AbstractWatchable<C> watchable3,
    required AbstractWatchable<D> watchable4,
    required AbstractWatchable<E> watchable5,
    required R Function(A, B, C, D, E) combiner,
    required Widget Function(R value) builder,
    bool Function(R previous, R current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<R>(
        key: key,
        watchable: WatchableCombined5(watchable1, watchable2, watchable3,
            watchable4, watchable5, combiner),
        builder: builder,
        shouldRebuild: shouldRebuild,
      );

  /// Creates a [WatchableBuilder] from six [AbstractWatchable] instances and a combiner function.
  static WatchableBuilder<R> from6<A, B, C, D, E, F, R>({
    Key? key,
    required AbstractWatchable<A> watchable1,
    required AbstractWatchable<B> watchable2,
    required AbstractWatchable<C> watchable3,
    required AbstractWatchable<D> watchable4,
    required AbstractWatchable<E> watchable5,
    required AbstractWatchable<F> watchable6,
    required R Function(A, B, C, D, E, F) combiner,
    required Widget Function(R value) builder,
    bool Function(R previous, R current)? shouldRebuild,
    Widget? child,
  }) =>
      WatchableBuilder<R>(
        key: key,
        watchable: WatchableCombined6(watchable1, watchable2, watchable3,
            watchable4, watchable5, watchable6, combiner),
        builder: builder,
        shouldRebuild: shouldRebuild,
      );
}

// ============================================================================
// EXTENSION API - .watchable SYNTAX
// ============================================================================

/// Generic extension on Object to add .watchable functionality
extension WatchableExtension<T extends Object?> on T {
  /// Convert any value to a Watchable
  ///
  /// Usage:
  /// ```dart
  /// final counter = 0.watchable;         // Watchable<int>
  /// final name = 'John'.watchable;       // Watchable<String>
  /// final user = User().watchable;       // Watchable<User>
  /// final items = <String>[].watchable;  // Watchable<List<String>>
  /// ```
  Watchable<T> get watchable => Watchable<T>(this);
}

/// Specialized extension for int with additional convenience methods
extension IntWatchableExtension on int {
  /// Create a watchable int with convenience methods
  Watchable<int> get watchable => Watchable<int>(this);

  /// Create a watchable with range constraints
  Watchable<int> watchableRange(int min, int max) {
    final clamped = clamp(min, max) as int;
    return Watchable<int>(clamped);
  }
}

/// Specialized extension for String with additional convenience methods
extension StringWatchableExtension on String {
  /// Create a watchable string
  Watchable<String> get watchable => Watchable<String>(this);

  /// Create a watchable with max length constraint
  Watchable<String> watchableMaxLength(int maxLength) {
    final truncated = length > maxLength ? substring(0, maxLength) : this;
    return Watchable<String>(truncated);
  }
}

/// Specialized extension for bool with convenience methods
extension BoolWatchableExtension on bool {
  /// Create a watchable bool
  Watchable<bool> get watchable => Watchable<bool>(this);

  /// Create a watchable with initial toggle capability
  Watchable<bool> get watchableToggle => Watchable<bool>(this);
}

/// Specialized extension for double with additional convenience methods
extension DoubleWatchableExtension on double {
  /// Create a watchable double
  Watchable<double> get watchable => Watchable<double>(this);

  /// Create a watchable with range constraints
  Watchable<double> watchableRange(double min, double max) {
    final clamped = clamp(min, max) as double;
    return Watchable<double>(clamped);
  }
}

/// Specialized extension for List with additional convenience methods
extension ListWatchableExtension<T> on List<T> {
  /// Create a watchable list
  Watchable<List<T>> get watchable => Watchable<List<T>>(this);

  /// Create a watchable list that's immutable (creates a copy)
  Watchable<List<T>> get watchableImmutable =>
      Watchable<List<T>>(List.from(this));
}

/// Specialized extension for Map with additional convenience methods
extension MapWatchableExtension<K, V> on Map<K, V> {
  /// Create a watchable map
  Watchable<Map<K, V>> get watchable => Watchable<Map<K, V>>(this);

  /// Create a watchable map that's immutable (creates a copy)
  Watchable<Map<K, V>> get watchableImmutable =>
      Watchable<Map<K, V>>(Map.from(this));
}

/// Specialized extension for Set with additional convenience methods
extension SetWatchableExtension<T> on Set<T> {
  /// Create a watchable set
  Watchable<Set<T>> get watchable => Watchable<Set<T>>(this);

  /// Create a watchable set that's immutable (creates a copy)
  Watchable<Set<T>> get watchableImmutable => Watchable<Set<T>>(Set.from(this));
}

// ============================================================================
// CONVENIENCE EXTENSIONS FOR WATCHABLE INSTANCES
// ============================================================================

/// Extension on Watchable\<int\> for convenient operations
extension WatchableIntExtension on Watchable<int> {
  /// Increment the value
  void increment([int amount = 1]) => value += amount;

  /// Decrement the value
  void decrement([int amount = 1]) => value -= amount;

  /// Reset to zero
  void reset() => value = 0;

  /// Set to absolute value
  void abs() => value = value.abs();

  /// Clamp to range
  void clampRange(int min, int max) => value = value.clamp(min, max);
}

/// Extension on Watchable\<String\> for convenient operations
extension WatchableStringExtension on Watchable<String> {
  /// Clear the string
  void clear() => value = '';

  /// Append text
  void append(String text) => value += text;

  /// Set to uppercase
  void toUpperCase() => value = value.toUpperCase();

  /// Set to lowercase
  void toLowerCase() => value = value.toLowerCase();

  /// Trim whitespace
  void trim() => value = value.trim();

  /// Truncate to max length
  void truncate(int maxLength) {
    if (value.length > maxLength) {
      value = value.substring(0, maxLength);
    }
  }
}

/// Extension on Watchable\<bool\> for convenient operations
extension WatchableBoolExtension on Watchable<bool> {
  /// Toggle the boolean value
  void toggle() => value = !value;

  /// Set to true
  void setTrue() => value = true;

  /// Set to false
  void setFalse() => value = false;
}

/// Extension on Watchable\<List\<T\>\> for convenient operations
extension WatchableListExtension<T> on Watchable<List<T>> {
  /// Add an item
  void add(T item) {
    final newList = List<T>.from(value);
    newList.add(item);
    value = newList;
  }

  /// Remove an item
  void remove(T item) {
    final newList = List<T>.from(value);
    newList.remove(item);
    value = newList;
  }

  /// Clear the list
  void clear() => value = [];

  /// Add multiple items
  void addAll(Iterable<T> items) {
    final newList = List<T>.from(value);
    newList.addAll(items);
    value = newList;
  }

  /// Remove item at index
  void removeAt(int index) {
    final newList = List<T>.from(value);
    if (index >= 0 && index < newList.length) {
      newList.removeAt(index);
      value = newList;
    }
  }

  /// Insert item at index
  void insert(int index, T item) {
    final newList = List<T>.from(value);
    if (index >= 0 && index <= newList.length) {
      newList.insert(index, item);
      value = newList;
    }
  }
}

/// Extension on Watchable\<Map\<K, V\>\> for convenient operations
extension WatchableMapExtension<K, V> on Watchable<Map<K, V>> {
  /// Set a key-value pair
  void set(K key, V val) {
    final newMap = Map<K, V>.from(value);
    newMap[key] = val;
    value = newMap;
  }

  /// Remove a key
  void removeKey(K key) {
    final newMap = Map<K, V>.from(value);
    newMap.remove(key);
    value = newMap;
  }

  /// Clear the map
  void clear() => value = {};

  /// Add all entries from another map
  void addAll(Map<K, V> other) {
    final newMap = Map<K, V>.from(value);
    newMap.addAll(other);
    value = newMap;
  }
}

/// Extension on Watchable\<Map\<String, bool\>\> for boolean flag operations
extension WatchableBoolMapExtension on Watchable<Map<String, bool>> {
  /// Toggle a boolean flag
  void toggle(String key) {
    final newMap = Map<String, bool>.from(value);
    newMap[key] = !(newMap[key] ?? false);
    value = newMap;
  }

  /// Add a boolean flag
  void add(String key, bool val) {
    set(key, val);
  }
}

/// Extension on Watchable\<Set\<T\>\> for convenient operations
extension WatchableSetExtension<T> on Watchable<Set<T>> {
  /// Add an item
  void add(T item) {
    final newSet = Set<T>.from(value);
    newSet.add(item);
    value = newSet;
  }

  /// Remove an item
  void remove(T item) {
    final newSet = Set<T>.from(value);
    newSet.remove(item);
    value = newSet;
  }

  /// Clear the set
  void clear() => value = <T>{};

  /// Add multiple items
  void addAll(Iterable<T> items) {
    final newSet = Set<T>.from(value);
    newSet.addAll(items);
    value = newSet;
  }

  /// Check if contains item
  bool contains(T item) => value.contains(item);

  /// Get set length
  int get length => value.length;

  /// Check if empty
  bool get isEmpty => value.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => value.isNotEmpty;
}

// ============================================================================
// SHORTHAND WIDGET BUILDING EXTENSIONS
// ============================================================================

/// Extension to add .build() method to AbstractWatchable for direct UI building
extension WatchableBuildExtension<T> on AbstractWatchable<T> {
  /// Build a widget directly from this watchable
  ///
  /// Usage:
  /// ```dart
  /// final counter = 0.watchable;
  /// counter.build((count) => Text('$count'))
  /// ```
  Widget build(
    Widget Function(T value) builder, {
    bool Function(T previous, T current)? shouldRebuild,
  }) {
    return WatchableBuilder<T>(
      watchable: this,
      builder: builder,
      shouldRebuild: shouldRebuild,
    );
  }
}

// ============================================================================
// TUPLE EXTENSIONS FOR RECORDS (DART 3.0)
// ============================================================================

/// Extension on 2-tuple of watchables for convenient combining
extension Tuple2WatchableExtension<A, B> on (
  AbstractWatchable<A>,
  AbstractWatchable<B>
) {
  /// Build UI from two watchables using tuple syntax
  ///
  /// Usage:
  /// ```dart
  /// (email, password).build((e, p) =>
  ///   ElevatedButton(
  ///     onPressed: isValid(e, p) ? submit : null,
  ///     child: Text('Submit'),
  ///   )
  /// )
  /// ```
  Widget build(
    Widget Function(A, B) builder, {
    bool Function((A, B) previous, (A, B) current)? shouldRebuild,
  }) {
    return WatchableBuilder.from2(
      watchable1: $1,
      watchable2: $2,
      combiner: (a, b) => (a, b),
      builder: (value) => builder(value.$1, value.$2),
      shouldRebuild: shouldRebuild,
    );
  }

  /// Combine two watchables into one using tuple syntax
  ///
  /// Usage:
  /// ```dart
  /// final fullName = (firstName, lastName).combine((f, l) => '$f $l');
  /// ```
  AbstractWatchable<R> combine<R>(R Function(A, B) combiner) {
    return WatchableCombined2($1, $2, combiner);
  }
}

/// Extension on 3-tuple of watchables for convenient combining
extension Tuple3WatchableExtension<A, B, C> on (
  AbstractWatchable<A>,
  AbstractWatchable<B>,
  AbstractWatchable<C>
) {
  /// Build UI from three watchables using tuple syntax
  Widget build(
    Widget Function(A, B, C) builder, {
    bool Function((A, B, C) previous, (A, B, C) current)? shouldRebuild,
  }) {
    return WatchableBuilder.from3(
      watchable1: $1,
      watchable2: $2,
      watchable3: $3,
      combiner: (a, b, c) => (a, b, c),
      builder: (value) => builder(value.$1, value.$2, value.$3),
      shouldRebuild: shouldRebuild,
    );
  }

  /// Combine three watchables into one using tuple syntax
  AbstractWatchable<R> combine<R>(R Function(A, B, C) combiner) {
    return WatchableCombined3($1, $2, $3, combiner);
  }
}

/// Extension on 4-tuple of watchables for convenient combining
extension Tuple4WatchableExtension<A, B, C, D> on (
  AbstractWatchable<A>,
  AbstractWatchable<B>,
  AbstractWatchable<C>,
  AbstractWatchable<D>
) {
  /// Build UI from four watchables using tuple syntax
  Widget build(
    Widget Function(A, B, C, D) builder, {
    bool Function((A, B, C, D) previous, (A, B, C, D) current)? shouldRebuild,
  }) {
    return WatchableBuilder.from4(
      watchable1: $1,
      watchable2: $2,
      watchable3: $3,
      watchable4: $4,
      combiner: (a, b, c, d) => (a, b, c, d),
      builder: (value) => builder(value.$1, value.$2, value.$3, value.$4),
      shouldRebuild: shouldRebuild,
    );
  }

  /// Combine four watchables into one using tuple syntax
  AbstractWatchable<R> combine<R>(R Function(A, B, C, D) combiner) {
    return WatchableCombined4($1, $2, $3, $4, combiner);
  }
}

/// Extension on 5-tuple of watchables for convenient combining
extension Tuple5WatchableExtension<A, B, C, D, E> on (
  AbstractWatchable<A>,
  AbstractWatchable<B>,
  AbstractWatchable<C>,
  AbstractWatchable<D>,
  AbstractWatchable<E>
) {
  /// Build UI from five watchables using tuple syntax
  Widget build(
    Widget Function(A, B, C, D, E) builder, {
    bool Function((A, B, C, D, E) previous, (A, B, C, D, E) current)?
        shouldRebuild,
  }) {
    return WatchableBuilder.from5(
      watchable1: $1,
      watchable2: $2,
      watchable3: $3,
      watchable4: $4,
      watchable5: $5,
      combiner: (a, b, c, d, e) => (a, b, c, d, e),
      builder: (value) =>
          builder(value.$1, value.$2, value.$3, value.$4, value.$5),
      shouldRebuild: shouldRebuild,
    );
  }

  /// Combine five watchables into one using tuple syntax
  AbstractWatchable<R> combine<R>(R Function(A, B, C, D, E) combiner) {
    return WatchableCombined5($1, $2, $3, $4, $5, combiner);
  }
}

/// Extension on 6-tuple of watchables for convenient combining
extension Tuple6WatchableExtension<A, B, C, D, E, F> on (
  AbstractWatchable<A>,
  AbstractWatchable<B>,
  AbstractWatchable<C>,
  AbstractWatchable<D>,
  AbstractWatchable<E>,
  AbstractWatchable<F>
) {
  /// Build UI from six watchables using tuple syntax
  Widget build(
    Widget Function(A, B, C, D, E, F) builder, {
    bool Function((A, B, C, D, E, F) previous, (A, B, C, D, E, F) current)?
        shouldRebuild,
  }) {
    return WatchableBuilder.from6(
      watchable1: $1,
      watchable2: $2,
      watchable3: $3,
      watchable4: $4,
      watchable5: $5,
      watchable6: $6,
      combiner: (a, b, c, d, e, f) => (a, b, c, d, e, f),
      builder: (value) =>
          builder(value.$1, value.$2, value.$3, value.$4, value.$5, value.$6),
      shouldRebuild: shouldRebuild,
    );
  }

  /// Combine six watchables into one using tuple syntax
  AbstractWatchable<R> combine<R>(R Function(A, B, C, D, E, F) combiner) {
    return WatchableCombined6($1, $2, $3, $4, $5, $6, combiner);
  }
}

// ============================================================================
// WATCH UTILITY CLASS
// ============================================================================

/// Utility class providing static methods for watchable operations
///
/// Alternative to tuple syntax for combining multiple watchables
class Watch {
  Watch._(); // Private constructor to prevent instantiation

  // ========== BUILD METHODS ==========

  /// Build UI from two watchables
  ///
  /// Usage:
  /// ```dart
  /// Watch.build2(email, password, (e, p) =>
  ///   ElevatedButton(
  ///     onPressed: isValid(e, p) ? submit : null,
  ///     child: Text('Submit'),
  ///   )
  /// )
  /// ```
  static Widget build2<A, B>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    Widget Function(A, B) builder,
  ) {
    return WatchableBuilder.from2(
      watchable1: watchable1,
      watchable2: watchable2,
      combiner: (a, b) => (a, b),
      builder: (value) => builder(value.$1, value.$2),
    );
  }

  /// Build UI from three watchables
  static Widget build3<A, B, C>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    AbstractWatchable<C> watchable3,
    Widget Function(A, B, C) builder,
  ) {
    return WatchableBuilder.from3(
      watchable1: watchable1,
      watchable2: watchable2,
      watchable3: watchable3,
      combiner: (a, b, c) => (a, b, c),
      builder: (value) => builder(value.$1, value.$2, value.$3),
    );
  }

  /// Build UI from four watchables
  static Widget build4<A, B, C, D>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    AbstractWatchable<C> watchable3,
    AbstractWatchable<D> watchable4,
    Widget Function(A, B, C, D) builder,
  ) {
    return WatchableBuilder.from4(
      watchable1: watchable1,
      watchable2: watchable2,
      watchable3: watchable3,
      watchable4: watchable4,
      combiner: (a, b, c, d) => (a, b, c, d),
      builder: (value) => builder(value.$1, value.$2, value.$3, value.$4),
    );
  }

  /// Build UI from five watchables
  static Widget build5<A, B, C, D, E>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    AbstractWatchable<C> watchable3,
    AbstractWatchable<D> watchable4,
    AbstractWatchable<E> watchable5,
    Widget Function(A, B, C, D, E) builder,
  ) {
    return WatchableBuilder.from5(
      watchable1: watchable1,
      watchable2: watchable2,
      watchable3: watchable3,
      watchable4: watchable4,
      watchable5: watchable5,
      combiner: (a, b, c, d, e) => (a, b, c, d, e),
      builder: (value) =>
          builder(value.$1, value.$2, value.$3, value.$4, value.$5),
    );
  }

  /// Build UI from six watchables
  static Widget build6<A, B, C, D, E, F>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    AbstractWatchable<C> watchable3,
    AbstractWatchable<D> watchable4,
    AbstractWatchable<E> watchable5,
    AbstractWatchable<F> watchable6,
    Widget Function(A, B, C, D, E, F) builder,
  ) {
    return WatchableBuilder.from6(
      watchable1: watchable1,
      watchable2: watchable2,
      watchable3: watchable3,
      watchable4: watchable4,
      watchable5: watchable5,
      watchable6: watchable6,
      combiner: (a, b, c, d, e, f) => (a, b, c, d, e, f),
      builder: (value) =>
          builder(value.$1, value.$2, value.$3, value.$4, value.$5, value.$6),
    );
  }

  // ========== COMBINE METHODS ==========

  /// Combine two watchables into one
  ///
  /// Usage:
  /// ```dart
  /// final fullName = Watch.combine2(firstName, lastName, (f, l) => '$f $l');
  /// ```
  static AbstractWatchable<R> combine2<A, B, R>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    R Function(A, B) combiner,
  ) {
    return WatchableCombined2(watchable1, watchable2, combiner);
  }

  /// Combine three watchables into one
  static AbstractWatchable<R> combine3<A, B, C, R>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    AbstractWatchable<C> watchable3,
    R Function(A, B, C) combiner,
  ) {
    return WatchableCombined3(watchable1, watchable2, watchable3, combiner);
  }

  /// Combine four watchables into one
  static AbstractWatchable<R> combine4<A, B, C, D, R>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    AbstractWatchable<C> watchable3,
    AbstractWatchable<D> watchable4,
    R Function(A, B, C, D) combiner,
  ) {
    return WatchableCombined4(
        watchable1, watchable2, watchable3, watchable4, combiner);
  }

  /// Combine five watchables into one
  static AbstractWatchable<R> combine5<A, B, C, D, E, R>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    AbstractWatchable<C> watchable3,
    AbstractWatchable<D> watchable4,
    AbstractWatchable<E> watchable5,
    R Function(A, B, C, D, E) combiner,
  ) {
    return WatchableCombined5(
        watchable1, watchable2, watchable3, watchable4, watchable5, combiner);
  }

  /// Combine six watchables into one
  static AbstractWatchable<R> combine6<A, B, C, D, E, F, R>(
    AbstractWatchable<A> watchable1,
    AbstractWatchable<B> watchable2,
    AbstractWatchable<C> watchable3,
    AbstractWatchable<D> watchable4,
    AbstractWatchable<E> watchable5,
    AbstractWatchable<F> watchable6,
    R Function(A, B, C, D, E, F) combiner,
  ) {
    return WatchableCombined6(watchable1, watchable2, watchable3, watchable4,
        watchable5, watchable6, combiner);
  }
}
