import 'package:flock/flock.dart';
import 'package:flock_todomvc/ToDoItem.dart';
import 'package:flock_todomvc/events.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TodoHome extends StoreWidget<AppEvent> {
  TodoHome({Key key, this.title, @required this.store})
      : super(key: key, store: store);

  final String title;
  final Store<AppEvent> store;

  @override
  State<StatefulWidget> createState() {
    return _TodoHomeState();
  }
}

class _TodoHomeState extends StoreState<TodoHome, AppEvent, _TodoHomeStore> {
  _TodoHomeStore projector(_TodoHomeStore prev, List<AppEvent> events) {
    var next = prev ?? const _TodoHomeStore(editingItem: '', itemIDs: []);

    for (final e in events) {
      if (e is AddedTodo) next = next.push(e.id);
      if (e is RemovedTodo) next = next.remove(e.id);
      if (e is StartedEditingTodo) next = next.editing(e.id);
      if (e is StoppedEditingTodo && e.id == next.editingItem)
        next = next.editing('');
    }

    return next;
  }

  _addClicked() {
    final id = Uuid().v4();
    dispatch(AddedTodo(id, ''));
    dispatch(StartedEditingTodo(id));
  }

  void _tappedApp() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _tappedApp,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'todos',
                style: Theme.of(context).textTheme.display4,
                textAlign: TextAlign.center,
              ),
              Expanded(
                  child: ListView(
                shrinkWrap: true,
                children: projection.itemIDs
                    .map((id) => TodoItem(
                          id: id,
                          store: widget.store,
                          isEditing: projection.editingItem == id,
                        ))
                    .toList(),
              ))
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addClicked,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ));
  }
}

@immutable
class _TodoHomeStore {
  final List<String> itemIDs;

  _TodoHomeStore push(String itemID) {
    return _TodoHomeStore(
        itemIDs: itemIDs.toList()..add(itemID), editingItem: editingItem);
  }

  _TodoHomeStore remove(String itemID) {
    return _TodoHomeStore(
        itemIDs: itemIDs.where((id) => id != itemID).toList(),
        editingItem: editingItem);
  }

  _TodoHomeStore editing(String itemID) {
    return _TodoHomeStore(itemIDs: itemIDs, editingItem: itemID);
  }

  final String editingItem;

  const _TodoHomeStore({this.itemIDs, this.editingItem});
}
