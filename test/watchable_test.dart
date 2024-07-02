import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:watchable/watchable.dart';
// Update with the correct path

void main() {
  group('Watchable', () {
    test('emit value to subscribers', () {
      final shared = Watchable<int>();
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
      final shared = Watchable<int>(replay: 2);
      shared.emit(1);
      shared.emit(2);
      expect(shared.replayCache, [1, 2]);
    });

    test('replay cache respects buffer size', () {
      final shared = Watchable<int>(replay: 1);
      shared.emit(1);
      shared.emit(2);
      expect(shared.replayCache, [2]);
    });

    test('new subscriber receives replayed values', () {
      final shared = Watchable<int>(replay: 2);
      shared.emit(1);
      shared.emit(2);
      List<int> receivedValues = [];
      shared.watch((value) {
        receivedValues.add(value);
      });
      expect(receivedValues, [1, 2]);
    });

    test('unwatch removes subscriber', () {
      final shared = Watchable<int>();
      void watcher(int value) {}
      shared.watch(watcher);
      shared.unwatch(watcher);
      expect(shared.watchers.isEmpty, true);
    });

    test('dispose clears subscribers and replay cache', () {
      final shared = Watchable<int>(replay: 2);
      shared.emit(1);
      shared.dispose();
      expect(shared.watchers.isEmpty, true);
      expect(shared.replayCache.isEmpty, true);
    });
  });

  group('StateWatchable', () {
    test('initial value is emitted', () {
      final watchable = StateWatchable<int>(0);
      expect(watchable.value, 0);
    });

    test('value does not change if compare function returns false', () {
      final watchable =
          StateWatchable<int>(0, compare: (old, current) => old == current);
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
      final watchable = StateWatchable<List<int>>([1, 2, 3]);
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
      final watchable = StateWatchable<Map<String, int>>({'a': 1});
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
      final watchable = StateWatchable<int>(0);
      watchable.dispose();
      expect(watchable.replayCache.isEmpty, true);
    });
  });

  group('CombineLatestWatchable', () {
    test('combines initial values correctly', () {
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      expect(combined.value, 3);
    });

    test('updates combined value when one of the sources changes', () {
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      combined.dispose();
      expect(watchable1.watchers.isEmpty, true);
      expect(watchable2.watchers.isEmpty, true);
    });
  });

  group('WatchableBuilder', () {
    testWidgets('builds with initial value', (WidgetTester tester) async {
      final watchable = StateWatchable<int>(0);
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
      final watchable = StateWatchable<int>(0);
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
      final watchable = StateWatchable<int>(0);
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
      final watchable1 = StateWatchable<int>(0);
      final watchable2 = StateWatchable<int>(1);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final watchable3 = StateWatchable<int>(3);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final watchable3 = StateWatchable<int>(3);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final watchable3 = StateWatchable<int>(3);
      final watchable4 = StateWatchable<int>(4);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final watchable3 = StateWatchable<int>(3);
      final watchable4 = StateWatchable<int>(4);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final watchable3 = StateWatchable<int>(3);
      final watchable4 = StateWatchable<int>(4);
      final watchable5 = StateWatchable<int>(5);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final watchable3 = StateWatchable<int>(3);
      final watchable4 = StateWatchable<int>(4);
      final watchable5 = StateWatchable<int>(5);
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
    late StateWatchable<int> watchable;
    late Widget testWidget;

    setUp(() {
      watchable = StateWatchable<int>(0);
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
      final anotherWatchable = StateWatchable<int>(0);
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
    late StateWatchable<int> watchable1;
    late StateWatchable<int> watchable2;
    late Widget testWidget;

    setUp(() {
      watchable1 = StateWatchable<int>(0);
      watchable2 = StateWatchable<int>(0);
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
    late Watchable<int> watchable;
    late int callbackValue;

    setUp(() {
      watchable = Watchable<int>();
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

      expect(watchable.watchers.length, 1);

      watchable.emit(42);
      await tester.pump();

      expect(callbackValue, 42);

      await tester.pumpWidget(Container()); // Unmount the widget
      expect(watchable.watchers.length, 0);
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

      expect(watchable.watchers.length, 1);

      await tester.pumpWidget(Container()); // Unmount the widget
      expect(watchable.watchers.length, 0);
    });
  });

  group('Watchable Negative Tests', () {
    test('emit value without subscribers', () {
      final shared = Watchable<int>();
      expect(() => shared.emit(1), returnsNormally);
    });

    test('unwatch non-existent subscriber', () {
      final shared = Watchable<int>();
      void watcher(int value) {}
      expect(() => shared.unwatch(watcher), returnsNormally);
    });

    test('dispose already disposed watchable', () {
      final shared = Watchable<int>();
      shared.dispose();
      expect(() => shared.dispose(), returnsNormally);
    });
  });

  group('StateWatchable Negative Tests', () {
    test('emit value without subscribers', () {
      final watchable = StateWatchable<int>(0);
      expect(() => watchable.emit(1), returnsNormally);
    });

    test('unwatch non-existent subscriber', () {
      final watchable = StateWatchable<int>(0);
      void watcher(int value) {}
      expect(() => watchable.unwatch(watcher), returnsNormally);
    });

    test('dispose already disposed watchable', () {
      final watchable = StateWatchable<int>(0);
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
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      expect(() => combined.emit(3), returnsNormally);
    });

    test('unwatch non-existent subscriber', () {
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      void watcher(int value) {}
      expect(() => combined.unwatch(watcher), returnsNormally);
    });

    test('dispose already disposed watchable', () {
      final watchable1 = StateWatchable<int>(1);
      final watchable2 = StateWatchable<int>(2);
      final combined = CombineLatestWatchable<int, int>(
        [watchable1, watchable2],
        (values) => values.reduce((a, b) => a + b),
      );
      combined.dispose();
      expect(() => combined.dispose(), returnsNormally);
    });
  });

  group('WatchableConsumer Negative Tests', () {
    late Watchable<int> watchable;

    setUp(() {
      watchable = Watchable<int>();
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
      expect(watchable.watchers.length, 0);

      // Dispose again
      await tester.pumpWidget(Container());
      expect(watchable.watchers.length, 0);
    });
  });

  group('WatchableBuilder Negative Tests', () {
    testWidgets('should handle dispose already disposed widget gracefully',
        (WidgetTester tester) async {
      final watchable = StateWatchable<int>(0);

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
      expect(watchable.watchers.isEmpty, true);

      // Dispose again
      await tester.pumpWidget(Container());
      expect(watchable.watchers.isEmpty, true);
    });

    testWidgets('should handle unwatch non-existent subscriber gracefully',
        (WidgetTester tester) async {
      final watchable = StateWatchable<int>(0);

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
      expect(watchable.watchers.isEmpty, true);

      // Unwatch non-existent subscriber
      void nonExistentWatcher(int value) {}
      expect(() => watchable.unwatch(nonExistentWatcher), returnsNormally);
    });
  });

  group('WatchableBuilder Dispose Negative Tests', () {
    late StateWatchable<int> watchable;
    late Widget testWidget;

    setUp(() {
      watchable = StateWatchable<int>(0);
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
      final anotherWatchable = StateWatchable<int>(0);
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
    late StateWatchable<int> watchable1;
    late StateWatchable<int> watchable2;
    late Widget testWidget;

    setUp(() {
      watchable1 = StateWatchable<int>(0);
      watchable2 = StateWatchable<int>(0);
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
      final shared = Watchable<int>();
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
      final shared = Watchable<int?>();
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
      final shared = Watchable<int>();
      void watcher(int value) {}

      for (int i = 0; i < 100; i++) {
        shared.watch(watcher);
        shared.unwatch(watcher);
      }

      expect(shared.watchers.isEmpty, true);
    });

    test('handles concurrent emissions', () async {
      final shared = Watchable<int>();
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
      final shared = Watchable<int>();
      shared.dispose();
      expect(() => shared.dispose(), returnsNormally);
    });

    test('handles unwatch non-existent subscriber gracefully', () {
      final shared = Watchable<int>();
      void watcher(int value) {}
      expect(() => shared.unwatch(watcher), returnsNormally);
    });
  });
}
