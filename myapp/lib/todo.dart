import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String key;
  String subject;
  bool completed;
  String userId;
  DateTime date;

  Todo(this.subject, this.userId, this.completed, this.date);

  Todo.fromSnapshot(DocumentSnapshot snapshot) :
        key = snapshot.documentID,
        userId = snapshot["userId"],
        subject = snapshot["subject"],
        completed = snapshot["completed"],
        date = new DateTime.fromMillisecondsSinceEpoch(snapshot["date"].seconds * 1000);

  toJson() {
    return {
      "userId": userId,
      "subject": subject,
      "completed": completed,
      "date": date
    };
  }
}