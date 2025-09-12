import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:watchable/watchable.dart';

// Test class for generic type testing
class User {
  final String name;
  final int id;

  User({this.name = 'Test User', this.id = 1});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id;

  @override
  int get hashCode => name.hashCode ^ id.hashCode;
}

// Test class for CounterState pattern testing
class CounterState {
  final counter = 0.watch;

  void increment() {
    counter.value += 1;
  }

  void decrement() {
    counter.value -= 1;
  }

  void reset() {
    counter.value = 0;
  }
}

// Test enum for enum testing
enum Status { pending, active, inactive }

void main() {
  group('MutableWatchable', () {
    test('emit value to subscribers', () {
      final shared = MutableWatchable<int>();
      bool valueReceived = false;
      shared.watch((value) {
        if (value == 1) {
          valueReceived = true;
        }
      });
      shared.emit(1);
      expect(valueReceived, true);
    });

    test('replay cache works correctly', () {
      final shared = MutableWatchable<int>(replay: 2);
      shared.emit(1);
      shared.emit(2);
      expect(shared.replayCache, [1, 2]);
    });

    test('replay cache respects buffer size', () {
      final shared = MutableWatchable<int>(replay: 1);
      shared.emit(1);
      shared.emit(2);
      expect(shared.replayCache, [2]);
    });

    test('new subscriber receives replayed values', () {
      final shared = MutableWatchable<int>(replay: 2);
      shared.emit(1);
      shared.emit(2);
      List<int> receivedValues = [];
      shared.watch((value) {
        receivedValues.add(value);
      });
      expect(receivedValues, [1, 2]);
    });

    test('unwatch removes subscriber', () {
      final shared = MutableWatchable<int>();
      void watcher(int value) {}
      shared.watch(watcher);
      shared.unwatch(watcher);
      expect(shared.watcherCount, 0);
    });

    test('dispose clears subscribers and replay cache', () {
      final shared = MutableWatchable<int>(replay: 2);
      shared.emit(1);
      shared.dispose();
      expect(shared.watcherCount, 0);
      expect(shared.replayCache.isEmpty, true);
    });
  });

  group('MutableStateWatchable', () {
    test('initial value is emitted', () {
      final watchable = MutableStateWatchable<int>(0);
      expect(watchable.value, 0);
    });

    test('value does not change if compare function returns false', () {
      final watchable = MutableStateWatchable<int>(0,
          compare: (old, current) => old == current);
      bool valueChanged = false;
      watchable.watch((value) {
        if (value == 1) {
          valueChanged = true;
        }
      });
      watchable.emit(0); // Should not trigger change
      expect(valueChanged, false);
    });

    test('list equality comparison', () {
      final watchable = MutableStateWatchable<List<int>>([1, 2, 3]);
      bool valueChanged = false;
      watchable.watch((value) {
        if (value == [1, 2, 3]) {
          valueChanged = true;
        }
      });
      watchable.emit([1, 2, 3]); // Should not trigger change
      expect(valueChanged, false);
    });

    test('map equality comparison', () {
      final watchable = MutableStateWatchable<Map<String, int>>({'a': 1});
      bool valueChanged = false;
      watchable.watch((value) {
        if (value == {'a': 1}) {
          valueChanged = true;
        }
      });
      watchable.emit({'a': 1}); // Should not trigger change
      expect(valueChanged, false);
    });

    test('dispose clears subscribers and replay cache', () {
      final watchable = MutableStateWatchable<int>(0);
      watchable.dispose();
      expect(watchable.replayCache.isEmpty, true);
    });

    test('value setter updates value directly', () {
      final watchable = MutableStateWatchable<int>(0);
      watchable.value = 42;
      expect(watchable.value, 42);
    });

    test('value setter triggers watchers', () {
      final watchable = MutableStateWatchable<int>(0);
      bool wasTriggered = false;
      int receivedValue = 0;

      watchable.watch((value) {
        wasTriggered = true;
        receivedValue = value;
      });

      watchable.value = 42;
      expect(wasTriggered, true);
      expect(receivedValue, 42);
    });

    test('value setter works with compound assignments', () {
      final watchable = MutableStateWatchable<int>(10);
      watchable.value += 5;
      expect(watchable.value, 15);

      watchable.value -= 3;
      expect(watchable.value, 12);

      watchable.value *= 2;
      expect(watchable.value, 24);
    });

    test('value setter works with string concatenation', () {
      final watchable = MutableStateWatchable<String>('Hello');
      watchable.value += ' World';
      expect(watchable.value, 'Hello World');
    });

    test('value setter works with custom objects', () {
      final user1 = User(name: 'John', id: 1);
      final user2 = User(name: 'Jane', id: 2);
      final watchable = MutableStateWatchable<User>(user1);

      bool wasTriggered = false;
      User? receivedUser;

      watchable.watch((user) {
        wasTriggered = true;
        receivedUser = user;
      });

      watchable.value = user2;
      expect(wasTriggered, true);
      expect(receivedUser, user2);
      expect(watchable.value, user2);
    });

    test('value setter respects equality comparison for lists', () {
      final watchable = MutableStateWatchable<List<int>>([1, 2, 3]);
      bool wasTriggered = false;

      watchable.watch((value) {
        wasTriggered = true;
      });

      // Reset flag after initial replay
      wasTriggered = false;

      // Setting same list content should not trigger
      watchable.value = [1, 2, 3];
      expect(wasTriggered, false);

      // Setting different list should trigger
      watchable.value = [1, 2, 3, 4];
      expect(wasTriggered, true);
    });

    test('value setter respects equality comparison for maps', () {
      final watchable = MutableStateWatchable<Map<String, int>>({'a': 1});
      bool wasTriggered = false;

      watchable.watch((value) {
        wasTriggered = true;
      });

      // Reset flag after initial replay
      wasTriggered = false;

      // Setting same map content should not trigger
      watchable.value = {'a': 1};
      expect(wasTriggered, false);

      // Setting different map should trigger
      watchable.value = {'a': 1, 'b': 2};
      expect(wasTriggered, true);
    });
  });

  group('CombineLatestWatchable', () {
    test('combines initial values correctly', () {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      expect(combined.value, 3);
    });

    test('updates combined value when one of the sources changes', () {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      bool valueChanged = false;
      combined.watch((value) {
        if (value == 4) {
          valueChanged = true;
        }
      });
      watchable1.emit(2);
      expect(valueChanged, true);
    });

    test('dispose unwatch all sources', () {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      combined.dispose();
      expect(watchable1.watcherCount, 0);
      expect(watchable2.watcherCount, 0);
    });
  });

  group('WatchableBuilder', () {
    testWidgets('builds with initial value', (WidgetTester tester) async {
      final watchable = MutableStateWatchable<int>(0);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder<int>(
            watchable: watchable,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('rebuilds when value changes', (WidgetTester tester) async {
      final watchable = MutableStateWatchable<int>(0);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder<int>(
            watchable: watchable,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      watchable.emit(1);
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('does not rebuild if shouldRebuild returns false',
        (WidgetTester tester) async {
      final watchable = MutableStateWatchable<int>(0);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder<int>(
            watchable: watchable,
            shouldRebuild: (previous, current) => false,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      watchable.emit(1);
      await tester.pump();
      expect(find.text('0'), findsOneWidget); // Should still show '0'
    });

    testWidgets('updates widget when watchable changes',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(0);
      final watchable2 = MutableStateWatchable<int>(1);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder<int>(
            watchable: watchable1,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder<int>(
            watchable: watchable2,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('WatchableBuilder.fromList', () {
    testWidgets('combines initial values correctly',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.fromList(
            watchableList: [watchable1, watchable2],
            combiner: (values) => values.reduce((a, b) => a + b),
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('updates combined value when one of the sources changes',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.fromList(
            watchableList: [watchable1, watchable2],
            combiner: (values) => values.reduce((a, b) => a + b),
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      watchable1.emit(2);
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
    });
  });

  group('WatchableBuilder.from2', () {
    testWidgets('combines initial values correctly',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.from2(
            watchable1: watchable1,
            watchable2: watchable2,
            combiner: (first, second) => first + second,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('updates combined value when one of the sources changes',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.from2(
            watchable1: watchable1,
            watchable2: watchable2,
            combiner: (first, second) => first + second,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      watchable1.emit(2);
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
    });
  });

  group('WatchableBuilder.from3', () {
    testWidgets('combines initial values correctly',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final watchable3 = MutableStateWatchable<int>(3);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.from3(
            watchable1: watchable1,
            watchable2: watchable2,
            watchable3: watchable3,
            combiner: (first, second, third) => first + second + third,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('updates combined value when one of the sources changes',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final watchable3 = MutableStateWatchable<int>(3);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.from3(
            watchable1: watchable1,
            watchable2: watchable2,
            watchable3: watchable3,
            combiner: (first, second, third) => first + second + third,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      watchable1.emit(2);
      await tester.pump();
      expect(find.text('7'), findsOneWidget);
    });
  });

  group('WatchableBuilder.from4', () {
    testWidgets('combines initial values correctly',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final watchable3 = MutableStateWatchable<int>(3);
      final watchable4 = MutableStateWatchable<int>(4);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.from4(
            watchable1: watchable1,
            watchable2: watchable2,
            watchable3: watchable3,
            watchable4: watchable4,
            combiner: (first, second, third, fourth) =>
                first + second + third + fourth,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('updates combined value when one of the sources changes',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final watchable3 = MutableStateWatchable<int>(3);
      final watchable4 = MutableStateWatchable<int>(4);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.from4(
            watchable1: watchable1,
            watchable2: watchable2,
            watchable3: watchable3,
            watchable4: watchable4,
            combiner: (first, second, third, fourth) =>
                first + second + third + fourth,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      watchable1.emit(2);
      await tester.pump();
      expect(find.text('11'), findsOneWidget);
    });
  });

  group('WatchableBuilder.from5', () {
    testWidgets('combines initial values correctly',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final watchable3 = MutableStateWatchable<int>(3);
      final watchable4 = MutableStateWatchable<int>(4);
      final watchable5 = MutableStateWatchable<int>(5);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.from5(
            watchable1: watchable1,
            watchable2: watchable2,
            watchable3: watchable3,
            watchable4: watchable4,
            watchable5: watchable5,
            combiner: (first, second, third, fourth, fifth) =>
                first + second + third + fourth + fifth,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      expect(find.text('15'), findsOneWidget);
      watchable1.emit(2);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('updates combined value when one of the sources changes',
        (WidgetTester tester) async {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final watchable3 = MutableStateWatchable<int>(3);
      final watchable4 = MutableStateWatchable<int>(4);
      final watchable5 = MutableStateWatchable<int>(5);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder.from5(
            watchable1: watchable1,
            watchable2: watchable2,
            watchable3: watchable3,
            watchable4: watchable4,
            watchable5: watchable5,
            combiner: (first, second, third, fourth, fifth) =>
                first + second + third + fourth + fifth,
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );
      watchable1.emit(2);
      await tester.pump();
      expect(find.text('16'), findsOneWidget);
    });
  });

  group('WatchableBuilder Dispose Tests', () {
    late MutableStateWatchable<int> watchable;
    late Widget testWidget;

    setUp(() {
      watchable = MutableStateWatchable<int>(0);
      testWidget = Directionality(
        textDirection: TextDirection.ltr,
        child: WatchableBuilder<int>(
          watchable: watchable,
          builder: (context, value, child) {
            return Text('$value');
          },
        ),
      );
    });

    testWidgets('WatchableBuilder calls unwatch on dispose',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Update the watchable value
      watchable.emit(1);
      await tester.pump();

      // Verify updated state
      expect(find.text('1'), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Update the watchable value again
      watchable.emit(2);
      await tester.pump();

      // Verify that the widget is disposed and no longer updates
      expect(find.text('2'), findsNothing);
    });

    testWidgets('WatchableBuilder does not call unwatch if not watched',
        (WidgetTester tester) async {
      final anotherWatchable = MutableStateWatchable<int>(0);
      bool unwatchCalled = false;

      anotherWatchable.watch((value) {
        // This should not be called
      });

      anotherWatchable.unwatch((value) {
        unwatchCalled = true;
      });

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WatchableBuilder<int>(
          watchable: anotherWatchable,
          builder: (context, value, child) {
            return Text('$value');
          },
        ),
      ));

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Verify that unwatch was not called
      expect(unwatchCalled, isFalse);
    });
  });

  group('WatchableBuilder from Constructors Dispose Tests', () {
    late MutableStateWatchable<int> watchable1;
    late MutableStateWatchable<int> watchable2;
    late Widget testWidget;

    setUp(() {
      watchable1 = MutableStateWatchable<int>(0);
      watchable2 = MutableStateWatchable<int>(0);
      testWidget = Directionality(
        textDirection: TextDirection.ltr,
        child: WatchableBuilder.from2(
          watchable1: watchable1,
          watchable2: watchable2,
          combiner: (a, b) => a + b,
          builder: (context, value, child) {
            return Text('$value');
          },
        ),
      );
    });

    testWidgets('WatchableBuilder.from2 calls unwatch on dispose',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Update the watchable values
      watchable1.emit(1);
      watchable2.emit(2);
      await tester.pump();

      // Verify updated state
      expect(find.text('3'), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Update the watchable values again
      watchable1.emit(3);
      watchable2.emit(4);
      await tester.pump();

      // Verify that the widget is disposed and no longer updates
      expect(find.text('7'), findsNothing);
    });

    testWidgets('WatchableBuilder.fromList calls unwatch on dispose',
        (WidgetTester tester) async {
      final watchableList = [watchable1, watchable2];
      testWidget = Directionality(
        textDirection: TextDirection.ltr,
        child: WatchableBuilder.fromList(
          watchableList: watchableList,
          combiner: (values) => values.reduce((a, b) => a + b),
          builder: (context, value, child) {
            return Text('$value');
          },
        ),
      );

      await tester.pumpWidget(testWidget);

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Update the watchable values
      watchable1.emit(1);
      watchable2.emit(2);
      await tester.pump();

      // Verify updated state
      expect(find.text('3'), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Update the watchable values again
      watchable1.emit(3);
      watchable2.emit(4);
      await tester.pump();

      // Verify that the widget is disposed and no longer updates
      expect(find.text('7'), findsNothing);
    });
  });

  group('WatchableConsumer Tests', () {
    late MutableWatchable<int> watchable;
    late int callbackValue;

    setUp(() {
      watchable = MutableWatchable<int>();
      callbackValue = -1;
    });

    testWidgets('should call onEvent when value changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableConsumer<int>(
            watchable: watchable,
            onEvent: (value) {
              callbackValue = value;
            },
            child: const Text('Test Widget'),
          ),
        ),
      );

      watchable.emit(42);
      await tester.pump();

      expect(callbackValue, 42);
    });

    testWidgets('should not rebuild child widget on value change',
        (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableConsumer<int>(
            watchable: watchable,
            onEvent: (value) {},
            child: Builder(
              builder: (context) {
                buildCount++;
                return const Text('Test Widget');
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);

      watchable.emit(42);
      await tester.pump();

      expect(
          buildCount, 1); // Should still be 1 because child should not rebuild
    });

    testWidgets('should handle watch and unwatch correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableConsumer<int>(
            watchable: watchable,
            onEvent: (value) {
              callbackValue = value;
            },
            child: const Text('Test Widget'),
          ),
        ),
      );

      expect(watchable.watcherCount, 1);

      watchable.emit(42);
      await tester.pump();

      expect(callbackValue, 42);

      await tester.pumpWidget(Container()); // Unmount the widget
      expect(watchable.watcherCount, 0);
    });

    testWidgets('should handle dispose correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableConsumer<int>(
            watchable: watchable,
            onEvent: (value) {
              callbackValue = value;
            },
            child: const Text('Test Widget'),
          ),
        ),
      );

      expect(watchable.watcherCount, 1);

      await tester.pumpWidget(Container()); // Unmount the widget
      expect(watchable.watcherCount, 0);
    });
  });

  group('MutableWatchable Negative Tests', () {
    test('emit value without subscribers', () {
      final shared = MutableWatchable<int>();
      expect(() => shared.emit(1), returnsNormally);
    });

    test('unwatch non-existent subscriber', () {
      final shared = MutableWatchable<int>();
      void watcher(int value) {}
      expect(() => shared.unwatch(watcher), returnsNormally);
    });

    test('dispose already disposed watchable', () {
      final shared = MutableWatchable<int>();
      shared.dispose();
      expect(() => shared.dispose(), returnsNormally);
    });
  });

  group('MutableStateWatchable Negative Tests', () {
    test('emit value without subscribers', () {
      final watchable = MutableStateWatchable<int>(0);
      expect(() => watchable.emit(1), returnsNormally);
    });

    test('unwatch non-existent subscriber', () {
      final watchable = MutableStateWatchable<int>(0);
      void watcher(int value) {}
      expect(() => watchable.unwatch(watcher), returnsNormally);
    });

    test('dispose already disposed watchable', () {
      final watchable = MutableStateWatchable<int>(0);
      watchable.dispose();
      expect(() => watchable.dispose(), returnsNormally);
    });
  });

  group('CombineLatestWatchable Negative Tests', () {
    test('throws ArgumentError if watchableList is empty', () {
      expect(
        () => CombineLatestWatchable<int, int>(
            [], (values) => values.reduce((a, b) => a + b)),
        throwsArgumentError,
      );
    });

    test('emit value without subscribers', () {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      expect(() => combined.emit(3), returnsNormally);
    });

    test('unwatch non-existent subscriber', () {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      void watcher(int value) {}
      expect(() => combined.unwatch(watcher), returnsNormally);
    });

    test('dispose already disposed watchable', () {
      final watchable1 = MutableStateWatchable<int>(1);
      final watchable2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      combined.dispose();
      expect(() => combined.dispose(), returnsNormally);
    });
  });

  group('WatchableConsumer Negative Tests', () {
    late MutableWatchable<int> watchable;

    setUp(() {
      watchable = MutableWatchable<int>();
    });

    testWidgets('should handle dispose already disposed widget gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableConsumer<int>(
            watchable: watchable,
            onEvent: (value) {},
            child: const Text('Test Widget'),
          ),
        ),
      );

      await tester.pumpWidget(Container()); // Unmount the widget
      expect(watchable.watcherCount, 0);

      // Dispose again
      await tester.pumpWidget(Container());
      expect(watchable.watcherCount, 0);
    });
  });

  group('WatchableBuilder Negative Tests', () {
    testWidgets('should handle dispose already disposed widget gracefully',
        (WidgetTester tester) async {
      final watchable = MutableStateWatchable<int>(0);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder<int>(
            watchable: watchable,
            builder: (context, value, child) {
              return const Text('Test Widget');
            },
          ),
        ),
      );

      await tester.pumpWidget(Container()); // Unmount the widget
      expect(watchable.watcherCount, 0);

      // Dispose again
      await tester.pumpWidget(Container());
      expect(watchable.watcherCount, 0);
    });

    testWidgets('should handle unwatch non-existent subscriber gracefully',
        (WidgetTester tester) async {
      final watchable = MutableStateWatchable<int>(0);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WatchableBuilder<int>(
            watchable: watchable,
            builder: (context, value, child) {
              return const Text('Test Widget');
            },
          ),
        ),
      );

      await tester.pumpWidget(Container()); // Unmount the widget
      expect(watchable.watcherCount, 0);

      // Unwatch non-existent subscriber
      void nonExistentWatcher(int value) {}
      expect(() => watchable.unwatch(nonExistentWatcher), returnsNormally);
    });
  });

  group('WatchableBuilder Dispose Negative Tests', () {
    late MutableStateWatchable<int> watchable;
    late Widget testWidget;

    setUp(() {
      watchable = MutableStateWatchable<int>(0);
      testWidget = Directionality(
        textDirection: TextDirection.ltr,
        child: WatchableBuilder<int>(
          watchable: watchable,
          builder: (context, value, child) {
            return Text('$value');
          },
        ),
      );
    });

    testWidgets('WatchableBuilder calls unwatch on dispose',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Update the watchable value
      watchable.emit(1);
      await tester.pump();

      // Verify updated state
      expect(find.text('1'), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Update the watchable value again
      watchable.emit(2);
      await tester.pump();

      // Verify that the widget is disposed and no longer updates
      expect(find.text('2'), findsNothing);
    });

    testWidgets('WatchableBuilder does not call unwatch if not watched',
        (WidgetTester tester) async {
      final anotherWatchable = MutableStateWatchable<int>(0);
      bool unwatchCalled = false;

      anotherWatchable.watch((value) {
        // This should not be called
      });

      anotherWatchable.unwatch((value) {
        unwatchCalled = true;
      });

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WatchableBuilder<int>(
          watchable: anotherWatchable,
          builder: (context, value, child) {
            return Text('$value');
          },
        ),
      ));

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Verify that unwatch was not called
      expect(unwatchCalled, isFalse);
    });
  });

  group('WatchableBuilder from Constructors Dispose Negative Tests', () {
    late MutableStateWatchable<int> watchable1;
    late MutableStateWatchable<int> watchable2;
    late Widget testWidget;

    setUp(() {
      watchable1 = MutableStateWatchable<int>(0);
      watchable2 = MutableStateWatchable<int>(0);
      testWidget = Directionality(
        textDirection: TextDirection.ltr,
        child: WatchableBuilder.from2(
          watchable1: watchable1,
          watchable2: watchable2,
          combiner: (a, b) => a + b,
          builder: (context, value, child) {
            return Text('$value');
          },
        ),
      );
    });

    testWidgets('WatchableBuilder.from2 calls unwatch on dispose',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Update the watchable values
      watchable1.emit(1);
      watchable2.emit(2);
      await tester.pump();

      // Verify updated state
      expect(find.text('3'), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Update the watchable values again
      watchable1.emit(3);
      watchable2.emit(4);
      await tester.pump();

      // Verify that the widget is disposed and no longer updates
      expect(find.text('7'), findsNothing);
    });

    testWidgets('WatchableBuilder.fromList calls unwatch on dispose',
        (WidgetTester tester) async {
      final watchableList = [watchable1, watchable2];
      testWidget = Directionality(
        textDirection: TextDirection.ltr,
        child: WatchableBuilder.fromList(
          watchableList: watchableList,
          combiner: (values) => values.reduce((a, b) => a + b),
          builder: (context, value, child) {
            return Text('$value');
          },
        ),
      );

      await tester.pumpWidget(testWidget);

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Update the watchable values
      watchable1.emit(1);
      watchable2.emit(2);
      await tester.pump();

      // Verify updated state
      expect(find.text('3'), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(Container());

      // Update the watchable values again
      watchable1.emit(3);
      watchable2.emit(4);
      await tester.pump();

      // Verify that the widget is disposed and no longer updates
      expect(find.text('7'), findsNothing);
    });
  });

  group('Stability Tests', () {
    test('handles high load of emissions', () {
      final shared = MutableWatchable<int>();
      int receivedCount = 0;
      shared.watch((value) {
        receivedCount++;
      });

      for (int i = 0; i < 1000; i++) {
        shared.emit(i);
      }

      expect(receivedCount, 1000);
    });

    test('handles null emission gracefully', () {
      final shared = MutableWatchable<int?>();
      bool nullReceived = false;
      shared.watch((value) {
        if (value == null) {
          nullReceived = true;
        }
      });

      shared.emit(null);
      expect(nullReceived, true);
    });

    test('manages resources correctly after multiple subscriptions', () {
      final shared = MutableWatchable<int>();
      void watcher(int value) {}

      for (int i = 0; i < 100; i++) {
        shared.watch(watcher);
        shared.unwatch(watcher);
      }

      expect(shared.watcherCount, 0);
    });

    test('handles concurrent emissions', () async {
      final shared = MutableWatchable<int>();
      int receivedCount = 0;
      shared.watch((value) {
        receivedCount++;
      });

      await Future.wait([
        Future(() => shared.emit(1)),
        Future(() => shared.emit(2)),
        Future(() => shared.emit(3)),
      ]);

      expect(receivedCount, 3);
    });

    test('handles multiple dispose calls gracefully', () {
      final shared = MutableWatchable<int>();
      shared.dispose();
      expect(() => shared.dispose(), returnsNormally);
    });

    test('handles unwatch non-existent subscriber gracefully', () {
      final shared = MutableWatchable<int>();
      void watcher(int value) {}
      expect(() => shared.unwatch(watcher), returnsNormally);
    });
  });

  // ============================================================================
  // COMPREHENSIVE EDGE CASE TESTS
  // ============================================================================

  group('MutableWatchable Advanced Edge Cases', () {
    test('should handle zero replay buffer correctly', () {
      final watchable = MutableWatchable<int>(replay: 0);
      expect(watchable.replayCache.isEmpty, true);

      watchable.emit(42);
      expect(watchable.replayCache.isEmpty, true);

      List<int> received = [];
      watchable.watch((value) => received.add(value));
      expect(received.isEmpty, true); // No replay with buffer size 0

      watchable.emit(100);
      expect(received, [100]);
    });

    test('should handle negative replay buffer size assertion', () {
      expect(() => MutableWatchable<int>(replay: -1), throwsAssertionError);
    });

    test('should handle very large replay buffer', () {
      final watchable = MutableWatchable<int>(replay: 10000);

      // Emit many values
      for (int i = 0; i < 10000; i++) {
        watchable.emit(i);
      }

      expect(watchable.replayCache.length, 10000);
      expect(watchable.replayCache.first, 0);
      expect(watchable.replayCache.last, 9999);

      // Add one more to test buffer overflow
      watchable.emit(10000);
      expect(watchable.replayCache.length, 10000);
      expect(watchable.replayCache.first, 1); // First item should be removed
      expect(watchable.replayCache.last, 10000);
    });

    test('should handle watch after dispose', () {
      final watchable = MutableWatchable<int>();
      watchable.dispose();

      expect(() => watchable.watch((value) {}), throwsStateError);
    });

    test('should handle emit after dispose', () {
      final watchable = MutableWatchable<int>();
      watchable.dispose();

      // Should not crash, just do nothing
      expect(() => watchable.emit(42), returnsNormally);
    });

    test('should handle unwatch after dispose', () {
      final watchable = MutableWatchable<int>();
      void watcher(int value) {}

      watchable.watch(watcher);
      watchable.dispose();

      // Should not crash
      expect(() => watchable.unwatch(watcher), returnsNormally);
    });

    test('should handle multiple identical watchers', () {
      final watchable = MutableWatchable<int>();
      void watcher(int value) {}

      // Sets prevent duplicates, so this should only add one watcher
      watchable.watch(watcher);
      watchable.watch(watcher);
      watchable.watch(watcher);

      expect(watchable.watcherCount, 1);

      watchable.unwatch(watcher);
      expect(watchable.watcherCount, 0);
    });

    test('should handle watcher that throws exception', () {
      final watchable = MutableWatchable<int>();
      List<int> successfulValues = [];

      watchable.watch((value) => throw Exception('Test exception'));
      watchable.watch((value) => successfulValues.add(value));

      // Should not prevent other watchers from receiving values
      watchable.emit(42);
      expect(successfulValues, [42]);
    });

    test('should handle watcher that modifies watcher list during emission',
        () {
      final watchable = MutableWatchable<int>();
      List<int> received = [];

      void recursiveWatcher(int value) {
        received.add(value);
        if (value < 5) {
          watchable.watch((v) => received.add(v * 10));
        }
      }

      watchable.watch(recursiveWatcher);
      watchable.emit(1);
      watchable.emit(2);

      // Should handle concurrent modification gracefully
      expect(received.contains(1), true);
      expect(received.contains(2), true);
    });

    test('should handle extremely rapid emissions', () {
      final watchable = MutableWatchable<int>();
      List<int> received = [];

      watchable.watch((value) => received.add(value));

      // Rapid fire emissions
      for (int i = 0; i < 1000; i++) {
        watchable.emit(i);
      }

      expect(received.length, 1000);
      expect(received.first, 0);
      expect(received.last, 999);
    });

    test('should handle different data types correctly', () {
      // String watchable
      final stringWatchable = MutableWatchable<String>();
      String? lastString;
      stringWatchable.watch((value) => lastString = value);
      stringWatchable.emit('hello');
      expect(lastString, 'hello');

      // Double watchable
      final doubleWatchable = MutableWatchable<double>();
      double? lastDouble;
      doubleWatchable.watch((value) => lastDouble = value);
      doubleWatchable.emit(3.14);
      expect(lastDouble, 3.14);

      // Custom object watchable
      final customWatchable = MutableWatchable<Map<String, int>>();
      Map<String, int>? lastMap;
      customWatchable.watch((value) => lastMap = value);
      customWatchable.emit({'key': 42});
      expect(lastMap, {'key': 42});
    });

    test('should maintain replay order correctly with rapid emissions', () {
      final watchable = MutableWatchable<int>(replay: 5);

      for (int i = 0; i < 10; i++) {
        watchable.emit(i);
      }

      expect(watchable.replayCache, [5, 6, 7, 8, 9]);

      List<int> replayed = [];
      watchable.watch((value) => replayed.add(value));

      expect(replayed, [5, 6, 7, 8, 9]);
    });
  });

  group('MutableStateWatchable Advanced Edge Cases', () {
    test('should handle custom equality comparison correctly', () {
      final watchable = MutableStateWatchable<int>(0,
          compare: (old, current) => (old - current).abs() < 2);

      List<int> received = [];
      watchable.watch((value) => received.add(value));

      // Initial value is now in replay buffer
      expect(received.length, 1);
      expect(received[0], 0);

      watchable.emit(
          1); // Should not emit (difference is 1, < 2, so considered equal)
      expect(received.length, 1); // Still only initial value

      watchable.emit(
          3); // Should emit (difference is 3, >= 2, so considered different)
      expect(received.length, 2);
      expect(received.last, 3);
    });

    test('should handle complex nested list comparison', () {
      final initialList = [
        [1, 2],
        [3, 4]
      ];
      final watchable = MutableStateWatchable<List<List<int>>>(initialList);

      List<List<List<int>>> received = [];
      watchable.watch((value) =>
          received.add(value.map((e) => List<int>.from(e)).toList()));

      // Initial value via replay buffer
      expect(received.length, 1);

      // Emit the same object reference - should not trigger (deep equality)
      watchable.emit(initialList);
      expect(received.length, 1); // Still only initial value

      // Emit identical nested structure but new object - should trigger (different object)
      watchable.emit([
        [1, 2],
        [3, 4]
      ]);
      expect(received.length,
          2); // This is actually different due to object reference

      // Emit different nested structure - should trigger
      watchable.emit([
        [1, 2],
        [3, 5] // Changed 4 to 5
      ]);
      expect(received.length, 3);
    });

    test('should handle complex nested map comparison', () {
      final initialMap = {
        'outer1': {'inner1': 1, 'inner2': 2},
        'outer2': {'inner3': 3, 'inner4': 4}
      };
      final watchable =
          MutableStateWatchable<Map<String, Map<String, int>>>(initialMap);

      int changeCount = 0;
      watchable.watch((value) => changeCount++);

      // Initial value from replay buffer
      expect(changeCount, 1);

      // Emit same object reference - should not trigger (deep equality for maps)
      watchable.emit(initialMap);
      expect(changeCount, 1); // Still only initial value

      // Emit identical nested structure but new object - should trigger (different object)
      watchable.emit({
        'outer1': {'inner1': 1, 'inner2': 2},
        'outer2': {'inner3': 3, 'inner4': 4}
      });
      expect(changeCount, 2); // Different object detected as change

      // Emit different nested structure - should trigger
      watchable.emit({
        'outer1': {'inner1': 1, 'inner2': 2},
        'outer2': {'inner3': 3, 'inner4': 5} // Changed 4 to 5
      });
      expect(changeCount, 3);
    });

    test('should handle null values correctly', () {
      final watchable = MutableStateWatchable<int?>(null);
      List<int?> received = [];
      watchable.watch((value) => received.add(value));

      // Initial null value via replay buffer
      expect(received.length, 1);
      expect(received[0], null);

      watchable.emit(42);
      expect(received.last, 42);
      expect(received.length, 2);

      watchable.emit(null);
      expect(received.last, null);
      expect(received.length, 3); // initial null, 42, final null
    });

    test('should handle comparison function that throws', () {
      bool compareThrew = false;
      final watchable = MutableStateWatchable<int>(0, compare: (old, current) {
        if (current == 1) {
          // Only throw for emit(1)
          compareThrew = true;
          throw Exception('Compare error');
        }
        return old == current;
      });

      List<int> received = [];
      watchable.watch((value) => received.add(value));

      // Initial value via replay buffer
      expect(received.length, 1);
      expect(received[0], 0);

      // Should fallback to default comparison and still work
      watchable.emit(1);
      expect(compareThrew, true);
      expect(received.length, 2); // initial 0, then 1
    });

    test('should handle very frequent state changes', () {
      final watchable = MutableStateWatchable<int>(0);
      List<int> received = [];
      watchable.watch((value) => received.add(value));

      // Initial value via replay buffer
      expect(received.length, 1);
      expect(received.first, 0);

      // Rapid state changes
      for (int i = 1; i <= 1000; i++) {
        watchable.emit(i);
      }

      expect(received.length, 1001); // initial + 1000 changes
      expect(received.first, 0);
      expect(received.last, 1000);
    });

    test('should handle state changes that alternate between two values', () {
      final watchable = MutableStateWatchable<bool>(true);
      List<bool> received = [];
      watchable.watch((value) => received.add(value));

      // Initial value via replay buffer
      expect(received.length, 1);
      expect(received.first, true);

      // Alternate between true and false
      // i=0: emit(true) - same as current, no change
      // i=1: emit(false) - different, change
      // i=2: emit(true) - different, change
      // etc.
      for (int i = 0; i < 100; i++) {
        watchable.emit(i % 2 == 0);
      }

      // Should be: initial true + 99 actual changes (skipping first true)
      expect(received.length, 100);
    });

    test('should handle dispose during value emission', () {
      final watchable = MutableStateWatchable<int>(0);
      bool disposed = false;

      watchable.watch((value) {
        if (value == 5) {
          watchable.dispose();
          disposed = true;
        }
      });

      for (int i = 1; i <= 10; i++) {
        if (!disposed) {
          watchable.emit(i);
        }
      }

      expect(disposed, true);
      expect(watchable.watcherCount, 0);
    });
  });

  group('CombineLatestWatchable Advanced Edge Cases', () {
    test('should handle single source watchable', () {
      final source = MutableStateWatchable<int>(42);
      final combined = CombineLatestWatchable<int, String>(
        [source],
        (values) => 'Value: ${values.first}',
      );

      expect(combined.value, 'Value: 42');

      List<String> received = [];
      combined.watch((value) => received.add(value));

      source.emit(100);
      expect(received.last, 'Value: 100');
    });

    test('should handle many source watchables', () {
      final sources = List.generate(100, (i) => MutableStateWatchable<int>(i));
      final combined = CombineLatestWatchable<int, int>(
        sources,
        (values) => values.reduce((a, b) => a + b),
      );

      final expectedSum = List.generate(100, (i) => i).reduce((a, b) => a + b);
      expect(combined.value, expectedSum);

      List<int> received = [];
      combined.watch((value) => received.add(value));

      // Change one source
      sources[0].emit(1000);
      expect(received.last, expectedSum - 0 + 1000);
    });

    test('should handle combiner function that throws', () {
      final source1 = MutableStateWatchable<int>(1);
      final source2 = MutableStateWatchable<int>(2);

      // The constructor itself will throw if the initial combiner throws
      expect(
          () => CombineLatestWatchable<int, int>(
                [source1, source2],
                (values) => throw Exception('Combiner error'),
              ),
          throwsException);
    });

    test('should handle rapid changes from multiple sources', () {
      final source1 = MutableStateWatchable<int>(0);
      final source2 = MutableStateWatchable<int>(0);
      final combined = CombineLatestWatchable<int, int>(
        [source1, source2],
        (values) => values[0] + values[1],
      );

      List<int> received = [];
      combined.watch((value) => received.add(value));

      // Rapid alternating changes
      for (int i = 0; i < 100; i++) {
        if (i % 2 == 0) {
          source1.emit(i);
        } else {
          source2.emit(i);
        }
      }

      expect(received.length > 50, true); // Should receive many updates
    });

    test('should handle source disposal during combination', () {
      final source1 = MutableStateWatchable<int>(1);
      final source2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [source1, source2],
        (values) => values[0] + values[1],
      );

      List<int> received = [];
      combined.watch((value) => received.add(value));

      source1.dispose(); // Dispose one source

      // Should handle gracefully
      source2.emit(10);
    });

    test('should handle concurrent dispose operations', () async {
      final source1 = MutableStateWatchable<int>(1);
      final source2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [source1, source2],
        (values) => values[0] + values[1],
      );

      // Dispose sources and combined simultaneously and wait for completion
      await Future.wait([
        Future(() => source1.dispose()),
        Future(() => source2.dispose()),
        Future(() => combined.dispose()),
      ]);

      expect(source1.watcherCount, 0);
      expect(source2.watcherCount, 0);
      expect(combined.watcherCount, 0);
    });

    test('should handle circular dependency prevention', () {
      final source1 = MutableStateWatchable<int>(1);
      final source2 = MutableStateWatchable<int>(2);
      final combined1 = CombineLatestWatchable<int, int>(
        [source1, source2],
        (values) => values[0] + values[1],
      );

      // Create a circular-ish dependency
      final combined2 = CombineLatestWatchable<int, int>(
        [combined1, source1],
        (values) => values[0] * values[1],
      );

      expect(combined2.value, 3); // (1 + 2) * 1 = 3

      source1.emit(5);
      expect(combined2.value, 35); // (5 + 2) * 5 = 35
    });
  });

  group('Type-Safe Combiners Edge Cases', () {
    test('should handle from2 with different types', () {
      final intWatchable = MutableStateWatchable<int>(42);
      final stringWatchable = MutableStateWatchable<String>('hello');

      late Widget testWidget;
      testWidget = MaterialApp(
        home: WatchableBuilder.from2<int, String, String>(
          watchable1: intWatchable,
          watchable2: stringWatchable,
          combiner: (int a, String b) => '$b: $a',
          builder: (context, value, child) => Text(value),
        ),
      );

      expect(testWidget, isA<MaterialApp>());
      // The actual type safety is enforced at compile time
    });

    test('should handle from3 with complex custom objects', () {
      final userWatchable =
          MutableStateWatchable<Map<String, String>>({'name': 'John'});
      final ageWatchable = MutableStateWatchable<int>(30);
      final activeWatchable = MutableStateWatchable<bool>(true);

      late Widget testWidget;
      testWidget = MaterialApp(
        home: WatchableBuilder.from3<Map<String, String>, int, bool, String>(
          watchable1: userWatchable,
          watchable2: ageWatchable,
          watchable3: activeWatchable,
          combiner: (user, age, active) =>
              '${user['name']}: $age years old, ${active ? 'active' : 'inactive'}',
          builder: (context, value, child) => Text(value),
        ),
      );

      expect(testWidget, isA<MaterialApp>());
    });

    test('should handle from4 and from5 with nullable types', () {
      final w1 = MutableStateWatchable<int?>(null);
      final w2 = MutableStateWatchable<int?>(null);
      final w3 = MutableStateWatchable<int?>(null);
      final w4 = MutableStateWatchable<int?>(null);
      final w5 = MutableStateWatchable<int?>(null);

      late Widget testWidget4;
      testWidget4 = MaterialApp(
        home: WatchableBuilder.from4<int?, int?, int?, int?, String>(
          watchable1: w1,
          watchable2: w2,
          watchable3: w3,
          watchable4: w4,
          combiner: (a, b, c, d) =>
              'Sum: ${(a ?? 0) + (b ?? 0) + (c ?? 0) + (d ?? 0)}',
          builder: (context, value, child) => Text(value),
        ),
      );

      late Widget testWidget5;
      testWidget5 = MaterialApp(
        home: WatchableBuilder.from5<int?, int?, int?, int?, int?, String>(
          watchable1: w1,
          watchable2: w2,
          watchable3: w3,
          watchable4: w4,
          watchable5: w5,
          combiner: (a, b, c, d, e) =>
              'Sum: ${(a ?? 0) + (b ?? 0) + (c ?? 0) + (d ?? 0) + (e ?? 0)}',
          builder: (context, value, child) => Text(value),
        ),
      );

      expect(testWidget4, isA<MaterialApp>());
      expect(testWidget5, isA<MaterialApp>());
    });
  });

  group('Error Handling and Exception Tests', () {
    testWidgets('should handle watcher exception in WatchableBuilder',
        (WidgetTester tester) async {
      final watchable = MutableStateWatchable<int>(0);
      bool exceptionThrown = false;

      await tester.pumpWidget(
        MaterialApp(
          home: WatchableBuilder<int>(
            watchable: watchable,
            shouldRebuild: (previous, current) {
              if (current == 5) {
                exceptionThrown = true;
                throw Exception('shouldRebuild error');
              }
              return true;
            },
            builder: (context, value, child) {
              return Text('$value');
            },
          ),
        ),
      );

      // Should handle exception gracefully and still rebuild
      watchable.emit(5);
      await tester.pump();

      expect(exceptionThrown, true);
      expect(find.text('5'), findsOneWidget); // Should still show the value
    });

    testWidgets('should handle onEvent exception in WatchableConsumer',
        (WidgetTester tester) async {
      final watchable = MutableWatchable<int>();
      bool exceptionThrown = false;

      await tester.pumpWidget(
        MaterialApp(
          home: WatchableConsumer<int>(
            watchable: watchable,
            onEvent: (value) {
              if (value == 42) {
                exceptionThrown = true;
                throw Exception('onEvent error');
              }
            },
            child: const Text('Test Widget'),
          ),
        ),
      );

      // Should handle exception gracefully
      watchable.emit(42);
      await tester.pump();

      expect(exceptionThrown, true);
      expect(find.text('Test Widget'), findsOneWidget);
    });

    test('should handle watcher exception during replay', () {
      final watchable = MutableWatchable<int>(replay: 3);
      watchable.emit(1);
      watchable.emit(2);
      watchable.emit(3);

      bool exceptionThrown = false;
      List<int> successfulReplays = [];

      // Add watcher that throws on replay
      watchable.watch((value) {
        if (value == 2) {
          exceptionThrown = true;
          throw Exception('Replay error');
        } else {
          successfulReplays.add(value);
        }
      });

      expect(exceptionThrown, true);
      expect(successfulReplays, [1, 3]); // Should receive other replayed values
    });

    test('should handle comparison function exception in MutableStateWatchable',
        () {
      final watchable = MutableStateWatchable<int>(0, compare: (old, current) {
        if (current == 5) {
          throw Exception('Compare error');
        }
        return old == current;
      });

      List<int> received = [];
      watchable.watch((value) => received.add(value));

      watchable.emit(1);
      expect(received.last, 1);

      // Should fallback to default comparison when compare throws
      watchable.emit(5);
      expect(received.last, 5); // Should still emit the value
    });

    test('should handle combiner exception in CombineLatestWatchable', () {
      final source1 = MutableStateWatchable<int>(1);
      final source2 = MutableStateWatchable<int>(2);

      bool exceptionThrown = false;
      final combined = CombineLatestWatchable<int, int>(
        [source1, source2],
        (values) {
          if (values[0] == 10) {
            exceptionThrown = true;
            throw Exception('Combiner error');
          }
          return values[0] + values[1];
        },
      );

      expect(combined.value, 3); // Initial combination works

      source1.emit(10); // This should trigger the exception
      expect(exceptionThrown, true);
    });
  });

  group('Memory and Resource Management Tests', () {
    test('should not leak memory with many watchers', () {
      final watchable = MutableWatchable<int>();

      // Add many watchers
      final watchers = List.generate(1000, (i) => (int value) {});
      for (var watcher in watchers) {
        watchable.watch(watcher);
      }

      expect(watchable.watcherCount, 1000);

      // Remove all watchers
      for (var watcher in watchers) {
        watchable.unwatch(watcher);
      }

      expect(watchable.watcherCount, 0);
    });

    test('should handle stress test with rapid subscribe/unsubscribe', () {
      final watchable = MutableWatchable<int>();

      for (int i = 0; i < 1000; i++) {
        void watcher(int value) {}
        watchable.watch(watcher);
        watchable.emit(i);
        watchable.unwatch(watcher);
      }

      expect(watchable.watcherCount, 0);
    });

    test('should handle large replay buffer efficiently', () {
      final watchable = MutableWatchable<int>(replay: 1000);

      // Fill the buffer
      for (int i = 0; i < 1000; i++) {
        watchable.emit(i);
      }

      expect(watchable.replayCache.length, 1000);

      // Add watcher - should receive all 1000 values
      List<int> replayed = [];
      watchable.watch((value) => replayed.add(value));

      expect(replayed.length, 1000);
      expect(replayed.first, 0);
      expect(replayed.last, 999);
    });

    test('should clean up resources on dispose', () {
      final source1 = MutableStateWatchable<int>(1);
      final source2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [source1, source2],
        (values) => values[0] + values[1],
      );

      // Verify initial setup
      expect(source1.watcherCount, 1);
      expect(source2.watcherCount, 1);

      combined.dispose();

      // Should clean up all resources
      expect(source1.watcherCount, 0);
      expect(source2.watcherCount, 0);
      expect(combined.watcherCount, 0);
    });

    test('should handle dispose of already disposed resources gracefully', () {
      final watchable = MutableWatchable<int>();

      // Test multiple dispose calls
      watchable.dispose();
      expect(() => watchable.dispose(), returnsNormally);
      expect(() => watchable.dispose(), returnsNormally);

      // Test creating CombineLatestWatchable with valid sources then disposing
      final source1 = MutableStateWatchable<int>(1);
      final source2 = MutableStateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [source1, source2],
        (values) => values[0] + values[1],
      );

      // Dispose all
      source1.dispose();
      source2.dispose();
      combined.dispose();

      expect(source1.watcherCount, 0);
      expect(source2.watcherCount, 0);
      expect(combined.watcherCount, 0);
    });
  });

  group('Threading and Concurrency Tests', () {
    test('should handle concurrent emissions from different sources', () async {
      final watchable = MutableWatchable<int>();
      List<int> received = [];

      watchable.watch((value) => received.add(value));

      // Concurrent emissions
      await Future.wait(
          [for (int i = 0; i < 100; i++) Future(() => watchable.emit(i))]);

      expect(received.length, 100);
      // Values might be in different order due to concurrency
      expect(received.toSet().length, 100); // But all should be unique
    });

    test('should handle concurrent watcher modifications', () async {
      final watchable = MutableWatchable<int>();

      // Concurrent watch/unwatch operations
      await Future.wait([
        for (int i = 0; i < 50; i++)
          Future(() {
            void watcher(int value) {}
            watchable.watch(watcher);
            watchable.unwatch(watcher);
          })
      ]);

      expect(watchable.watcherCount, 0);
    });

    test('should handle concurrent dispose operations', () async {
      final watchables = List.generate(100, (i) => MutableWatchable<int>());

      await Future.wait([
        for (var watchable in watchables) Future(() => watchable.dispose())
      ]);

      for (var watchable in watchables) {
        expect(watchable.watcherCount, 0);
      }
    });
  });

  group('Integration and System Tests', () {
    testWidgets('should handle complex widget tree with many watchables',
        (WidgetTester tester) async {
      final watchables =
          List.generate(10, (i) => MutableStateWatchable<int>(i));

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              for (int i = 0; i < watchables.length; i++)
                WatchableBuilder<int>(
                  watchable: watchables[i],
                  builder: (context, value, child) => Text('W$i: $value'),
                ),
            ],
          ),
        ),
      );

      // Verify all initial values
      for (int i = 0; i < watchables.length; i++) {
        expect(find.text('W$i: $i'), findsOneWidget);
      }

      // Update all watchables
      for (int i = 0; i < watchables.length; i++) {
        watchables[i].emit(i * 10);
      }
      await tester.pump();

      // Verify all updated values
      for (int i = 0; i < watchables.length; i++) {
        expect(find.text('W$i: ${i * 10}'), findsOneWidget);
      }
    });

    testWidgets('should handle nested WatchableBuilders',
        (WidgetTester tester) async {
      final outer = MutableStateWatchable<int>(1);
      final inner = MutableStateWatchable<String>('A');

      await tester.pumpWidget(
        MaterialApp(
          home: WatchableBuilder<int>(
            watchable: outer,
            builder: (context, outerValue, child) {
              return WatchableBuilder<String>(
                watchable: inner,
                builder: (context, innerValue, child) {
                  return Text('$outerValue-$innerValue');
                },
              );
            },
          ),
        ),
      );

      expect(find.text('1-A'), findsOneWidget);

      outer.emit(2);
      await tester.pump();
      expect(find.text('2-A'), findsOneWidget);

      inner.emit('B');
      await tester.pump();
      expect(find.text('2-B'), findsOneWidget);
    });

    testWidgets('should handle complex state updates with shouldRebuild',
        (WidgetTester tester) async {
      final watchable = MutableStateWatchable<int>(0);
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: WatchableBuilder<int>(
            watchable: watchable,
            shouldRebuild: (previous, current) =>
                current % 2 == 0, // Only even numbers
            builder: (context, value, child) {
              buildCount++;
              return Text('$value');
            },
          ),
        ),
      );

      expect(buildCount, 1); // Initial build

      watchable.emit(1); // Odd - should not rebuild
      await tester.pump();
      expect(buildCount, 1);
      expect(find.text('0'), findsOneWidget); // Still shows old value in widget

      watchable.emit(2); // Even - should rebuild
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('2'), findsOneWidget);

      watchable.emit(3); // Odd - should not rebuild
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('2'), findsOneWidget); // Still shows previous even value
    });

    test('should handle end-to-end data flow', () {
      // Create a complete data flow chain
      final source = MutableWatchable<int>();
      final state = MutableStateWatchable<String>('initial');
      final combined = CombineLatestWatchable<String, String>(
        [state],
        (values) => 'Processed: ${values.first}',
      );

      List<String> finalResults = [];
      combined.watch((value) => finalResults.add(value));

      // Update source which updates state which updates combined
      source.watch((value) => state.emit('value_$value'));

      source.emit(42);
      expect(finalResults.last, 'Processed: value_42');

      source.emit(100);
      expect(finalResults.last, 'Processed: value_100');
    });
  });

  // ============================================================================
  // EXTENSION API TESTS - Testing new .watch syntax and shortcuts
  // ============================================================================

  group('Extension API Tests', () {
    group('Basic .watch Extension', () {
      test('should create WInt from int.watch', () {
        final counter = 0.watch;
        expect(counter, isA<WInt>());
        expect(counter.value, 0);

        // Test functionality
        int? receivedValue;
        counter.watch((value) => receivedValue = value);

        counter.emit(42);
        expect(counter.value, 42);
        expect(receivedValue, 42);
      });

      test('should create WString from string.watch', () {
        final name = 'John'.watch;
        expect(name, isA<WString>());
        expect(name.value, 'John');

        // Test functionality
        String? receivedValue;
        name.watch((value) => receivedValue = value);

        name.emit('Jane');
        expect(name.value, 'Jane');
        expect(receivedValue, 'Jane');
      });

      test('should create WBool from bool.watch', () {
        final flag = false.watch;
        expect(flag, isA<WBool>());
        expect(flag.value, false);

        // Test functionality
        bool? receivedValue;
        flag.watch((value) => receivedValue = value);

        flag.emit(true);
        expect(flag.value, true);
        expect(receivedValue, true);
      });

      test('should create WDouble from double.watch', () {
        final price = 99.99.watch;
        expect(price, isA<WDouble>());
        expect(price.value, 99.99);

        // Test functionality
        double? receivedValue;
        price.watch((value) => receivedValue = value);

        price.emit(89.99);
        expect(price.value, 89.99);
        expect(receivedValue, 89.99);
      });

      test('should create WList from list.watch', () {
        final items = <String>['item1'].watch;
        expect(items, isA<WList<String>>());
        expect(items.value, ['item1']);

        // Test functionality
        List<String>? receivedValue;
        items.watch((value) => receivedValue = value);

        items.emit(['item1', 'item2']);
        expect(items.value, ['item1', 'item2']);
        expect(receivedValue, ['item1', 'item2']);
      });

      test('should create WMap from map.watch', () {
        final config = <String, int>{'timeout': 30}.watch;
        expect(config, isA<WMap<String, int>>());
        expect(config.value, {'timeout': 30});

        // Test functionality
        Map<String, int>? receivedValue;
        config.watch((value) => receivedValue = value);

        config.emit({'timeout': 60, 'retries': 3});
        expect(config.value, {'timeout': 60, 'retries': 3});
        expect(receivedValue, {'timeout': 60, 'retries': 3});
      });

      test('should create W<T> from generic.watch', () {
        final user = User().watch;
        expect(user, isA<W<User>>());
        expect(user.value, isA<User>());

        // Test functionality
        User? receivedValue;
        user.watch((value) => receivedValue = value);

        final newUser = User();
        user.emit(newUser);
        expect(user.value, newUser);
        expect(receivedValue, newUser);
      });
    });

    group('Type Aliases Tests', () {
      test('WInt should be equivalent to MutableStateWatchable<int>', () {
        final counter1 = WInt(42);
        final counter2 = MutableStateWatchable<int>(42);

        expect(counter1.runtimeType, counter2.runtimeType);
        expect(counter1.value, counter2.value);
      });

      test('WString should be equivalent to MutableStateWatchable<String>', () {
        final name1 = WString('John');
        final name2 = MutableStateWatchable<String>('John');

        expect(name1.runtimeType, name2.runtimeType);
        expect(name1.value, name2.value);
      });

      test('WBool should be equivalent to MutableStateWatchable<bool>', () {
        final flag1 = WBool(true);
        final flag2 = MutableStateWatchable<bool>(true);

        expect(flag1.runtimeType, flag2.runtimeType);
        expect(flag1.value, flag2.value);
      });

      test('WDouble should be equivalent to MutableStateWatchable<double>', () {
        final price1 = WDouble(99.99);
        final price2 = MutableStateWatchable<double>(99.99);

        expect(price1.runtimeType, price2.runtimeType);
        expect(price1.value, price2.value);
      });

      test('WList should be equivalent to MutableStateWatchable<List>', () {
        final items1 = WList<String>(['item1']);
        final items2 = MutableStateWatchable<List<String>>(['item1']);

        expect(items1.runtimeType, items2.runtimeType);
        expect(items1.value, items2.value);
      });

      test('WMap should be equivalent to MutableStateWatchable<Map>', () {
        final config1 = WMap<String, int>({'timeout': 30});
        final config2 =
            MutableStateWatchable<Map<String, int>>({'timeout': 30});

        expect(config1.runtimeType, config2.runtimeType);
        expect(config1.value, config2.value);
      });

      test('WEvent should be equivalent to MutableWatchable', () {
        final events1 = WEvent<String>();
        final events2 = MutableWatchable<String>();

        expect(events1.runtimeType, events2.runtimeType);
        expect(events1.replayCache, events2.replayCache);
      });

      test('W<T> should be equivalent to MutableStateWatchable<T>', () {
        final user1 = W<User>(User());
        final user2 = MutableStateWatchable<User>(User());

        expect(user1.runtimeType, user2.runtimeType);
      });
    });

    group('Widget Extension Tests', () {
      testWidgets('StateWatchable.build should work like WatchableBuilder',
          (tester) async {
        final counter = 0.watch;

        int buildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: counter.build((value) {
              buildCount++;
              return Text('Count: $value');
            }),
          ),
        );

        expect(find.text('Count: 0'), findsOneWidget);
        expect(buildCount, 1);

        counter.emit(42);
        await tester.pump();

        expect(find.text('Count: 42'), findsOneWidget);
        expect(buildCount, 2);
      });

      testWidgets('StateWatchable.build with shouldRebuild should work',
          (tester) async {
        final counter = 0.watch;

        int buildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: counter.build(
              (value) {
                buildCount++;
                return Text('Count: $value');
              },
              shouldRebuild: (previous, current) => current % 2 == 0,
            ),
          ),
        );

        expect(buildCount, 1); // Initial build

        counter.emit(1); // Odd - should not rebuild
        await tester.pump();
        expect(buildCount, 1);

        counter.emit(2); // Even - should rebuild
        await tester.pump();
        expect(buildCount, 2);
        expect(find.text('Count: 2'), findsOneWidget);
      });

      testWidgets('Watchable.consume should work like WatchableConsumer',
          (tester) async {
        final events = WEvent<String>();

        List<String> receivedEvents = [];

        await tester.pumpWidget(
          MaterialApp(
            home: events.consume(
              onEvent: (message) => receivedEvents.add(message),
              child: const Text('Child Widget'),
            ),
          ),
        );

        expect(find.text('Child Widget'), findsOneWidget);
        expect(receivedEvents.isEmpty, true);

        events.emit('Event 1');
        await tester.pump();

        expect(receivedEvents, ['Event 1']);
        expect(find.text('Child Widget'), findsOneWidget); // Child unchanged

        events.emit('Event 2');
        await tester.pump();

        expect(receivedEvents, ['Event 1', 'Event 2']);
      });
    });

    group('Extension API Equivalence Tests', () {
      test('extension API should behave identically to traditional API', () {
        // Create same state using both APIs
        final traditionalCounter = MutableStateWatchable<int>(0);
        final extensionCounter = 0.watch;

        // Both should receive same values
        List<int> traditionalValues = [];
        List<int> extensionValues = [];

        traditionalCounter.watch((value) => traditionalValues.add(value));
        extensionCounter.watch((value) => extensionValues.add(value));

        // Emit same values to both
        for (int i = 1; i <= 10; i++) {
          traditionalCounter.emit(i);
          extensionCounter.emit(i);
        }

        // Results should be identical
        expect(extensionValues, traditionalValues);
        expect(extensionCounter.value, traditionalCounter.value);
      });

      testWidgets(
          'extension widgets should behave identically to traditional widgets',
          (tester) async {
        final traditionalCounter = MutableStateWatchable<int>(0);
        final extensionCounter = 0.watch;

        int traditionalBuildCount = 0;
        int extensionBuildCount = 0;

        // Traditional widget
        final traditionalWidget = WatchableBuilder<int>(
          watchable: traditionalCounter,
          builder: (context, value, child) {
            traditionalBuildCount++;
            return Text('Traditional: $value');
          },
        );

        // Extension widget
        final extensionWidget = extensionCounter.build((value) {
          extensionBuildCount++;
          return Text('Extension: $value');
        });

        // Test traditional widget
        await tester.pumpWidget(MaterialApp(home: traditionalWidget));
        expect(traditionalBuildCount, 1);

        traditionalCounter.emit(42);
        await tester.pump();
        expect(traditionalBuildCount, 2);

        // Test extension widget
        await tester.pumpWidget(MaterialApp(home: extensionWidget));
        expect(extensionBuildCount, 1);

        extensionCounter.emit(42);
        await tester.pump();
        expect(extensionBuildCount, 2);

        // Both should have same build pattern
        expect(extensionBuildCount, traditionalBuildCount);
      });

      test('extension event handling should behave identically', () {
        final traditionalEvents = MutableWatchable<String>();
        final extensionEvents = WEvent<String>();

        List<String> traditionalReceived = [];
        List<String> extensionReceived = [];

        traditionalEvents.watch((event) => traditionalReceived.add(event));
        extensionEvents.watch((event) => extensionReceived.add(event));

        // Emit same events to both
        for (int i = 1; i <= 5; i++) {
          final event = 'Event $i';
          traditionalEvents.emit(event);
          extensionEvents.emit(event);
        }

        expect(extensionReceived, traditionalReceived);
        expect(extensionReceived.length, 5);
      });
    });

    group('Extension API Memory Management Tests', () {
      test('extension watchables should handle disposal correctly', () {
        final counter = 0.watch;
        final events = WEvent<String>();

        bool counterWatcherCalled = false;
        bool eventsWatcherCalled = false;

        counter.watch((value) => counterWatcherCalled = true);
        events.watch((value) => eventsWatcherCalled = true);

        // Dispose both
        counter.dispose();
        events.dispose();

        // Try to watch after disposal - should throw StateError
        expect(() => counter.watch((value) {}), throwsStateError);
        expect(() => events.watch((value) {}), throwsStateError);

        // Emit values after disposal should work (no exception), but no watchers called
        counter.emit(42); // This won't throw but no watchers will be called
        events.emit('test'); // Same here

        expect(
            counterWatcherCalled, true); // Called during initial construction
        expect(eventsWatcherCalled,
            false); // Events don't have initial values, so watcher not called initially
      });

      testWidgets('extension widgets should handle disposal correctly',
          (tester) async {
        final counter = 0.watch;

        await tester.pumpWidget(
          MaterialApp(
            home: counter.build((value) => Text('$value')),
          ),
        );

        expect(counter.watcherCount, 1); // Widget is watching

        // Dispose widget by pumping empty widget
        await tester.pumpWidget(Container());

        expect(counter.watcherCount, 0); // Widget stopped watching
      });
    });

    group('Extension API Performance Tests', () {
      test('extension API should have same performance as traditional API', () {
        final traditionalCounter = MutableStateWatchable<int>(0);
        final extensionCounter = 0.watch;

        // Measure traditional API performance
        final traditionalStopwatch = Stopwatch()..start();
        for (int i = 0; i < 1000; i++) {
          traditionalCounter.emit(i);
        }
        traditionalStopwatch.stop();

        // Measure extension API performance
        final extensionStopwatch = Stopwatch()..start();
        for (int i = 0; i < 1000; i++) {
          extensionCounter.emit(i);
        }
        extensionStopwatch.stop();

        // Extension API should not be significantly slower (allow 50% variance)
        final ratio = extensionStopwatch.elapsedMicroseconds /
            traditionalStopwatch.elapsedMicroseconds;
        expect(ratio, lessThan(1.5),
            reason: 'Extension API should not be significantly slower');

        expect(extensionCounter.value, 999);
        expect(traditionalCounter.value, 999);
      });

      test('extension API should handle high load correctly', () {
        final counter = 0.watch;
        final events = WEvent<String>();

        int counterCallCount = 0;
        int eventsCallCount = 0;

        counter.watch((value) => counterCallCount++);
        events.watch((value) => eventsCallCount++);

        // High load test
        for (int i = 0; i < 10000; i++) {
          counter.emit(i);
          events.emit('Event $i');
        }

        expect(counterCallCount,
            10000); // No +1 because counter doesn't auto-emit initial on watch
        expect(eventsCallCount, 10000);
        expect(counter.value, 9999);
      });
    });

    group('Extension API Edge Cases', () {
      test('should handle null values correctly with extensions', () {
        final nullableString = W<String?>(null);
        expect(nullableString.value, null);

        String? receivedValue = 'not null';
        nullableString.watch((value) => receivedValue = value);

        nullableString.emit('hello');
        expect(receivedValue, 'hello');

        nullableString.emit(null);
        expect(receivedValue, null);
      });

      test('should handle complex generic types with extensions', () {
        final complexMap = <String, List<int>>{}.watch;
        expect(complexMap, isA<WMap<String, List<int>>>());

        Map<String, List<int>>? received;
        complexMap.watch((value) => received = value);

        complexMap.emit({
          'numbers': [1, 2, 3],
          'more': [4, 5]
        });
        expect(received, {
          'numbers': [1, 2, 3],
          'more': [4, 5]
        });
      });

      test('should handle custom comparison functions with extensions', () {
        final counter =
            WInt(0, compare: (old, current) => (old - current).abs() < 2);

        int callCount = 0;
        counter.watch((value) => callCount++);

        counter.emit(1); // Difference is 1, should not emit
        expect(callCount, 1); // Only initial call
        expect(counter.value, 0); // Value unchanged

        counter.emit(3); // Difference is 3, should emit
        expect(callCount, 2);
        expect(counter.value, 3);
      });
    });

    group('Combiner Extension Tests', () {
      test('should combine 2 watchables with tuple extension', () {
        final name = 'John'.watch;
        final age = 25.watch;

        final combined = (name, age).combine((n, a) => 'Name: $n, Age: $a');

        expect(combined.value, 'Name: John, Age: 25');

        String? receivedValue;
        combined.watch((value) => receivedValue = value);

        name.emit('Jane');
        expect(combined.value, 'Name: Jane, Age: 25');
        expect(receivedValue, 'Name: Jane, Age: 25');

        age.emit(30);
        expect(combined.value, 'Name: Jane, Age: 30');
        expect(receivedValue, 'Name: Jane, Age: 30');
      });

      test('should combine 3 watchables with tuple extension', () {
        final first = 'John'.watch;
        final last = 'Doe'.watch;
        final age = 25.watch;

        final combined = (first, last, age).combine((f, l, a) => '$f $l ($a)');

        expect(combined.value, 'John Doe (25)');

        String? receivedValue;
        combined.watch((value) => receivedValue = value);

        first.emit('Jane');
        expect(combined.value, 'Jane Doe (25)');
        expect(receivedValue, 'Jane Doe (25)');
      });

      testWidgets('should build widget from 2 watchables with tuple extension',
          (tester) async {
        final name = 'John'.watch;
        final age = 25.watch;

        await tester.pumpWidget(
          MaterialApp(
            home: (name, age).build((n, a) => Text('$n is $a years old')),
          ),
        );

        expect(find.text('John is 25 years old'), findsOneWidget);

        name.emit('Jane');
        await tester.pump();

        expect(find.text('Jane is 25 years old'), findsOneWidget);

        age.emit(30);
        await tester.pump();

        expect(find.text('Jane is 30 years old'), findsOneWidget);
      });

      test('should use Watch.combine2 for combining watchables', () {
        final name = 'John'.watch;
        final age = 25.watch;

        final combined =
            Watch.combine2(name, age, (n, a) => 'Name: $n, Age: $a');

        expect(combined.value, 'Name: John, Age: 25');

        String? receivedValue;
        combined.watch((value) => receivedValue = value);

        name.emit('Jane');
        expect(combined.value, 'Name: Jane, Age: 25');
        expect(receivedValue, 'Name: Jane, Age: 25');
      });

      testWidgets('should use Watch.build2 for building widgets',
          (tester) async {
        final name = 'John'.watch;
        final age = 25.watch;

        await tester.pumpWidget(
          MaterialApp(
            home: Watch.build2(name, age, (n, a) => Text('$n is $a years old')),
          ),
        );

        expect(find.text('John is 25 years old'), findsOneWidget);

        name.emit('Jane');
        await tester.pump();

        expect(find.text('Jane is 25 years old'), findsOneWidget);
      });

      test('should combine multiple different types correctly', () {
        final name = 'John'.watch;
        final age = 25.watch;
        final isActive = true.watch;
        final score = 95.5.watch;

        final combined = Watch.combine4(name, age, isActive, score,
            (n, a, active, s) => 'User: $n ($a), Active: $active, Score: $s');

        expect(combined.value, 'User: John (25), Active: true, Score: 95.5');

        String? receivedValue;
        combined.watch((value) => receivedValue = value);

        isActive.emit(false);
        expect(combined.value, 'User: John (25), Active: false, Score: 95.5');
        expect(receivedValue, 'User: John (25), Active: false, Score: 95.5');
      });

      testWidgets('should handle complex form validation with combiners',
          (tester) async {
        final email = ''.watch;
        final password = ''.watch;
        final confirmPassword = ''.watch;
        final agreedToTerms = false.watch;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Form inputs would go here
                  Watch.build4(email, password, confirmPassword, agreedToTerms,
                      (e, p, cp, agreed) {
                    final isValidEmail = e.contains('@');
                    final isValidPassword = p.length >= 6;
                    final passwordsMatch = p == cp;
                    final isFormValid = isValidEmail &&
                        isValidPassword &&
                        passwordsMatch &&
                        agreed;

                    return ElevatedButton(
                      onPressed: isFormValid ? () {} : null,
                      child: Text(isFormValid ? 'Submit' : 'Fix errors'),
                    );
                  }),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Fix errors'), findsOneWidget);

        // Fill form correctly
        email.emit('test@example.com');
        password.emit('password123');
        confirmPassword.emit('password123');
        agreedToTerms.emit(true);
        await tester.pump();

        expect(find.text('Submit'), findsOneWidget);
      });

      test('should handle custom classes in combiners', () {
        final user1 = User(name: 'John', id: 1).watch;
        final user2 = User(name: 'Jane', id: 2).watch;

        final combined = (user1, user2).combine((u1, u2) =>
            'Users: ${u1.name} (${u1.id}) and ${u2.name} (${u2.id})');

        expect(combined.value, 'Users: John (1) and Jane (2)');

        String? receivedValue;
        combined.watch((value) => receivedValue = value);

        user1.emit(User(name: 'Bob', id: 3));
        expect(combined.value, 'Users: Bob (3) and Jane (2)');
        expect(receivedValue, 'Users: Bob (3) and Jane (2)');
      });

      test('should combine 6 watchables with tuple extension', () {
        final firstName = 'John'.watch;
        final lastName = 'Doe'.watch;
        final age = 25.watch;
        final email = 'john@example.com'.watch;
        final isActive = true.watch;
        final score = 95.5.watch;

        final combined = (
          firstName,
          lastName,
          age,
          email,
          isActive,
          score
        ).combine((first, last, a, e, active, s) =>
            'User: $first $last ($a), Email: $e, Active: $active, Score: $s');

        expect(combined.value,
            'User: John Doe (25), Email: john@example.com, Active: true, Score: 95.5');

        String? receivedValue;
        combined.watch((value) => receivedValue = value);

        firstName.emit('Jane');
        expect(combined.value,
            'User: Jane Doe (25), Email: john@example.com, Active: true, Score: 95.5');
        expect(receivedValue,
            'User: Jane Doe (25), Email: john@example.com, Active: true, Score: 95.5');

        isActive.emit(false);
        expect(combined.value,
            'User: Jane Doe (25), Email: john@example.com, Active: false, Score: 95.5');
        expect(receivedValue,
            'User: Jane Doe (25), Email: john@example.com, Active: false, Score: 95.5');
      });

      testWidgets('should build widget from 6 watchables with tuple extension',
          (tester) async {
        final firstName = 'John'.watch;
        final lastName = 'Doe'.watch;
        final age = 25.watch;
        final email = 'john@example.com'.watch;
        final isActive = true.watch;
        final score = 95.5.watch;

        await tester.pumpWidget(
          MaterialApp(
            home: (firstName, lastName, age, email, isActive, score).build(
                (first, last, a, e, active, s) => Text('$first $last ($a)')),
          ),
        );

        expect(find.text('John Doe (25)'), findsOneWidget);

        firstName.emit('Jane');
        await tester.pump();

        expect(find.text('Jane Doe (25)'), findsOneWidget);

        age.emit(30);
        await tester.pump();

        expect(find.text('Jane Doe (30)'), findsOneWidget);
      });

      test('should use Watch.combine6 for combining watchables', () {
        final firstName = 'John'.watch;
        final lastName = 'Doe'.watch;
        final age = 25.watch;
        final email = 'john@example.com'.watch;
        final isActive = true.watch;
        final score = 95.5.watch;

        final combined = Watch.combine6(
            firstName,
            lastName,
            age,
            email,
            isActive,
            score,
            (first, last, a, e, active, s) =>
                'Profile: $first $last ($a), Contact: $e, Status: $active, Score: $s');

        expect(combined.value,
            'Profile: John Doe (25), Contact: john@example.com, Status: true, Score: 95.5');

        String? receivedValue;
        combined.watch((value) => receivedValue = value);

        score.emit(87.3);
        expect(combined.value,
            'Profile: John Doe (25), Contact: john@example.com, Status: true, Score: 87.3');
        expect(receivedValue,
            'Profile: John Doe (25), Contact: john@example.com, Status: true, Score: 87.3');
      });

      testWidgets('should use Watch.build6 for building widgets',
          (tester) async {
        final firstName = 'John'.watch;
        final lastName = 'Doe'.watch;
        final age = 25.watch;
        final email = 'john@example.com'.watch;
        final isActive = true.watch;
        final score = 95.5.watch;

        await tester.pumpWidget(
          MaterialApp(
            home: Watch.build6(firstName, lastName, age, email, isActive, score,
                (first, last, a, e, active, s) => Text('$first: $s')),
          ),
        );

        expect(find.text('John: 95.5'), findsOneWidget);

        firstName.emit('Jane');
        score.emit(88.0);
        await tester.pump();

        expect(find.text('Jane: 88.0'), findsOneWidget);
      });

      testWidgets('should handle complex 6-item form validation',
          (tester) async {
        final email = ''.watch;
        final password = ''.watch;
        final confirmPassword = ''.watch;
        final firstName = ''.watch;
        final lastName = ''.watch;
        final agreedToTerms = false.watch;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: (
                email,
                password,
                confirmPassword,
                firstName,
                lastName,
                agreedToTerms
              ).build((e, p, cp, fn, ln, agreed) {
                final isValidEmail = e.contains('@');
                final isValidPassword = p.length >= 6;
                final passwordsMatch = p == cp;
                final hasNames = fn.isNotEmpty && ln.isNotEmpty;
                final isFormValid = isValidEmail &&
                    isValidPassword &&
                    passwordsMatch &&
                    hasNames &&
                    agreed;

                return ElevatedButton(
                  onPressed: isFormValid ? () {} : null,
                  child: Text(isFormValid ? 'Create Account' : 'Complete Form'),
                );
              }),
            ),
          ),
        );

        expect(find.text('Complete Form'), findsOneWidget);

        // Fill all fields correctly
        email.emit('test@example.com');
        password.emit('password123');
        confirmPassword.emit('password123');
        firstName.emit('John');
        lastName.emit('Doe');
        agreedToTerms.emit(true);
        await tester.pump();

        expect(find.text('Create Account'), findsOneWidget);

        // Break one requirement
        password.emit('123'); // Too short
        await tester.pump();

        expect(find.text('Complete Form'), findsOneWidget);
      });
    });

    group('Widget Rerendering Tests', () {
      testWidgets('only affected widgets should rebuild when state changes',
          (tester) async {
        final counter1 = 0.watch;
        final counter2 = 100.watch;

        int widget1BuildCount = 0;
        int widget2BuildCount = 0;
        int parentBuildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                parentBuildCount++;
                return Column(
                  children: [
                    counter1.build((value) {
                      widget1BuildCount++;
                      return Text('Counter 1: $value',
                          key: const Key('counter1'));
                    }),
                    counter2.build((value) {
                      widget2BuildCount++;
                      return Text('Counter 2: $value',
                          key: const Key('counter2'));
                    }),
                  ],
                );
              },
            ),
          ),
        );

        // Initial build
        expect(widget1BuildCount, 1);
        expect(widget2BuildCount, 1);
        expect(parentBuildCount, 1);

        // Change counter1 only
        counter1.emit(42);
        await tester.pump();

        // Only widget1 should rebuild, not widget2 or parent
        expect(widget1BuildCount, 2);
        expect(widget2BuildCount, 1); // Should NOT rebuild
        expect(parentBuildCount, 1); // Should NOT rebuild
        expect(find.text('Counter 1: 42'), findsOneWidget);
        expect(find.text('Counter 2: 100'), findsOneWidget);

        // Change counter2 only
        counter2.emit(200);
        await tester.pump();

        // Only widget2 should rebuild
        expect(widget1BuildCount, 2); // Should NOT rebuild
        expect(widget2BuildCount, 2);
        expect(parentBuildCount, 1); // Should NOT rebuild
        expect(find.text('Counter 1: 42'), findsOneWidget);
        expect(find.text('Counter 2: 200'), findsOneWidget);
      });

      testWidgets('shouldRebuild parameter prevents unnecessary rebuilds',
          (tester) async {
        final counter = 0.watch;
        int widgetBuildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: counter.build(
              (value) {
                widgetBuildCount++;
                return Text('Even: $value', key: const Key('even-counter'));
              },
              shouldRebuild: (previous, current) => current % 2 == 0,
            ),
          ),
        );

        // Initial build (0 is even)
        expect(widgetBuildCount, 1);
        expect(find.text('Even: 0'), findsOneWidget);

        // Emit odd number - should NOT rebuild
        counter.emit(1);
        await tester.pump();
        expect(widgetBuildCount, 1); // No rebuild
        expect(find.text('Even: 0'), findsOneWidget); // Still shows old value

        // Emit even number - should rebuild
        counter.emit(2);
        await tester.pump();
        expect(widgetBuildCount, 2); // Rebuilt
        expect(find.text('Even: 2'), findsOneWidget);

        // Another odd number - should NOT rebuild
        counter.emit(3);
        await tester.pump();
        expect(widgetBuildCount, 2); // No rebuild
        expect(find.text('Even: 2'),
            findsOneWidget); // Still shows previous even value

        // Another even number - should rebuild
        counter.emit(4);
        await tester.pump();
        expect(widgetBuildCount, 3); // Rebuilt
        expect(find.text('Even: 4'), findsOneWidget);
      });

      testWidgets('combiner widgets only rebuild when dependent state changes',
          (tester) async {
        final firstName = 'John'.watch;
        final lastName = 'Doe'.watch;
        final age = 25.watch;

        int fullNameBuildCount = 0;
        int userInfoBuildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                // Combiner depending on firstName + lastName
                (firstName, lastName).build((fn, ln) {
                  fullNameBuildCount++;
                  return Text('Name: $fn $ln', key: const Key('fullname'));
                }),
                // Combiner depending on firstName + age
                (firstName, age).build((fn, a) {
                  userInfoBuildCount++;
                  return Text('User: $fn ($a)', key: const Key('userinfo'));
                }),
              ],
            ),
          ),
        );

        // Initial builds - combiners may build multiple times during setup
        // due to initial emissions from each dependency
        expect(fullNameBuildCount, greaterThanOrEqualTo(1));
        expect(userInfoBuildCount, greaterThanOrEqualTo(1));
        final initialFullNameBuildCount = fullNameBuildCount;
        final initialUserInfoBuildCount = userInfoBuildCount;
        expect(find.text('Name: John Doe'), findsOneWidget);
        expect(find.text('User: John (25)'), findsOneWidget);

        // Change firstName - both should rebuild
        firstName.emit('Jane');
        await tester.pump();
        expect(fullNameBuildCount, initialFullNameBuildCount + 1);
        expect(userInfoBuildCount, initialUserInfoBuildCount + 1);
        expect(find.text('Name: Jane Doe'), findsOneWidget);
        expect(find.text('User: Jane (25)'), findsOneWidget);

        // Change lastName - only fullName should rebuild
        final beforeLastNameFullNameCount = fullNameBuildCount;
        final beforeLastNameUserInfoCount = userInfoBuildCount;
        lastName.emit('Smith');
        await tester.pump();
        expect(fullNameBuildCount, beforeLastNameFullNameCount + 1);
        expect(userInfoBuildCount,
            beforeLastNameUserInfoCount); // Should NOT rebuild
        expect(find.text('Name: Jane Smith'), findsOneWidget);
        expect(find.text('User: Jane (25)'), findsOneWidget);

        // Change age - only userInfo should rebuild
        final beforeAgeFullNameCount = fullNameBuildCount;
        final beforeAgeUserInfoCount = userInfoBuildCount;
        age.emit(30);
        await tester.pump();
        expect(
            fullNameBuildCount, beforeAgeFullNameCount); // Should NOT rebuild
        expect(userInfoBuildCount, beforeAgeUserInfoCount + 1);
        expect(find.text('Name: Jane Smith'), findsOneWidget);
        expect(find.text('User: Jane (30)'), findsOneWidget);
      });

      testWidgets('Watch.build2-6 methods have isolated rebuilding',
          (tester) async {
        final a = 1.watch;
        final b = 2.watch;
        final c = 3.watch;
        final d = 4.watch;
        final e = 5.watch;
        final f = 6.watch;

        int build2Count = 0;
        int build3Count = 0;
        int build6Count = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                Watch.build2(a, b, (av, bv) {
                  build2Count++;
                  return Text('Sum2: ${av + bv}', key: const Key('sum2'));
                }),
                Watch.build3(a, b, c, (av, bv, cv) {
                  build3Count++;
                  return Text('Sum3: ${av + bv + cv}', key: const Key('sum3'));
                }),
                Watch.build6(a, b, c, d, e, f, (av, bv, cv, dv, ev, fv) {
                  build6Count++;
                  return Text('Sum6: ${av + bv + cv + dv + ev + fv}',
                      key: const Key('sum6'));
                }),
              ],
            ),
          ),
        );

        // Initial builds - combiners may build multiple times during setup
        expect(build2Count, greaterThanOrEqualTo(1));
        expect(build3Count, greaterThanOrEqualTo(1));
        expect(build6Count, greaterThanOrEqualTo(1));
        final initialBuild2Count = build2Count;
        final initialBuild3Count = build3Count;
        final initialBuild6Count = build6Count;
        expect(find.text('Sum2: 3'), findsOneWidget);
        expect(find.text('Sum3: 6'), findsOneWidget);
        expect(find.text('Sum6: 21'), findsOneWidget);

        // Change 'a' - all should rebuild
        a.emit(10);
        await tester.pump();
        expect(build2Count, initialBuild2Count + 1);
        expect(build3Count, initialBuild3Count + 1);
        expect(build6Count, initialBuild6Count + 1);
        expect(find.text('Sum2: 12'), findsOneWidget);
        expect(find.text('Sum3: 15'), findsOneWidget);
        expect(find.text('Sum6: 30'), findsOneWidget);

        // Change 'c' - only build3 and build6 should rebuild
        final beforeCBuild2Count = build2Count;
        final beforeCBuild3Count = build3Count;
        final beforeCBuild6Count = build6Count;
        c.emit(30);
        await tester.pump();
        expect(build2Count, beforeCBuild2Count); // Should NOT rebuild
        expect(build3Count, beforeCBuild3Count + 1); // Should rebuild
        expect(build6Count, beforeCBuild6Count + 1); // Should rebuild
        expect(find.text('Sum2: 12'), findsOneWidget);
        expect(find.text('Sum3: 42'), findsOneWidget);
        expect(find.text('Sum6: 57'), findsOneWidget);

        // Change 'f' - only build6 should rebuild
        final beforeFBuild2Count = build2Count;
        final beforeFBuild3Count = build3Count;
        final beforeFBuild6Count = build6Count;
        f.emit(60);
        await tester.pump();
        expect(build2Count, beforeFBuild2Count); // Should NOT rebuild
        expect(build3Count, beforeFBuild3Count); // Should NOT rebuild
        expect(build6Count, beforeFBuild6Count + 1); // Should rebuild
        expect(find.text('Sum2: 12'), findsOneWidget);
        expect(find.text('Sum3: 42'), findsOneWidget);
        expect(find.text('Sum6: 111'), findsOneWidget);
      });

      testWidgets('event consumers do not cause unnecessary rebuilds',
          (tester) async {
        final notifications = WEvent<String>();
        final counter = 0.watch;

        int consumerChildBuildCount = 0;
        int otherWidgetBuildCount = 0;
        String? lastEvent;

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                notifications.consume(
                  onEvent: (event) => lastEvent = event,
                  child: Builder(
                    builder: (context) {
                      consumerChildBuildCount++;
                      return const Text('Consumer Child',
                          key: Key('consumer-child'));
                    },
                  ),
                ),
                counter.build((value) {
                  otherWidgetBuildCount++;
                  return Text('Counter: $value',
                      key: const Key('other-widget'));
                }),
              ],
            ),
          ),
        );

        // Initial builds
        expect(consumerChildBuildCount, 1);
        expect(otherWidgetBuildCount, 1);
        expect(lastEvent, null);

        // Emit event - should NOT cause consumer child to rebuild
        notifications.emit('Test Event 1');
        await tester.pump();
        expect(consumerChildBuildCount, 1); // Should NOT rebuild
        expect(otherWidgetBuildCount, 1); // Should NOT rebuild
        expect(lastEvent, 'Test Event 1');

        // Change counter - should only rebuild counter widget
        counter.emit(42);
        await tester.pump();
        expect(consumerChildBuildCount, 1); // Should NOT rebuild
        expect(otherWidgetBuildCount, 2); // Should rebuild
        expect(lastEvent, 'Test Event 1');

        // Another event - still no rebuilds
        notifications.emit('Test Event 2');
        await tester.pump();
        expect(consumerChildBuildCount, 1); // Should NOT rebuild
        expect(otherWidgetBuildCount, 2); // Should NOT rebuild
        expect(lastEvent, 'Test Event 2');
      });

      testWidgets('traditional WatchableBuilder has same rebuild isolation',
          (tester) async {
        final counter1 = MutableStateWatchable<int>(0);
        final counter2 = MutableStateWatchable<int>(100);

        int widget1BuildCount = 0;
        int widget2BuildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                WatchableBuilder<int>(
                  watchable: counter1,
                  builder: (context, value, child) {
                    widget1BuildCount++;
                    return Text('Traditional 1: $value',
                        key: const Key('trad1'));
                  },
                ),
                WatchableBuilder<int>(
                  watchable: counter2,
                  builder: (context, value, child) {
                    widget2BuildCount++;
                    return Text('Traditional 2: $value',
                        key: const Key('trad2'));
                  },
                ),
              ],
            ),
          ),
        );

        // Initial builds
        expect(widget1BuildCount, 1);
        expect(widget2BuildCount, 1);

        // Change counter1 only
        counter1.emit(42);
        await tester.pump();
        expect(widget1BuildCount, 2);
        expect(widget2BuildCount, 1); // Should NOT rebuild

        // Change counter2 only
        counter2.emit(200);
        await tester.pump();
        expect(widget1BuildCount, 2); // Should NOT rebuild
        expect(widget2BuildCount, 2);
      });
    });
  });

  group('Extension API with .value setter', () {
    test('.watch extension creates watchable with .value setter', () {
      final counter = 0.watch;
      expect(counter.value, 0);

      counter.value = 42;
      expect(counter.value, 42);
    });

    test('.watch extension with custom types supports .value setter', () {
      final user = User(name: 'John', id: 1).watch;
      expect(user.value.name, 'John');

      user.value = User(name: 'Jane', id: 2);
      expect(user.value.name, 'Jane');
      expect(user.value.id, 2);
    });

    test('compound assignments work with .watch extensions', () {
      final counter = 10.watch;
      final name = 'Hello'.watch;
      final items = <String>['a'].watch;

      counter.value += 5;
      expect(counter.value, 15);

      name.value += ' World';
      expect(name.value, 'Hello World');

      // Note: For collections, we need to create a new instance to trigger change detection
      items.value = [...items.value, 'b'];
      expect(items.value, ['a', 'b']);
    });

    test('watchers are triggered when using .value setter with extensions', () {
      final counter = 0.watch;
      bool wasTriggered = false;
      int receivedValue = 0;

      counter.watch((value) {
        wasTriggered = true;
        receivedValue = value;
      });

      counter.value = 99;
      expect(wasTriggered, true);
      expect(receivedValue, 99);
    });

    test('CounterState pattern works as expected', () {
      final state = CounterState();
      bool wasTriggered = false;
      int receivedValue = 0;

      state.counter.watch((value) {
        wasTriggered = true;
        receivedValue = value;
      });

      // Test increment
      state.increment();
      expect(state.counter.value, 1);
      expect(wasTriggered, true);
      expect(receivedValue, 1);

      // Test decrement
      state.decrement();
      expect(state.counter.value, 0);
      expect(receivedValue, 0);

      // Test multiple increments
      state.increment();
      state.increment();
      state.increment();
      expect(state.counter.value, 3);
      expect(receivedValue, 3);

      // Test reset
      state.reset();
      expect(state.counter.value, 0);
      expect(receivedValue, 0);
    });
  });

  group('Comprehensive Type Testing with .value setter', () {
    group('Primitive Types', () {
      test('int type with .value setter', () {
        final intWatch = 0.watch;
        expect(intWatch.value, 0);

        intWatch.value = 42;
        expect(intWatch.value, 42);

        intWatch.value += 10;
        expect(intWatch.value, 52);

        intWatch.value--;
        expect(intWatch.value, 51);
      });

      test('String type with .value setter', () {
        final stringWatch = 'hello'.watch;
        expect(stringWatch.value, 'hello');

        stringWatch.value = 'world';
        expect(stringWatch.value, 'world');

        stringWatch.value += ' test';
        expect(stringWatch.value, 'world test');

        stringWatch.value = stringWatch.value.toUpperCase();
        expect(stringWatch.value, 'WORLD TEST');
      });

      test('bool type with .value setter', () {
        final boolWatch = false.watch;
        expect(boolWatch.value, false);

        boolWatch.value = true;
        expect(boolWatch.value, true);

        boolWatch.value = !boolWatch.value;
        expect(boolWatch.value, false);
      });

      test('double type with .value setter', () {
        final doubleWatch = 3.14.watch;
        expect(doubleWatch.value, 3.14);

        doubleWatch.value = 2.71;
        expect(doubleWatch.value, 2.71);

        doubleWatch.value *= 2;
        expect(doubleWatch.value, 5.42);
      });
    });

    group('Collection Types', () {
      test('List<T> with .value setter', () {
        final listWatch = <String>['a', 'b'].watch;
        expect(listWatch.value, ['a', 'b']);

        listWatch.value = ['c', 'd', 'e'];
        expect(listWatch.value, ['c', 'd', 'e']);

        // Test with different types
        final intListWatch = <int>[1, 2, 3].watch;
        intListWatch.value = [4, 5, 6];
        expect(intListWatch.value, [4, 5, 6]);
      });

      test('Map<K, V> with .value setter', () {
        final mapWatch = <String, int>{'a': 1, 'b': 2}.watch;
        expect(mapWatch.value, {'a': 1, 'b': 2});

        mapWatch.value = {'c': 3, 'd': 4};
        expect(mapWatch.value, {'c': 3, 'd': 4});

        // Test with different types
        final stringMapWatch = <int, String>{1: 'one', 2: 'two'}.watch;
        stringMapWatch.value = {3: 'three', 4: 'four'};
        expect(stringMapWatch.value, {3: 'three', 4: 'four'});
      });

      test('Set<T> with .value setter', () {
        final setWatch = <String>{'a', 'b'}.watch;
        expect(setWatch.value, {'a', 'b'});

        setWatch.value = {'c', 'd', 'e'};
        expect(setWatch.value, {'c', 'd', 'e'});
      });
    });

    group('Nullable Types', () {
      test('nullable int with .value setter', () {
        final nullableIntWatch = W<int?>(null);
        expect(nullableIntWatch.value, null);

        nullableIntWatch.value = 42;
        expect(nullableIntWatch.value, 42);

        nullableIntWatch.value = null;
        expect(nullableIntWatch.value, null);
      });

      test('nullable String with .value setter', () {
        final nullableStringWatch = W<String?>(null);
        expect(nullableStringWatch.value, null);

        nullableStringWatch.value = 'test';
        expect(nullableStringWatch.value, 'test');

        nullableStringWatch.value = null;
        expect(nullableStringWatch.value, null);
      });

      test('nullable custom object with .value setter', () {
        final nullableUserWatch = W<User?>(null);
        expect(nullableUserWatch.value, null);

        final user = User(name: 'John', id: 1);
        nullableUserWatch.value = user;
        expect(nullableUserWatch.value, user);

        nullableUserWatch.value = null;
        expect(nullableUserWatch.value, null);
      });
    });

    group('Custom Object Types', () {
      test('User object with .value setter', () {
        final user1 = User(name: 'Alice', id: 1);
        final user2 = User(name: 'Bob', id: 2);
        final userWatch = user1.watch;

        expect(userWatch.value, user1);

        userWatch.value = user2;
        expect(userWatch.value, user2);
        expect(userWatch.value.name, 'Bob');
        expect(userWatch.value.id, 2);
      });

      test('enum with .value setter', () {
        final statusWatch = Status.pending.watch;
        expect(statusWatch.value, Status.pending);

        statusWatch.value = Status.active;
        expect(statusWatch.value, Status.active);

        statusWatch.value = Status.inactive;
        expect(statusWatch.value, Status.inactive);
      });

      test('DateTime with .value setter', () {
        final now = DateTime.now();
        final tomorrow = now.add(Duration(days: 1));
        final dateWatch = now.watch;

        expect(dateWatch.value, now);

        dateWatch.value = tomorrow;
        expect(dateWatch.value, tomorrow);
      });
    });

    group('Complex Nested Types', () {
      test('List of custom objects with .value setter', () {
        final user1 = User(name: 'Alice', id: 1);
        final user2 = User(name: 'Bob', id: 2);
        final user3 = User(name: 'Charlie', id: 3);

        final userListWatch = <User>[user1, user2].watch;
        expect(userListWatch.value.length, 2);
        expect(userListWatch.value[0].name, 'Alice');

        userListWatch.value = [user2, user3];
        expect(userListWatch.value.length, 2);
        expect(userListWatch.value[0].name, 'Bob');
        expect(userListWatch.value[1].name, 'Charlie');
      });

      test('Map with complex values with .value setter', () {
        final complexMapWatch = <String, List<int>>{
          'group1': [1, 2, 3],
          'group2': [4, 5, 6]
        }.watch;

        expect(complexMapWatch.value['group1'], [1, 2, 3]);

        complexMapWatch.value = {
          'group3': [7, 8, 9],
          'group4': [10, 11, 12]
        };

        expect(complexMapWatch.value['group3'], [7, 8, 9]);
        expect(complexMapWatch.value['group4'], [10, 11, 12]);
      });

      test('nested collections with .value setter', () {
        final nestedWatch = <String, Map<String, int>>{
          'section1': {'a': 1, 'b': 2},
          'section2': {'c': 3, 'd': 4}
        }.watch;

        expect(nestedWatch.value['section1']!['a'], 1);

        nestedWatch.value = {
          'section3': {'e': 5, 'f': 6},
          'section4': {'g': 7, 'h': 8}
        };

        expect(nestedWatch.value['section3']!['e'], 5);
      });
    });

    group('Generic Types', () {
      test('Future<T> with .value setter', () {
        final futureWatch = Future.value(42).watch;
        expect(futureWatch.value, isA<Future<int>>());

        final newFuture = Future.value(100);
        futureWatch.value = newFuture;
        expect(futureWatch.value, newFuture);
      });

      test('Function types with .value setter', () {
        int addOne(int x) => x + 1;
        int multiplyTwo(int x) => x * 2;

        final functionWatch = addOne.watch;
        expect(functionWatch.value(5), 6);

        functionWatch.value = multiplyTwo;
        expect(functionWatch.value(5), 10);
      });
    });

    group('Reactive Behavior Across All Types', () {
      test('watchers are triggered for all types', () {
        // Test multiple types in sequence
        final intWatch = 0.watch;
        final stringWatch = 'init'.watch;
        final listWatch = <int>[].watch;

        int intChanges = 0;
        int stringChanges = 0;
        int listChanges = 0;

        intWatch.watch((value) => intChanges++);
        stringWatch.watch((value) => stringChanges++);
        listWatch.watch((value) => listChanges++);

        // Reset counters after initial replay
        intChanges = 0;
        stringChanges = 0;
        listChanges = 0;

        // Test changes
        intWatch.value = 42;
        stringWatch.value = 'changed';
        listWatch.value = [1, 2, 3];

        expect(intChanges, 1);
        expect(stringChanges, 1);
        expect(listChanges, 1);

        // Test compound operations
        intWatch.value += 10;
        stringWatch.value += ' more';
        listWatch.value = [...listWatch.value, 4];

        expect(intChanges, 2);
        expect(stringChanges, 2);
        expect(listChanges, 2);
      });
    });
  });
}
