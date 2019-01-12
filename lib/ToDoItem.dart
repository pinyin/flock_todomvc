import 'package:flock/flock.dart';
import 'package:flock_todomvc/events.dart';
import 'package:flutter/material.dart';

class TodoItem extends StoreWidget<AppEvent> {
  TodoItem({@required this.id, @required this.store, this.isEditing = false})
      : super(key: Key(id));

  final String id;
  final Store<AppEvent> store;
  final bool isEditing;

  @override
  State<StatefulWidget> createState() {
    return _TodoItemState();
  }
}

class _TodoItemState extends StoreState<TodoItem, AppEvent, _Projection> {
  @override
  void initState() {
    super.initState();
    _editFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_editFocus.hasFocus) {
      if (latestEdit == '') {
        dispatch(StoppedEditingTodo(widget.id));
      } else {
        dispatch(UpdatedTodoContent(widget.id, latestEdit));
        dispatch(StoppedEditingTodo(widget.id));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _editFocus.removeListener(_onFocusChange);
  }

  void _clickedCheckbox(bool clicked) {
    dispatch(UpdatedTodoStatus(widget.id, clicked));
  }

  void _tappedContent() {
    dispatch(StartedEditingTodo(widget.id));
  }

  void _submittedEdit(String edit) {
    if (edit == '')
      dispatch(RemovedTodo(widget.id));
    else
      dispatch(UpdatedTodoContent(widget.id, edit));
    dispatch(StoppedEditingTodo(widget.id));
  }

  var latestEdit = '';

  void _updatedEdit(String edit) {
    latestEdit = edit;
  }

  final _editFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: widget.isEditing ? 1 : 0,
        child: ListTile(
            leading:
                Checkbox(value: projection.isDone, onChanged: _clickedCheckbox),
            title: widget.isEditing
                ? TodoEditor(
                    init: projection.content,
                    editFocus: _editFocus,
                    onSubmit: _submittedEdit,
                    onUpdate: _updatedEdit)
                : GestureDetector(
                    onTap: _tappedContent,
                    child: Text(
                      '${projection.content}',
                      style: Theme.of(context).textTheme.display1,
                    ))));
  }

  _Projection projector(_Projection prev, Events<AppEvent> events) {
    var next = prev ?? const _Projection();

    for (final event in events.reversed) {
      if (event is UpdatedTodoStatus && event.id == widget.id) {
        next = next.update(isDone: event.isDone);
        break;
      }
    }
    for (final event in events.reversed) {
      if (event is UpdatedTodoContent && event.id == widget.id) {
        next = next.update(content: event.content);
        break;
      }
    }

    return next;
  }
}

class TodoEditor extends StatefulWidget {
  TodoEditor(
      {Key key,
      @required String init,
      @required this.editFocus,
      this.onSubmit,
      this.onUpdate})
      : editController = TextEditingController(text: init),
        super(key: key);
  final Function(String) onSubmit;
  final Function(String) onUpdate;
  final TextEditingController editController;
  final FocusNode editFocus;

  @override
  State<StatefulWidget> createState() {
    return _TodoEditorState();
  }
}

class _TodoEditorState extends State<TodoEditor> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget.editFocus);
    });
  }

  _onSubmit(String str) {
    if (widget.onSubmit != null) {
      widget.onSubmit(str);
    }
  }

  _onChanged(String str) {
    if (widget.onUpdate != null) {
      widget.onUpdate(str);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      focusNode: widget.editFocus,
      controller: widget.editController,
      onSubmitted: _onSubmit,
      onChanged: _onChanged,
      style: Theme.of(context).textTheme.display1,
    );
  }
}

@immutable
class _Projection {
  final bool isDone;
  final String content;

  update({bool isDone, String content}) {
    isDone = isDone ?? this.isDone;
    content = content ?? this.content;
    if (isDone != this.isDone || content != this.content)
      return _Projection(isDone: isDone, content: content);
    return this;
  }

  const _Projection({this.isDone = false, this.content = ''});
}
