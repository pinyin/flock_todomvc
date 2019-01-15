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

class _TodoHomeState extends StoreState<TodoHome, AppEvent, _Store> {
  _clickedAdd() {
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
                    children: state.itemIDs
                    .map((id) => TodoItem(
                          id: id,
                          store: widget.store,
                      isEditing: state.editingItem == id,
                        ))
                    .toList(),
              ))
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _clickedAdd,
            tooltip: 'Add Todo',
            child: Icon(Icons.add),
          ),
        ));
  }

  @override
  _Store reducer(_Store prev, AppEvent event) {
    var next = prev;

    if (event is AddedTodo) next = next.push(event.id);
    if (event is RemovedTodo) next = next.remove(event.id);
    if (event is StartedEditingTodo) next = next.editing(event.id);
    if (event is StoppedEditingTodo && event.id == next.editingItem)
      next = next.editing('');

    return next;
  }

  @override
  _Store initializer(List<AppEvent> events) {
    return events.fold(_Store(itemIDs: [], editingItem: ''), reducer);
  }
}

@immutable
class _Store {
  final List<String> itemIDs;

  _Store push(String itemID) {
    return _Store(
        itemIDs: itemIDs.toList()..add(itemID), editingItem: editingItem);
  }

  _Store remove(String itemID) {
    return _Store(
        itemIDs: itemIDs.where((id) => id != itemID).toList(),
        editingItem: editingItem);
  }

  _Store editing(String itemID) {
    return _Store(itemIDs: itemIDs, editingItem: itemID);
  }

  final String editingItem;

  const _Store({this.itemIDs, this.editingItem});
}
