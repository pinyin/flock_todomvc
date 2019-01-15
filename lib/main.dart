import 'package:flock/flock.dart';
import 'package:flock_todomvc/ToDoHome.dart';
import 'package:flock_todomvc/events.dart';
import 'package:flutter/material.dart';

void main() => runApp(TodoMVC());

class TodoMVC extends StatelessWidget {
  final store = createStore<AppEvent>([], [debugPrintDispatch]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flock TodoMVC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoHome(title: 'Flock TodoMVC', store: store),
    );
  }
}

StoreCreator<E> debugPrintDispatch<E>(StoreCreator<E> inner) {
  return (List<E> prepublish) {
    return _DebugPrintDispatchStore(inner(prepublish));
  };
}

class _DebugPrintDispatchStore<E> extends StoreForEnhancer<E> {
  _DebugPrintDispatchStore(this._inner);

  StoreForEnhancer<E> _inner;

  @override
  subscribe(subscriber) {
    return _inner.subscribe(subscriber);
  }

  @override
  int get cursor => _inner.cursor;

  @override
  List<E> get events => _inner.events;

  @override
  void dispatch([E event]) {
    debugPrint(event.toString());
    _inner.dispatch(event);
  }

  @override
  P getState<P>(projector, initializer) {
    return _inner.getState(projector, initializer);
  }

  @override
  void replaceEvents(List<E> events, [int cursor]) {
    _inner.replaceEvents(events, cursor);
  }
}
