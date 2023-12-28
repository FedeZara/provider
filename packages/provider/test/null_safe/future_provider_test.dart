import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'common.dart';

class ErrorBuilderMock<T> extends Mock {
  ErrorBuilderMock(this.fallback);

  final T fallback;

  T call(BuildContext? context, Object? error) {
    return super.noSuchMethod(
      Invocation.method(#call, [context, error]),
      returnValue: fallback,
      returnValueForMissingStub: fallback,
    ) as T;
  }
}

void main() {
  testWidgets('works with MultiProvider', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          FutureProvider.value(
            initialData: 0,
            value: Future.value(42),
          ),
        ],
        child: TextOf<int>(),
      ),
    );

    expect(find.text('0'), findsOneWidget);

    await Future.microtask(tester.pump);

    expect(find.text('42'), findsOneWidget);
  });

  testWidgets(
    '(catchError) previous future completes after transition is no-op',
    (tester) async {
      final controller = Completer<int>();
      final controller2 = Completer<int>();

      await tester.pumpWidget(
        FutureProvider.value(
          initialData: 0,
          value: controller.future,
          child: TextOf<int>(),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.pumpWidget(
        FutureProvider.value(
          initialData: 1,
          value: controller2.future,
          child: TextOf<int>(),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      controller.complete(1);
      await Future.microtask(tester.pump);

      expect(find.text('0'), findsOneWidget);

      controller2.complete(2);

      await Future.microtask(tester.pump);

      expect(find.text('0'), findsNothing);
      expect(find.text('2'), findsOneWidget);
    },
  );
  testWidgets(
    'previous future completes after transition is no-op',
    (tester) async {
      final controller = Completer<int>();
      final controller2 = Completer<int>();

      await tester.pumpWidget(
        FutureProvider.value(
          initialData: 0,
          value: controller.future,
          child: TextOf<int>(),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.pumpWidget(
        FutureProvider.value(
          initialData: 1,
          value: controller2.future,
          child: TextOf<int>(),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      controller.complete(1);
      await Future.microtask(tester.pump);

      expect(find.text('0'), findsOneWidget);

      controller2.complete(2);
      await Future.microtask(tester.pump);

      expect(find.text('2'), findsOneWidget);
    },
  );
  testWidgets(
    'transition from future to future preserve state',
    (tester) async {
      final controller = Completer<int>();
      final controller2 = Completer<int>();

      await tester.pumpWidget(
        FutureProvider.value(
          initialData: 0,
          value: controller.future,
          child: TextOf<int>(),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      controller.complete(1);

      await Future.microtask(tester.pump);

      expect(find.text('1'), findsOneWidget);

      await tester.pumpWidget(
        FutureProvider.value(
          initialData: 0,
          value: controller2.future,
          child: TextOf<int>(),
        ),
      );

      expect(find.text('1'), findsOneWidget);

      controller2.complete(2);
      await Future.microtask(tester.pump);

      expect(find.text('2'), findsOneWidget);
    },
  );
  testWidgets('throws if future has error and catchError is missing',
      (tester) async {
    final controller = Completer<int>();

    await tester.pumpWidget(
      FutureProvider.value(
        initialData: 0,
        value: controller.future,
        child: TextOf<int>(),
      ),
    );

    controller.completeError(42);
    await Future.microtask(tester.pump);

    final dynamic exception = tester.takeException();
    expect(exception, isFlutterError);
    expect(exception.toString(), equals('''
An exception was throw by Future<int> listened by
FutureProvider<int>, but no `catchError` was provided.

Exception:
42
'''));
  });

  testWidgets('calls catchError if present and future has error',
      (tester) async {
    final controller = Completer<int>();
    final catchError = ErrorBuilderMock<int>(0);
    when(catchError(any, 42)).thenReturn(42);

    await tester.pumpWidget(
      FutureProvider.value(
        initialData: null,
        value: controller.future,
        catchError: catchError,
        child: TextOf<int?>(),
      ),
    );

    expect(find.text('null'), findsOneWidget);

    controller.completeError(42);

    await Future.microtask(tester.pump);

    expect(find.text('42'), findsOneWidget);
    verify(catchError(argThat(isNotNull), 42)).called(1);
    verifyNoMoreInteractions(catchError);
  });

  testWidgets('works with null', (tester) async {
    await tester.pumpWidget(
      FutureProvider<int>.value(
        initialData: 42,
        value: null,
        child: TextOf<int>(),
      ),
    );

    expect(find.text('42'), findsOneWidget);

    await tester.pumpWidget(Container());
  });

  testWidgets('create and dispose future with builder', (tester) async {
    final completer = Completer<int>();

    await tester.pumpWidget(
      FutureProvider<int>(
        initialData: 42,
        create: (_) => completer.future,
        child: TextOf<int>(),
      ),
    );

    expect(find.text('42'), findsOneWidget);

    completer.complete(24);

    await Future.microtask(tester.pump);

    expect(find.text('24'), findsOneWidget);
  });

  group('FutureProxyProvider', () {
    testWidgets(
      'transition from future to future in proxy preserve state',
      (tester) async {
        final controller = Completer<int>();
        final controller2 = Completer<int>();

        await tester.pumpWidget(
          FutureProxyProvider0<int>(
            initialData: 0,
            create: (context) => controller.future,
            update: (_, __) => controller.future,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('0'), findsOneWidget);

        controller.complete(1);

        await Future.microtask(tester.pump);

        expect(find.text('1'), findsOneWidget);

        await tester.pumpWidget(
          FutureProxyProvider0<int>(
            initialData: 0,
            create: (context) => controller2.future,
            update: (_, __) => controller2.future,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('1'), findsOneWidget);

        controller2.complete(2);
        await Future.microtask(tester.pump);

        expect(find.text('2'), findsOneWidget);
      },
    );

    testWidgets(
      'update works without create',
      (tester) async {
        final controller = Completer<int>();
        final controller2 = Completer<int>();

        await tester.pumpWidget(
          FutureProxyProvider0<int>(
            initialData: 0,
            update: (_, __) => controller.future,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('0'), findsOneWidget);

        controller.complete(1);

        await Future.microtask(tester.pump);

        expect(find.text('1'), findsOneWidget);

        await tester.pumpWidget(
          FutureProxyProvider0<int>(
            initialData: 0,
            update: (_, __) => controller2.future,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('1'), findsOneWidget);

        controller2.complete(2);
        await Future.microtask(tester.pump);

        expect(find.text('2'), findsOneWidget);
      },
    );

    testWidgets(
      'previous future completes after transition is no-op',
      (tester) async {
        final controller = Completer<int>();
        final controller2 = Completer<int>();

        await tester.pumpWidget(
          FutureProxyProvider0<int>(
            initialData: 0,
            create: (context) => controller.future,
            update: (_, __) => controller.future,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('0'), findsOneWidget);

        await tester.pumpWidget(
          FutureProxyProvider0<int>(
            initialData: 0,
            create: (context) => controller2.future,
            update: (_, __) => controller2.future,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('0'), findsOneWidget);

        controller.complete(1);
        await Future.microtask(tester.pump);

        expect(find.text('0'), findsOneWidget);

        controller2.complete(2);

        await Future.microtask(tester.pump);

        expect(find.text('0'), findsNothing);
        expect(find.text('2'), findsOneWidget);
      },
    );
  });

  group('FutureProxyProvider variants', () {
    final a = A();
    final b = B();
    final c = C();
    final d = D();
    final e = E();
    final f = F();

    final combinedConsumerMock = MockCombinedBuilder();
    setUp(() => when(combinedConsumerMock(any)).thenReturn(Container()));
    tearDown(() {
      clearInteractions(combinedConsumerMock);
    });

    final mockConsumer = Consumer<Combined>(
      builder: (context, combined, child) {
        return combinedConsumerMock(combined);
      },
    );

    InheritedContext<Combined?> findInheritedProvider() =>
        findInheritedContext<Combined>();
    testWidgets('FutureProxyProvider0', (tester) async {
      final controller = Completer<Combined>();

      Future<Combined>? prevFuture;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            Provider.value(value: e),
            Provider.value(value: f),
            FutureProxyProvider0<Combined>(
              initialData: const Combined(),
              create: (_) => controller.future,
              update: (context, previous) {
                controller.complete(Combined(
                  context,
                  null,
                  Provider.of<A>(context),
                  Provider.of<B>(context),
                  Provider.of<C>(context),
                  Provider.of<D>(context),
                  Provider.of<E>(context),
                  Provider.of<F>(context),
                ));
                prevFuture = previous;
                return controller.future;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await Future.microtask(tester.pump);

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          Combined(
            context,
            null,
            a,
            b,
            c,
            d,
            e,
            f,
          ),
        ),
      ).called(1);
      expect(prevFuture, controller.future);
    });

    testWidgets('FutureProxyProvider', (tester) async {
      final controller = Completer<Combined>();

      Future<Combined>? prevFuture;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            FutureProxyProvider<A, Combined>(
              initialData: const Combined(),
              create: (_) => controller.future,
              update: (context, a, previous) {
                controller.complete(Combined(
                  context,
                  null,
                  a,
                ));
                prevFuture = previous;
                return controller.future;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await Future.microtask(tester.pump);

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          Combined(
            context,
            null,
            a,
          ),
        ),
      ).called(1);
      expect(prevFuture, controller.future);
    });

    testWidgets('FutureProxyProvider2', (tester) async {
      final controller = Completer<Combined>();

      Future<Combined>? prevFuture;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            FutureProxyProvider2<A, B, Combined>(
              initialData: const Combined(),
              create: (_) => controller.future,
              update: (context, a, b, previous) {
                controller.complete(Combined(
                  context,
                  null,
                  a,
                  b,
                ));
                prevFuture = previous;
                return controller.future;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await Future.microtask(tester.pump);

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          Combined(
            context,
            null,
            a,
            b,
          ),
        ),
      ).called(1);
      expect(prevFuture, controller.future);
    });

    testWidgets('FutureProxyProvider3', (tester) async {
      final controller = Completer<Combined>();

      Future<Combined>? prevFuture;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            FutureProxyProvider3<A, B, C, Combined>(
              initialData: const Combined(),
              create: (_) => controller.future,
              update: (context, a, b, c, previous) {
                controller.complete(Combined(
                  context,
                  null,
                  a,
                  b,
                  c,
                ));
                prevFuture = previous;
                return controller.future;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await Future.microtask(tester.pump);

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          Combined(
            context,
            null,
            a,
            b,
            c,
          ),
        ),
      ).called(1);
      expect(prevFuture, controller.future);
    });

    testWidgets('FutureProxyProvider4', (tester) async {
      final controller = Completer<Combined>();

      Future<Combined>? prevFuture;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            FutureProxyProvider4<A, B, C, D, Combined>(
              initialData: const Combined(),
              create: (_) => controller.future,
              update: (context, a, b, c, d, previous) {
                controller.complete(Combined(
                  context,
                  null,
                  a,
                  b,
                  c,
                  d,
                ));
                prevFuture = previous;
                return controller.future;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await Future.microtask(tester.pump);

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          Combined(
            context,
            null,
            a,
            b,
            c,
            d,
          ),
        ),
      ).called(1);
      expect(prevFuture, controller.future);
    });

    testWidgets('FutureProxyProvider5', (tester) async {
      final controller = Completer<Combined>();

      Future<Combined>? prevFuture;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            Provider.value(value: e),
            FutureProxyProvider5<A, B, C, D, E, Combined>(
              initialData: const Combined(),
              create: (_) => controller.future,
              update: (context, a, b, c, d, e, previous) {
                controller.complete(Combined(
                  context,
                  null,
                  a,
                  b,
                  c,
                  d,
                  e,
                ));
                prevFuture = previous;
                return controller.future;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await Future.microtask(tester.pump);

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          Combined(
            context,
            null,
            a,
            b,
            c,
            d,
            e,
          ),
        ),
      ).called(1);
      expect(prevFuture, controller.future);
    });

    testWidgets('FutureProxyProvider6', (tester) async {
      final controller = Completer<Combined>();

      Future<Combined>? prevFuture;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            Provider.value(value: e),
            Provider.value(value: f),
            FutureProxyProvider6<A, B, C, D, E, F, Combined>(
              initialData: const Combined(),
              create: (_) => controller.future,
              update: (context, a, b, c, d, e, f, previous) {
                controller.complete(Combined(
                  context,
                  null,
                  a,
                  b,
                  c,
                  d,
                  e,
                  f,
                ));
                prevFuture = previous;
                return controller.future;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await Future.microtask(tester.pump);

      final context = findInheritedProvider();

      verify(
        combinedConsumerMock(
          Combined(
            context,
            null,
            a,
            b,
            c,
            d,
            e,
            f,
          ),
        ),
      ).called(1);
      expect(prevFuture, controller.future);
    });
  });
}
