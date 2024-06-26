import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchable/watchable.dart';


void main() {
  group('Watchable', () {
    test('should initialize with the given value', () {
      final watchable = Watchable<int>(5);
      expect(watchable.value, equals(5));
    });

    test('should notify listeners when value changes', () {
      final watchable = Watchable<int>(0);
      int callCount = 0;

      watchable.addListener(() {
        callCount++;
      });

      watchable.value = 1;
      expect(callCount, equals(1));

      watchable.value = 2;
      expect(callCount, equals(2));
    });

    test('should not notify listeners when setting the same value', () {
      final watchable = Watchable<int>(0);
      int callCount = 0;

      watchable.addListener(() {
        callCount++;
      });

      watchable.value = 0;
      expect(callCount, equals(0));
    });

    test('should reset to initial value', () {
      final watchable = Watchable<int>(0);
      watchable.value = 5;
      watchable.reset();
      expect(watchable.value, equals(0));
    });
  });

  group('WatchableBuilder', () {
    testWidgets('should rebuild when Watchable value changes',
        (WidgetTester tester) async {
      final watchable = Watchable<int>(0);

      await tester.pumpWidget(
        WatchableBuilder<int>(
          watchable: watchable,
          builder: (context, value, child) => Text('$value'),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      watchable.value = 1;
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should combine multiple Watchables',
        (WidgetTester tester) async {
      final watchable1 = Watchable<int>(0);
      final watchable2 = Watchable<String>('');

      await tester.pumpWidget(
        WatchableBuilder.from2<int, String, String>(
          watchable1: watchable1,
          watchable2: watchable2,
          combiner: (a, b) => '$a-$b',
          builder: (context, value, child) => Text(value),
        ),
      );

      expect(find.text('0-'), findsOneWidget);

      watchable1.value = 1;
      watchable2.value = 'test';
      await tester.pump();

      expect(find.text('1-test'), findsOneWidget);
    });
  });
}
