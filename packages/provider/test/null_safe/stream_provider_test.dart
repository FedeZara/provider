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
          StreamProvider(
            initialData: 0,
            create: (_) => Stream.value(42),
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
    'transition from stream to stream preserve state',
    (tester) async {
      final controller = StreamController<int>(sync: true);
      final controller2 = StreamController<int>(sync: true);

      await tester.pumpWidget(
        StreamProvider.value(
          initialData: 0,
          value: controller.stream,
          child: TextOf<int>(),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      controller.add(1);

      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      await tester.pumpWidget(
        StreamProvider.value(
          initialData: 0,
          value: controller2.stream,
          child: TextOf<int>(),
        ),
      );

      expect(find.text('1'), findsOneWidget);

      controller.add(0);
      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      controller2.add(2);
      await tester.pump();

      expect(find.text('2'), findsOneWidget);

      await tester.pump();
      // ignore: unawaited_futures
      controller.close();
      // ignore: unawaited_futures
      controller2.close();
    },
  );
  testWidgets('throws if stream has error and catchError is missing',
      (tester) async {
    final controller = StreamController<int>();

    await tester.pumpWidget(
      StreamProvider.value(
        initialData: -1,
        value: controller.stream,
        child: TextOf<int>(),
      ),
    );

    controller.addError(42);
    await Future.microtask(tester.pump);

    final dynamic exception = tester.takeException();
    expect(exception, isFlutterError);
    expect(exception.toString(), equals('''
An exception was throw by _ControllerStream<int> listened by
StreamProvider<int>, but no `catchError` was provided.

Exception:
42
'''));

    // ignore: unawaited_futures
    controller.close();
  });

  testWidgets('calls catchError if present and stream has error',
      (tester) async {
    final controller = StreamController<int>(sync: true);
    final catchError = ErrorBuilderMock<int>(0);
    when(catchError(any, 42)).thenReturn(42);

    await tester.pumpWidget(
      StreamProvider.value(
        initialData: -1,
        value: controller.stream,
        catchError: catchError,
        child: TextOf<int>(),
      ),
    );

    expect(find.text('-1'), findsOneWidget);

    controller.addError(42);

    await Future.microtask(tester.pump);

    expect(find.text('42'), findsOneWidget);
    verify(catchError(argThat(isNotNull), 42)).called(1);
    verifyNoMoreInteractions(catchError);

    // ignore: unawaited_futures
    controller.close();
  });

  testWidgets('works with null', (tester) async {
    await tester.pumpWidget(
      StreamProvider<int>.value(
        initialData: 42,
        value: null,
        child: TextOf<int>(),
      ),
    );

    expect(find.text('42'), findsOneWidget);

    await tester.pumpWidget(Container());
  });

  group('StreamProvider()', () {
    testWidgets('create and dispose stream with builder', (tester) async {
      final stream = StreamMock<int>();
      final sub = StreamSubscriptionMock<int>();
      when(stream.listen(any, onError: anyNamed('onError'))).thenReturn(sub);

      final builder = InitialValueBuilderMock(stream);

      await tester.pumpWidget(
        StreamProvider<int>(
          initialData: -1,
          create: builder,
          child: TextOf<int>(),
        ),
      );

      verify(builder(argThat(isNotNull))).called(1);

      verify(stream.listen(any, onError: anyNamed('onError'))).called(1);
      verifyNoMoreInteractions(stream);

      await tester.pumpWidget(Container());

      verifyNoMoreInteractions(builder);
      verify(sub.cancel()).called(1);
      verifyNoMoreInteractions(sub);
      verifyNoMoreInteractions(stream);
    });
  });

  group('StreamProxyProvider', () {
    testWidgets(
      'transition from stream to stream in proxy preserve state',
      (tester) async {
        final controller = StreamController<int>(sync: true);
        final controller2 = StreamController<int>(sync: true);

        await tester.pumpWidget(
          StreamProxyProvider0<int>(
            initialData: 0,
            create: (context) => controller.stream,
            update: (_, __) => controller.stream,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('0'), findsOneWidget);

        controller.add(1);

        await tester.pump();

        expect(find.text('1'), findsOneWidget);

        await tester.pumpWidget(
          StreamProxyProvider0<int>(
            initialData: 0,
            create: (context) => controller2.stream,
            update: (_, __) => controller2.stream,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('1'), findsOneWidget);

        controller.add(3);
        await tester.pump();

        expect(find.text('1'), findsOneWidget);

        controller2.add(2);
        await tester.pump();

        expect(find.text('2'), findsOneWidget);

        await tester.pump();
        // ignore: unawaited_futures
        controller.close();
        // ignore: unawaited_futures
        controller2.close();
      },
    );

    testWidgets(
      'update works without create',
      (tester) async {
        final controller = StreamController<int>(sync: true);
        final controller2 = StreamController<int>(sync: true);

        await tester.pumpWidget(
          StreamProxyProvider0<int>(
            initialData: 0,
            update: (_, __) => controller.stream,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('0'), findsOneWidget);

        controller.add(1);

        await tester.pump();

        expect(find.text('1'), findsOneWidget);

        await tester.pumpWidget(
          StreamProxyProvider0<int>(
            initialData: 0,
            update: (_, __) => controller2.stream,
            child: TextOf<int>(),
          ),
        );

        expect(find.text('1'), findsOneWidget);

        controller.add(3);
        await tester.pump();

        expect(find.text('1'), findsOneWidget);

        controller2.add(2);
        await tester.pump();

        expect(find.text('2'), findsOneWidget);

        await tester.pump();
        // ignore: unawaited_futures
        controller.close();
        // ignore: unawaited_futures
        controller2.close();
      },
    );

    testWidgets(
        'update returning a new Stream disposes the previously'
        ' created one', (tester) async {
      var stream = StreamMock<int>();
      final sub = StreamSubscriptionMock<int>();
      when(stream.listen(any, onError: anyNamed('onError'))).thenReturn(sub);

      final create = InitialValueBuilderMock(stream);
      final update = StreamValueBuilderMock(stream);

      await tester.pumpWidget(
        StreamProxyProvider0<int>(
          initialData: -1,
          create: create,
          update: (context, previousStream) =>
              update(context, previousStream as StreamMock<int>?),
          child: TextOf<int>(),
        ),
      );

      verify(create(argThat(isNotNull))).called(1);
      verify(update(argThat(isNotNull), stream)).called(1);

      verify(stream.listen(any, onError: anyNamed('onError'))).called(1);
      verifyNoMoreInteractions(stream);

      final prevStream = stream;
      stream = StreamMock<int>();
      final update2 = StreamValueBuilderMock(stream);
      final sub2 = StreamSubscriptionMock<int>();
      when(stream.listen(any, onError: anyNamed('onError'))).thenReturn(sub2);

      await tester.pumpWidget(
        StreamProxyProvider0<int>(
          initialData: -1,
          create: create,
          update: (context, previousStream) =>
              update2(context, previousStream as StreamMock<int>?),
          child: TextOf<int>(),
        ),
      );

      verifyNoMoreInteractions(update);
      verify(update2(argThat(isNotNull), prevStream)).called(1);
      verify(sub.cancel()).called(1);
      verifyNoMoreInteractions(sub2);

      verify(stream.listen(any, onError: anyNamed('onError'))).called(1);
      verifyNoMoreInteractions(stream);

      await tester.pumpWidget(Container());

      verifyNoMoreInteractions(create);
      verifyNoMoreInteractions(update2);
      verify(sub2.cancel()).called(1);
      verifyNoMoreInteractions(sub2);
      verifyNoMoreInteractions(stream);
    });
  });

  group('StreamProxyProvider variants', () {
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
    testWidgets('StreamProxyProvider0', (tester) async {
      final controller = StreamController<Combined>(sync: true);

      Stream<Combined>? prevStream;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            Provider.value(value: e),
            Provider.value(value: f),
            StreamProxyProvider0<Combined>(
              initialData: const Combined(),
              create: (_) => controller.stream,
              update: (context, previous) {
                controller.add(Combined(
                  context,
                  null,
                  Provider.of<A>(context),
                  Provider.of<B>(context),
                  Provider.of<C>(context),
                  Provider.of<D>(context),
                  Provider.of<E>(context),
                  Provider.of<F>(context),
                ));
                prevStream = previous;
                return controller.stream;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await tester.pump();

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
      expect(prevStream, controller.stream);

      // ignore: unawaited_futures
      controller.close();
    });

    testWidgets('StreamProxyProvider', (tester) async {
      final controller = StreamController<Combined>(sync: true);

      Stream<Combined>? prevStream;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            StreamProxyProvider<A, Combined>(
              initialData: const Combined(),
              create: (_) => controller.stream,
              update: (context, a, previous) {
                controller.add(Combined(
                  context,
                  null,
                  a,
                ));
                prevStream = previous;
                return controller.stream;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await tester.pump();

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
      expect(prevStream, controller.stream);

      // ignore: unawaited_futures
      controller.close();
    });

    testWidgets('StreamProxyProvider2', (tester) async {
      final controller = StreamController<Combined>(sync: true);

      Stream<Combined>? prevStream;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            StreamProxyProvider2<A, B, Combined>(
              initialData: const Combined(),
              create: (_) => controller.stream,
              update: (context, a, b, previous) {
                controller.add(Combined(
                  context,
                  null,
                  a,
                  b,
                ));
                prevStream = previous;
                return controller.stream;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await tester.pump();

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
      expect(prevStream, controller.stream);

      // ignore: unawaited_futures
      controller.close();
    });

    testWidgets('StreamProxyProvider3', (tester) async {
      final controller = StreamController<Combined>(sync: true);

      Stream<Combined>? prevStream;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            StreamProxyProvider3<A, B, C, Combined>(
              initialData: const Combined(),
              create: (_) => controller.stream,
              update: (context, a, b, c, previous) {
                controller.add(Combined(
                  context,
                  null,
                  a,
                  b,
                  c,
                ));
                prevStream = previous;
                return controller.stream;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await tester.pump();

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
      expect(prevStream, controller.stream);

      // ignore: unawaited_futures
      controller.close();
    });

    testWidgets('StreamProxyProvider4', (tester) async {
      final controller = StreamController<Combined>(sync: true);

      Stream<Combined>? prevStream;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            StreamProxyProvider4<A, B, C, D, Combined>(
              initialData: const Combined(),
              create: (_) => controller.stream,
              update: (context, a, b, c, d, previous) {
                controller.add(Combined(
                  context,
                  null,
                  a,
                  b,
                  c,
                  d,
                ));
                prevStream = previous;
                return controller.stream;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await tester.pump();

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
      expect(prevStream, controller.stream);

      // ignore: unawaited_futures
      controller.close();
    });

    testWidgets('StreamProxyProvider5', (tester) async {
      final controller = StreamController<Combined>(sync: true);

      Stream<Combined>? prevStream;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            Provider.value(value: e),
            StreamProxyProvider5<A, B, C, D, E, Combined>(
              initialData: const Combined(),
              create: (_) => controller.stream,
              update: (context, a, b, c, d, e, previous) {
                controller.add(Combined(
                  context,
                  null,
                  a,
                  b,
                  c,
                  d,
                  e,
                ));
                prevStream = previous;
                return controller.stream;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await tester.pump();

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
      expect(prevStream, controller.stream);

      // ignore: unawaited_futures
      controller.close();
    });

    testWidgets('StreamProxyProvider6', (tester) async {
      final controller = StreamController<Combined>(sync: true);

      Stream<Combined>? prevStream;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: a),
            Provider.value(value: b),
            Provider.value(value: c),
            Provider.value(value: d),
            Provider.value(value: e),
            Provider.value(value: f),
            StreamProxyProvider6<A, B, C, D, E, F, Combined>(
              initialData: const Combined(),
              create: (_) => controller.stream,
              update: (context, a, b, c, d, e, f, previous) {
                controller.add(Combined(
                  context,
                  null,
                  a,
                  b,
                  c,
                  d,
                  e,
                  f,
                ));
                prevStream = previous;
                return controller.stream;
              },
            ),
          ],
          child: mockConsumer,
        ),
      );

      verify(
        combinedConsumerMock(const Combined()),
      ).called(1);

      await tester.pump();

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
      expect(prevStream, controller.stream);

      // ignore: unawaited_futures
      controller.close();
    });
  });
}
