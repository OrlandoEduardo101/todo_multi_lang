// A reactive command pattern implementation for Flutter.
// The `Command` class is a base class that extends `ChangeNotifier`, allowing it to notify listeners of state changes. The `RxCommand` class is a concrete implementation that manages the execution of asynchronous actions, tracking its execution state, completion status, and any errors that may occur. The `StreamRxCommand` class is another implementation that listens to a stream of data, managing its listening state, completion status, and errors.
// These classes can be used in Flutter applications to manage asynchronous operations and their states in a reactive way, allowing the UI to respond to changes in the command's state (e.g., showing loading indicators, displaying results, or handling errors). The `RxCommandBuilder` widget can be used to build UI components that react to the state of a `Command`, providing a convenient way to handle loading and error states in the UI.
// Example usage:
// ```dart
// final myCommand = RxCommand<String>();
// myCommand.execute(() async {
//   await Future.delayed(Duration(seconds: 2));
//   return 'Hello, World!';
// });
// ```

import 'dart:async';

import 'package:flutter/material.dart';

sealed class Command<T> extends ChangeNotifier {}

class RxCommand<T> extends Command<T> {
  bool _isExecuting = false;
  bool _completed = false;
  String? _error;
  bool _hasValue = false;
  late T _value;

  bool get isExecuting => _isExecuting;
  bool get completed => _completed;
  String? get error => _error;
  T get value => _value;
  bool get hasValue => _hasValue;
  T? get valueOrNull => _hasValue ? _value : null;

  Future<void> execute(Future<T> Function() action) async {
    if (_isExecuting) return;
    _isExecuting = true;
    _completed = false;
    _error = null;
    notifyListeners();

    try {
      _value = await action();
      _hasValue = true;
      _completed = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }
}

/// A command that listens to a stream of data, managing its listening state, completion status, and errors. It provides a `listen` method to start listening to the stream and a `cancel` method to stop listening. The command notifies listeners of state changes, allowing the UI to react accordingly (e.g., showing loading indicators, displaying results, or handling errors).
/// Example usage:
/// ```dart
/// final myStreamCommand = StreamRxCommand<String>();
/// myStreamCommand.listen(() => Stream.periodic(Duration(seconds: 1), (count) => 'Tick: $count').take(5));
/// ```
class StreamRxCommand<T> extends Command<T> {
  StreamSubscription<T>? _subscription;
  bool _isListening = false;
  bool _completed = false;
  String? _error;
  T? _value;

  bool get isListening => _isListening;
  bool get completed => _completed;
  String? get error => _error;
  T? get value => _value;
  bool get hasValue => _value != null;

  void listen(Stream<T> Function() streamFactory) {
    if (_isListening) return;

    _isListening = true;
    _completed = false;
    _error = null;
    notifyListeners();

    _subscription = streamFactory().listen(
      (data) {
        _value = data;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isListening = false;
        notifyListeners();
      },
      onDone: () {
        _completed = true;
        _isListening = false;
        notifyListeners();
      },
    );
  }

  void cancel() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
