import 'package:flutter/material.dart';
import 'package:myapp/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:myapp/todo.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList;

  final databaseReference = fs.Firestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  StreamSubscription<fs.QuerySnapshot> _onTodoAddedSubscription;
  StreamSubscription<fs.QuerySnapshot> _onTodoChangedSubscription;

  Stream<fs.QuerySnapshot> _todoQuery;

  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();
    _todoQuery = databaseReference.collection(widget.userId).snapshots();
    _onTodoAddedSubscription = _todoQuery.listen(onEntryAdded);
    // _onTodoChangedSubscription =
    //     _todoQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    // _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  // onEntryChanged(Event event) {
  //   var oldEntry = _todoList.singleWhere((entry) {
  //     return entry.key == event.snapshot.key;
  //   });

  //   setState(() {
  //     _todoList[_todoList.indexOf(oldEntry)] =
  //         Todo.fromSnapshot(event.snapshot);
  //   });
  // }

  onEntryAdded(fs.QuerySnapshot event) {
    setState(() {
      _todoList = new List();
      event.documents.forEach((element) {
        _todoList.add(Todo.fromSnapshot(element));
      });
      _todoList.sort((a,b) => a.date.compareTo(b.date));
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  updateTodo(Todo todo) {
    //Toggle completed
    todo.completed = !todo.completed;
    if (todo != null) {
      // _database.reference().child("todo").child(todo.key).set(todo.toJson());
    }
  }

  deleteTodo(Todo toDelete, int index) {
    databaseReference
        .collection(widget.userId)
        .document(toDelete.key)
        .delete()
        .whenComplete(() => _todoList.removeAt(index));
  }

  showAddTodoDialog(BuildContext context) async {
    await showDialog<String>(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return ToDoDialog(widget.userId);
        });
  }

  Color getDateColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date == today) {
      return Colors.orange.withOpacity(1.0);
    } else {
      if (date == yesterday) {
        return Colors.red.withOpacity(1.0);
      }
    }
    return Colors.green.withOpacity(1.0);
  }

  Widget showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _todoList[index].key;
            String subject = _todoList[index].subject;
            bool completed = _todoList[index].completed;
            DateTime date = _todoList[index].date;
            return Dismissible(
              key: Key(todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                deleteTodo(_todoList[index], index);
              },
              child: ListTile(
                title: Text(
                  new DateFormat('dd-MM-yyyy').format(date),
                  style: TextStyle(fontSize: 20.0, color: getDateColor(date)),
                ),
                subtitle: Text(
                  subject,
                  style: TextStyle(fontSize: 20.0),
                ),
                trailing: IconButton(
                    icon: (completed)
                        ? Icon(
                            Icons.done_outline,
                            color: Colors.green,
                            size: 20.0,
                          )
                        : Icon(Icons.done, color: Colors.grey, size: 20.0),
                    onPressed: () {
                      updateTodo(_todoList[index]);
                    }),
              ),
            );
          });
    } else {
      return Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter login demo'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: showTodoList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddTodoDialog(context);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ));
  }
}

class ToDoDialog extends StatefulWidget {
  ToDoDialog(this.userId);

  final String userId;

  @override
  _ToDoDialogState createState() => new _ToDoDialogState();
}

class _ToDoDialogState extends State<ToDoDialog> {
  final _textEditingController = TextEditingController();
  DateTime _dateTime;

  final databaseReference = fs.Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(16.0),
      children: <Widget>[
        new Expanded(
            child: new TextField(
          controller: _textEditingController,
          autofocus: true,
          decoration: new InputDecoration(
            labelText: 'Add new todo',
          ),
        )),
        new FlatButton(
            child:
                Text(_dateTime == null ? 'Pick a date' : _dateTime.toString()),
            onPressed: () {
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2222))
                  .then((date) {
                _dateTime = date;
              });
            }),
        new Row(
          children: <Widget>[
            new FlatButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: const Text('Save'),
                onPressed: () {
                  addNewTodo(_textEditingController.text.toString(), _dateTime);
                })
          ],
        )
      ],
    );
  }

  addNewTodo(String todoName, DateTime datetime) {
    if (todoName.length > 0 && datetime != null) {
      Todo todo = new Todo(todoName.toString(), widget.userId, false, datetime);
      databaseReference
          .collection(widget.userId)
          .document()
          .setData(todo.toJson())
          .then((value) => Navigator.pop(context));
    }
  }
}
