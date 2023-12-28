import 'dart:async';

import 'package:flutter/widgets.dart';

import 'provider.dart';
import 'proxy_provider.dart';

/// A callback used to build a valid value from an error.
///
/// See also:
///
///   * [StreamProvider] and [FutureProvider], which both uses [ErrorBuilder] to
///     handle respectively `Stream.catchError` and [Future.catch].
typedef ErrorBuilder<T> = T Function(BuildContext context, Object? error);

DeferredStartListening<Stream<T>?, T> _streamStartListening<T>({
  required T initialData,
  ErrorBuilder<T>? catchError,
}) {
  return (e, setState, controller, __) {
    if (!e.hasValue) {
      setState(initialData);
    }
    if (controller == null) {
      return () {};
    }
    final sub = controller.listen(
      setState,
      onError: (Object? error) {
        if (catchError != null) {
          setState(catchError(e, error));
        } else {
          FlutterError.reportError(
            FlutterErrorDetails(
              library: 'provider',
              exception: FlutterError('''
An exception was throw by ${controller.runtimeType} listened by
StreamProvider<$T>, but no `catchError` was provided.

Exception:
$error
'''),
            ),
          );
        }
      },
    );

    return sub.cancel;
  };
}

/// Listens to a [Stream] and exposes its content to `child` and descendants.
///
/// Its main use-case is to provide to a large number of a widget the content
/// of a [Stream], without caring about reacting to events.
/// A typical example would be to expose the battery level, or a Firebase query.
///
/// Trying to use [Stream] to replace [ChangeNotifier] is outside of the scope
/// of this class.
///
/// It is considered an error to pass a stream that can emit errors without
/// providing a `catchError` method.
///
/// `initialData` determines the value exposed until the [Stream] emits a value.
///
/// By default, [StreamProvider] considers that the [Stream] listened uses
/// immutable data. As such, it will not rebuild dependents if the previous and
/// the new value are `==`.
/// To change this behavior, pass a custom `updateShouldNotify`.
///
/// See also:
///
///   * [Stream], which is listened by [StreamProvider].
///   * [StreamController], to create a [Stream].
class StreamProvider<T> extends DeferredInheritedProvider<Stream<T>?, T> {
  /// Creates a [Stream] using `create` and subscribes to it.
  ///
  /// The parameter `create` must not be `null`.
  StreamProvider({
    Key? key,
    required Create<Stream<T>?> create,
    required T initialData,
    ErrorBuilder<T>? catchError,
    UpdateShouldNotify<T>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          updateShouldNotify: updateShouldNotify,
          startListening: _streamStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );

  /// Listens to `value` and expose it to all of [StreamProvider] descendants.
  StreamProvider.value({
    Key? key,
    required Stream<T>? value,
    required T initialData,
    ErrorBuilder<T>? catchError,
    UpdateShouldNotify<T>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super.value(
          key: key,
          lazy: lazy,
          builder: builder,
          value: value,
          updateShouldNotify: updateShouldNotify,
          startListening: _streamStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@template provider.streamproxyprovider}
/// A [StreamProvider] that builds and synchronizes a [Stream]
/// with external values.
/// {@endtemplate}
class StreamProxyProvider0<R> extends DeferredInheritedProvider<Stream<R>?, R> {
  /// Initializes [key] for subclasses.
  StreamProxyProvider0({
    Key? key,
    Create<Stream<R>?>? create,
    required Update<Stream<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          update: update,
          updateShouldNotify: updateShouldNotify,
          startListening: _streamStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.streamproxyprovider}
class StreamProxyProvider<T, R>
    extends DeferredInheritedProvider<Stream<R>?, R> {
  /// Initializes [key] for subclasses.
  StreamProxyProvider({
    Key? key,
    Create<Stream<R>?>? create,
    required ProxyProviderBuilder<T, Stream<R>> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _streamStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.streamproxyprovider}
class StreamProxyProvider2<T, T2, R>
    extends DeferredInheritedProvider<Stream<R>?, R> {
  /// Initializes [key] for subclasses.
  StreamProxyProvider2({
    Key? key,
    Create<Stream<R>?>? create,
    required ProxyProviderBuilder2<T, T2, Stream<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _streamStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.streamproxyprovider}
class StreamProxyProvider3<T, T2, T3, R>
    extends DeferredInheritedProvider<Stream<R>?, R> {
  /// Initializes [key] for subclasses.
  StreamProxyProvider3({
    Key? key,
    Create<Stream<R>?>? create,
    required ProxyProviderBuilder3<T, T2, T3, Stream<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _streamStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.streamproxyprovider}
class StreamProxyProvider4<T, T2, T3, T4, R>
    extends DeferredInheritedProvider<Stream<R>?, R> {
  /// Initializes [key] for subclasses.
  StreamProxyProvider4({
    Key? key,
    Create<Stream<R>?>? create,
    required ProxyProviderBuilder4<T, T2, T3, T4, Stream<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _streamStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.streamproxyprovider}
class StreamProxyProvider5<T, T2, T3, T4, T5, R>
    extends DeferredInheritedProvider<Stream<R>?, R> {
  /// Initializes [key] for subclasses.
  StreamProxyProvider5({
    Key? key,
    Create<Stream<R>?>? create,
    required ProxyProviderBuilder5<T, T2, T3, T4, T5, Stream<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _streamStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.streamproxyprovider}
class StreamProxyProvider6<T, T2, T3, T4, T5, T6, R>
    extends DeferredInheritedProvider<Stream<R>?, R> {
  /// Initializes [key] for subclasses.
  StreamProxyProvider6({
    Key? key,
    Create<Stream<R>?>? create,
    required ProxyProviderBuilder6<T, T2, T3, T4, T5, T6, Stream<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _streamStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

DeferredStartListening<Future<T>?, T> _futureStartListening<T>({
  required T initialData,
  ErrorBuilder<T>? catchError,
}) {
  // ignore: void_checks, false positive
  return (e, setState, controller, __) {
    if (!e.hasValue) {
      setState(initialData);
    }

    var canceled = false;
    controller?.then(
      (value) {
        if (canceled) {
          return;
        }
        setState(value);
      },
      onError: (Object? error) {
        if (canceled) {
          return;
        }
        if (catchError != null) {
          setState(catchError(e, error));
        } else {
          FlutterError.reportError(
            FlutterErrorDetails(
              library: 'provider',
              exception: FlutterError('''
An exception was throw by ${controller.runtimeType} listened by
FutureProvider<$T>, but no `catchError` was provided.

Exception:
$error
'''),
            ),
          );
        }
      },
    );

    return () => canceled = true;
  };
}

/// Listens to a [Future] and exposes its result to `child` and its descendants.
///
/// It is considered an error to pass a future that can emit errors without
/// providing a `catchError` method.
///
/// {@macro provider.updateshouldnotify}
///
/// See also:
///
///   * [Future], which is listened by [FutureProvider].
class FutureProvider<T> extends DeferredInheritedProvider<Future<T>?, T> {
  /// Creates a [Future] from `create` and subscribes to it.
  ///
  /// `create` must not be `null`.
  FutureProvider({
    Key? key,
    required Create<Future<T>?> create,
    required T initialData,
    ErrorBuilder<T>? catchError,
    UpdateShouldNotify<T>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          updateShouldNotify: updateShouldNotify,
          startListening: _futureStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );

  /// Listens to `value` and expose it to all of [FutureProvider] descendants.
  FutureProvider.value({
    Key? key,
    required Future<T>? value,
    required T initialData,
    ErrorBuilder<T>? catchError,
    UpdateShouldNotify<T>? updateShouldNotify,
    TransitionBuilder? builder,
    Widget? child,
  }) : super.value(
          key: key,
          builder: builder,
          lazy: false,
          value: value,
          updateShouldNotify: updateShouldNotify,
          startListening: _futureStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@template provider.futureproxyprovider}
/// A [FutureProvider] that builds and synchronizes a [Future]
/// with external values.
/// {@endtemplate}
class FutureProxyProvider0<R> extends DeferredInheritedProvider<Future<R>?, R> {
  /// Initializes [key] for subclasses.
  FutureProxyProvider0({
    Key? key,
    Create<Future<R>?>? create,
    required Update<Future<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          builder: builder,
          lazy: lazy,
          create: create,
          update: update,
          updateShouldNotify: updateShouldNotify,
          startListening: _futureStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.futureproxyprovider}
class FutureProxyProvider<T, R>
    extends DeferredInheritedProvider<Future<R>?, R> {
  /// Initializes [key] for subclasses.
  FutureProxyProvider({
    Key? key,
    Create<Future<R>?>? create,
    required ProxyProviderBuilder<T, Future<R>> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          builder: builder,
          lazy: false,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _futureStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.futureproxyprovider}
class FutureProxyProvider2<T, T2, R>
    extends DeferredInheritedProvider<Future<R>?, R> {
  /// Initializes [key] for subclasses.
  FutureProxyProvider2({
    Key? key,
    Create<Future<R>?>? create,
    required ProxyProviderBuilder2<T, T2, Future<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          builder: builder,
          lazy: false,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _futureStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.futureproxyprovider}
class FutureProxyProvider3<T, T2, T3, R>
    extends DeferredInheritedProvider<Future<R>?, R> {
  /// Initializes [key] for subclasses.
  FutureProxyProvider3({
    Key? key,
    Create<Future<R>?>? create,
    required ProxyProviderBuilder3<T, T2, T3, Future<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          builder: builder,
          lazy: false,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _futureStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.futureproxyprovider}
class FutureProxyProvider4<T, T2, T3, T4, R>
    extends DeferredInheritedProvider<Future<R>?, R> {
  /// Initializes [key] for subclasses.
  FutureProxyProvider4({
    Key? key,
    Create<Future<R>?>? create,
    required ProxyProviderBuilder4<T, T2, T3, T4, Future<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          builder: builder,
          lazy: false,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _futureStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.futureproxyprovider}
class FutureProxyProvider5<T, T2, T3, T4, T5, R>
    extends DeferredInheritedProvider<Future<R>?, R> {
  /// Initializes [key] for subclasses.
  FutureProxyProvider5({
    Key? key,
    Create<Future<R>?>? create,
    required ProxyProviderBuilder5<T, T2, T3, T4, T5, Future<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          builder: builder,
          lazy: false,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _futureStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}

/// {@macro provider.futureproxyprovider}
class FutureProxyProvider6<T, T2, T3, T4, T5, T6, R>
    extends DeferredInheritedProvider<Future<R>?, R> {
  /// Initializes [key] for subclasses.
  FutureProxyProvider6({
    Key? key,
    Create<Future<R>?>? create,
    required ProxyProviderBuilder6<T, T2, T3, T4, T5, T6, Future<R>?> update,
    required R initialData,
    ErrorBuilder<R>? catchError,
    UpdateShouldNotify<R>? updateShouldNotify,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          builder: builder,
          lazy: false,
          create: create,
          update: (context, previous) => update(
            context,
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            Provider.of(context),
            previous,
          ),
          updateShouldNotify: updateShouldNotify,
          startListening: _futureStartListening(
            catchError: catchError,
            initialData: initialData,
          ),
          child: child,
        );
}
