import 'package:firebase_database/firebase_database.dart';

class Todo {
  String key;
  String subject;
  bool completed;
  String userId;
  DateTime date;

  Todo(this.subject, this.userId, this.completed, this.date);

  Todo.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        subject = snapshot.value["subject"],
        completed = snapshot.value["completed"],
        date = snapshot.value["date"];

  toJson() {
    return {
      "userId": userId,
      "subject": subject,
      "completed": completed,
      "date": date
    };
  }
}