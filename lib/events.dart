class AppEvent {
  const AppEvent();

  static const EMPTY = AppEvent();
}

class TodoEvent extends AppEvent {
  const TodoEvent(this.id);

  final String id;
}

class AddedTodo extends TodoEvent {
  const AddedTodo(String id, this.content) : super(id);
  final String content;
}

class RemovedTodo extends TodoEvent {
  const RemovedTodo(String id) : super(id);
}

class UpdatedTodoStatus extends TodoEvent {
  const UpdatedTodoStatus(String id, this.isDone) : super(id);
  final bool isDone;
}

class UpdatedTodoContent extends TodoEvent {
  const UpdatedTodoContent(String id, this.content) : super(id);
  final String content;
}

class StartedEditingTodo extends TodoEvent {
  StartedEditingTodo(String id) : super(id);
}

class StoppedEditingTodo extends TodoEvent {
  StoppedEditingTodo(String id) : super(id);
}
