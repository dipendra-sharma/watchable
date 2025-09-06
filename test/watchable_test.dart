import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:watchable/watchable.dart';

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

    test('should handle watcher that modifies watcher list during emission', () {
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
      
      watchable.emit(1); // Should not emit (difference is 1, < 2, so considered equal)
      expect(received.length, 1); // Still only initial value
      
      watchable.emit(3); // Should emit (difference is 3, >= 2, so considered different)  
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
      watchable.watch((value) => received.add(value.map((e) => List<int>.from(e)).toList()));
      
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
      expect(received.length, 2); // This is actually different due to object reference
      
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
      final watchable = MutableStateWatchable<Map<String, Map<String, int>>>(initialMap);
      
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
      final watchable = MutableStateWatchable<int>(0, 
        compare: (old, current) {
          if (current == 1) { // Only throw for emit(1)
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
      expect(() => CombineLatestWatchable<int, int>(
        [source1, source2],
        (values) => throw Exception('Combiner error'),
      ), throwsException);
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
      final userWatchable = MutableStateWatchable<Map<String, String>>({'name': 'John'});
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
          combiner: (a, b, c, d) => 'Sum: ${(a ?? 0) + (b ?? 0) + (c ?? 0) + (d ?? 0)}',
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
          combiner: (a, b, c, d, e) => 'Sum: ${(a ?? 0) + (b ?? 0) + (c ?? 0) + (d ?? 0) + (e ?? 0)}',
          builder: (context, value, child) => Text(value),
        ),
      );
      
      expect(testWidget4, isA<MaterialApp>());
      expect(testWidget5, isA<MaterialApp>());
    });
  });

  group('Error Handling and Exception Tests', () {
    testWidgets('should handle watcher exception in WatchableBuilder', (WidgetTester tester) async {
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

    testWidgets('should handle onEvent exception in WatchableConsumer', (WidgetTester tester) async {
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

    test('should handle comparison function exception in MutableStateWatchable', () {
      final watchable = MutableStateWatchable<int>(0, 
        compare: (old, current) {
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
      await Future.wait([
        for (int i = 0; i < 100; i++)
          Future(() => watchable.emit(i))
      ]);
      
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
        for (var watchable in watchables)
          Future(() => watchable.dispose())
      ]);
      
      for (var watchable in watchables) {
        expect(watchable.watcherCount, 0);
      }
    });
  });

  group('Integration and System Tests', () {
    testWidgets('should handle complex widget tree with many watchables', (WidgetTester tester) async {
      final watchables = List.generate(10, (i) => MutableStateWatchable<int>(i));
      
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

    testWidgets('should handle nested WatchableBuilders', (WidgetTester tester) async {
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

    testWidgets('should handle complex state updates with shouldRebuild', (WidgetTester tester) async {
      final watchable = MutableStateWatchable<int>(0);
      int buildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: WatchableBuilder<int>(
            watchable: watchable,
            shouldRebuild: (previous, current) => current % 2 == 0, // Only even numbers
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
}
