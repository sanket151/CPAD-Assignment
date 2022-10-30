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
  final personNameController = TextEditingController();
  final personGenderController = TextEditingController();
  final personRoleController = TextEditingController();
  DateTime dob = DateTime(2022, 10, 22);
  DateTime doj = DateTime(2022, 10, 22);

  void addPerson() async {
    print('add button pressed');
    if (personNameController.text.trim().isEmpty &&
        personGenderController.text.trim().isEmpty &&
        personRoleController.text.trim().isEmpty &&
        dob == null &&
        doj == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Mandatory field is Empty"),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    await savePerson(personNameController.text, personGenderController.text,
        personRoleController.text, dob, doj);
    setState(() {
      personNameController.clear();
      personGenderController.clear();
      personRoleController.clear();
    });
  }
  void updatePerson() async {
    print('update button pressed');
    if (personNameController.text.trim().isEmpty &&
        personGenderController.text.trim().isEmpty &&
        personRoleController.text.trim().isEmpty &&
        dob == null &&
        doj == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Mandatory field is Empty"),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    await savePerson(personNameController.text, personGenderController.text,
        personRoleController.text, dob, doj);
    setState(() {
      personNameController.clear();
      personGenderController.clear();
      personRoleController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Parse Person List"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: TextField(
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            controller: personNameController,
            decoration: InputDecoration(
              labelText: "Name",
              labelStyle: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ),
        Expanded(
          child: TextField(
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            controller: personGenderController,
            decoration: InputDecoration(
              labelText: "Gender",
              labelStyle: TextStyle(color: Colors.blueAccent),

            ),
          ),
        ),
        Expanded(
          child: TextField(
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            controller: personRoleController,
            decoration: InputDecoration(
              labelText: "Role",
              labelStyle: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDoB = await showDatePicker(
                    context: context,
                    initialDate: dob,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDoB == null) return;
                  setState(() {
                    dob = selectedDoB;
                  });
                },
                child: Text('Date of Birth'),
              ),
              ),

              Expanded(child: Text('${dob.day}/${dob.month}/${dob.year}',
                textAlign: TextAlign.center,
              ),
              )
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDoB = await showDatePicker(
                    context: context,
                    initialDate: doj,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDoB == null) return;
                  setState(() {
                    doj = selectedDoB;
                  });
                },
                child: Text('Date of Joining'),
              ),
              ),
              Expanded(child: Text('${doj.day}/${doj.month}/${doj.year}',
                  textAlign: TextAlign.center),),
            ],
          ),
        ),
        Expanded(
            child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: Colors.green,
                    ),
                    onPressed: addPerson,
                    child: Text('Add')),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: Colors.amber,
                    ),
                    onPressed: updatePerson,
                    child: Text('Update')),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: Colors.redAccent,
                    ),
                    onPressed: () {},
                    child: Text('Delete')),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: Colors.blueAccent,
                    ),
                    onPressed: () {},
                    child: Text('Upload')),
              ),
            )
          ],
        )),
      ]),
    );
  }

  Future<void> savePerson(String name, String gender, String role, DateTime dob,
      DateTime doj) async {
    final person = ParseObject('Person')
      ..set('Name', name)
      ..set('Gender', gender)
      ..set('Role', role)
      ..set('DateOfBirth', dob)
      ..set('DateOfJoining', doj);

    await person.save();
  }
//
// Future<List<ParseObject>> getTodo() async {
//   QueryBuilder<ParseObject> queryTodo =
//   QueryBuilder<ParseObject>(ParseObject('Todo'));
//   final ParseResponse apiResponse = await queryTodo.query();
//
//   if (apiResponse.success && apiResponse.results != null) {
//     return apiResponse.results as List<ParseObject>;
//   } else {
//     return [];
//   }
// }
//
// Future<void> updateTodo(String id, bool done) async {
//   var todo = ParseObject('Todo')
//     ..objectId = id
//     ..set('done', done);
//   await todo.save();
// }
//
// Future<void> deleteTodo(String id) async {
//   var todo = ParseObject('Todo')..objectId = id;
//   await todo.delete();
// }
}
