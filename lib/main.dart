import 'package:flock/flock.dart';
import 'package:flock_todomvc/ToDoHome.dart';
import 'package:flock_todomvc/events.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

void main() => runApp(ToDoMVC());

final store = createStore<AppEvent>(
    [], [debugPrintDispatch, withShakeBack(userAccelerometerEvents)]);

class ToDoMVC extends StatelessWidget {
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
  return (Iterable<E> prepublish) {
    return _DebugPrintDispatchStore(inner(prepublish));
  };
}

class _DebugPrintDispatchStore<E> extends InnerStore<E> {
  _DebugPrintDispatchStore(this.inner);

  InnerStore<E> inner;

  @override
  void dispatch(E event) {
    debugPrint(event.toString());
    inner.dispatch(event);
  }

  @override
  P getState<P>(projector) {
    return inner.getState(projector);
  }

  @override
  void replaceEvents(Iterable<E> events) {
    return inner.replaceEvents(events);
  }

  @override
  subscribe(subscriber) {
    return inner.subscribe(subscriber);
  }
}
