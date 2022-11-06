import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'bZXe9WuVy4T6aW9a5cUxw3hUQkOOfFbMJOg64RdH';
  final keyClientKey = 'JFnEKNQTyRCNoeSgVYLXnU9tzhBxx7vM6fR3rjwP';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todoController = TextEditingController();

  void addToDo() async {
    if (todoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Empty title"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTodo(todoController.text);
    setState(() {
      todoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Parse Todo List"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FutureBuilder (
      future: getTodo(),
      builder: (context,AsyncSnapshot<String> snapshot){
    if (snapshot.hasData) {
    final theText = snapshot.data as String;
    return Text('$theText');
    }
    return const CircularProgressIndicator();
    },
      )
    );
  }

  Future<void> saveTodo(String title) async {
    final todo = ParseObject('Todo')..set('title', title)..set('done', false);
    await todo.save();
  }

  Future<String> getTodo() async {
    QueryBuilder<ParseObject> queryTodo =
    QueryBuilder<ParseObject>(ParseObject('Student'))..whereContains('schoolName', 'O6IHh0BbKB');
    final ParseResponse apiResponse = await queryTodo.count();
    print(apiResponse.toString());
    if (apiResponse.success && apiResponse.results != null) {
      print('count is --> ${apiResponse.count}');
      return apiResponse.count.toString();
    } else {
      return '';
    }
  }

  Future<void> updateTodo(String id, bool done) async {
    var todo = ParseObject('Todo')
      ..objectId = id
      ..set('done', done);
    await todo.save();
  }

  Future<void> deleteTodo(String id) async {
    var todo = ParseObject('Todo')..objectId = id;
    await todo.delete();
  }
}