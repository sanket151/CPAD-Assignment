import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:flutter/material.dart';

class studentPage extends StatefulWidget {
  const studentPage({Key? key}) : super(key: key);

  @override
  State<studentPage> createState() => _studentPageState();
}

class _studentPageState extends State<studentPage> {
  TextEditingController _nameController = TextEditingController();
  String gender = "Male";
  DateTime dob = DateTime.now();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    gender = "";
    dob = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.blue[900])),
          ),
          Container(
              child: Row(
            children: <Widget>[
              Expanded(
                  child: ListTile(
                contentPadding: EdgeInsets.all(6),
                title: const Text('Male'),
                leading: Radio(
                  fillColor:
                      MaterialStateColor.resolveWith((states) => Colors.green),
                  value: 'Male',
                  groupValue: gender,
                  onChanged: (String? value) {
                    setState(() {
                      gender = value.toString();
                    });
                  },
                ),
              )),
              Expanded(
                  child: ListTile(
                contentPadding: EdgeInsets.all(6),
                title: const Text('Female'),
                leading: Radio(
                  fillColor:
                      MaterialStateColor.resolveWith((states) => Colors.green),
                  value: 'Female',
                  groupValue: gender,
                  onChanged: (String? value) {
                    setState(() {
                      gender = value.toString();
                    });
                  },
                ),
              )),
            ],
          )),
          Container(
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    DateTime? selectedDoB = await showDatePicker(
                      context: context,
                      initialDate: DateTime(DateTime.now().year - 18),
                      firstDate: DateTime(DateTime.now().year - 18),
                      lastDate: DateTime(DateTime.now().year - 12),
                    );
                    if (selectedDoB == null) return;
                    setState(() {
                      dob = selectedDoB;
                    });
                  },
                  child: Text('Date of Birth'),
                ),
                Expanded(
                    child: Text(
                  '${dob.day}/${dob.month}/${dob.year}',
                  textAlign: TextAlign.center,
                ))
              ],
            ),
          ),
          Container(
            child: ElevatedButton.icon(
                onPressed: addStudent,
                icon: Icon(
                  Icons.add,
                  color: Colors.red,
                  size: 30.0,
                ),
                label: Text('Add')),
          ),
          Expanded(
              child: Column(
                children: <Widget>[
                  Text('Display students here'),
                  Expanded(
                      child: FutureBuilder<List<ParseObject>> (
                        future: getStudent(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState){
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Center(
                                child: Container(width: 100,height: 100,child: CircularProgressIndicator(),),
                              );
                            default:
                              if(snapshot.hasError){
                                return Center(child: Text("Error...."),);
                              }
                              if(!snapshot.hasData) {
                                return Center(child: Text("No Data... !!"),);
                              } else {
                                return ListView.builder( itemCount: snapshot.data!.length ,
                                    itemBuilder: (context,index){
                                      final varStudent = snapshot.data![index];
                                      final varName = varStudent.get<String>('Name')!;
                                      final varGender = varStudent.get<String>('Gender')!;
                                      final varDoB = varStudent.get<DateTime>('DoB')!.toString();
                                      return ListTile(
                                        title: Text(varName),
                                        subtitle: Row(
                                          children: <Widget>[
                                            Expanded(child: Text(varGender)),
                                            Expanded(child: Text(varDoB.substring(0,10))),
                                          ],
                                        ),
                                      );
                                    });
                              }
                          };
                        }
                      )
                  ),
                ],
              )
          ),
        ]),
      ),
    );
  }

  void addStudent() async {
    print('add button pressed');
    if (_nameController.text.trim().isEmpty && gender.isEmpty && dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Mandatory field is Empty"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveStudent(_nameController.text, gender, dob);
    setState(() {
      _nameController.clear();
    });
  }

  Future<void> saveStudent(String name, String gender, DateTime dob) async {
    var tempSchool = ParseObject('tempSchool')..set('Name', 'WWD');
    await tempSchool.save();

    final student = ParseObject('Student')
      ..set('Name', name)
      ..set('Gender', gender)
      ..set('DoB', dob)..set('schoolName', ParseObject('tempSchool')..objectId = tempSchool.objectId);
    await student.save();
  }

  Future<List<ParseObject>> getStudent() async {
    QueryBuilder<ParseObject> queryTodo =
    QueryBuilder<ParseObject>(ParseObject('Student'));
    final ParseResponse apiResponse = await queryTodo.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}
