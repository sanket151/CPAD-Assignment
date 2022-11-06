import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:flutter/material.dart';
import 'package:studentvaccine/pages/updatestudent.dart';

class studentPage extends StatefulWidget {
  const studentPage({Key? key}) : super(key: key);

  @override
  State<studentPage> createState() => _studentPageState();
}

class _studentPageState extends State<studentPage> {
  ParseUser? currentUser;

  Future<ParseUser?> getUser() async {
    currentUser = await ParseUser.currentUser() as ParseUser?;
    return currentUser;
  }

  TextEditingController _nameController = TextEditingController();
  String gender = "Male";
  DateTime dob = DateTime.now();

  @override
  void dispose() {
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
          FutureBuilder<ParseUser?>(
              future: getUser(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting :
                  case ConnectionState.none :
                    return Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  default :
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text('Hello, ${snapshot.data!.username}'),),
                    );
                }
              }
          ),
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
                  color: Colors.black,
                  size: 30.0,
                ),
                label: Text('Add')),
          ),
          Container(
            child: ElevatedButton.icon(
                onPressed: pickFile,
                icon: Icon(
                  Icons.upload_file,
                  color: Colors.black,
                  size: 30.0,
                ), label: Text('Choose file')),
          ),
          Expanded(
              child: Column(
                children: <Widget>[
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
                                return Center(child: Text("Error or continue to perform to get data..."),);
                              }
                              if(!snapshot.hasData) {
                                return Center(child: Text("No Data... !!"),);
                              } else {
                                return ListView.builder( itemCount: snapshot.data!.length ,
                                    itemBuilder: (context,index){
                                      final varStudent = snapshot.data![index];
                                      final studentObjectId = varStudent.get<String>('objectId')!;
                                      final varName = varStudent.get<String>('Name')!;
                                      final varGender = varStudent.get<String>('Gender')!;
                                      final varDoB = varStudent.get<DateTime>('DoB')!.toString();
                                      return ListTile(
                                        title: Text(varName),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => updateStudent(studentId: studentObjectId)),
                                          );
                                        },
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
  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result?.files.single != null) {
      if (kIsWeb) {
        var bytes = result?.files.single.bytes;
        var decoder = SpreadsheetDecoder.decodeBytes(bytes!);
        for (var table in decoder.tables.keys) {
          print(table);
          var maxcols = decoder.tables[table]!.maxCols;
          if (maxcols > 3 ) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Please select correct file"),
              duration: Duration(seconds: 2),
            ));
            return;
          }
          for (var row in decoder.tables[table]!.rows) {
            //print('$row');
            var name = row[0];
            var gender = row[1];
            var dob = row[2];
            await saveStudent(name, gender, DateTime.parse(dob));
          }
        }
      } else {
        // nee to check and complete below code
        String? path = result?.files.single.path;
        print("Path is " + path!);
        File? file = new File(path);
        ParseFileBase parseFile =  ParseFile(file);
        print(parseFile.toString());
      }
    }
  }

  Future<void> saveStudent(String name, String gender, DateTime dob) async {
    final QueryBuilder<ParseObject> school  = QueryBuilder(ParseObject('School'));
    school.whereContains('User', currentUser!.objectId!);
    final ParseResponse apiResponse = await school.query();
    String response = apiResponse.toString();
    // print("School watch starting here $response");
    if (apiResponse.success && apiResponse.results != null && apiResponse.count ==1) {
      // print('School watch here , count is -->${apiResponse.count}');
      for (var o in apiResponse.results!) {
        // print("School watch inside for loop here");
        // print('Name is --> ${(o as ParseObject).toString()}');
        // print('Address is --> ${(o as ParseObject).get<String>('Address')}');
        // print('Object ID is --> ${(o as ParseObject).get<String>('objectId')}');
        final student = ParseObject('Student')
          ..set('Name', name)
          ..set('Gender', gender)
          ..set('DoB', dob)..set('schoolName', (ParseObject('School')..objectId = (o as ParseObject).get<String>('objectId')).toPointer());
        await student.save();
      }
      // print("School watch inside if here");
    }
    // print("School watch ending here");
  }

  Future<List<ParseObject>> getStudent() async {
    final QueryBuilder<ParseObject> school  = QueryBuilder(ParseObject('School'));
    school.whereContains('User', currentUser!.objectId!);
    final ParseResponse schoolResponse = await school.query();
    String response = schoolResponse.toString();
    print("get student watch starting here $response");
    String schoolId = '';
    if (schoolResponse.success && schoolResponse.results != null && schoolResponse.count ==1) {
      print('get student watch here , count is -->${schoolResponse.count}');
      for (var o in schoolResponse.results!) {
        schoolId = (o as ParseObject).get<String>('objectId').toString();
        print('get student watch here , school ID is -->${schoolId}');
      }
    }
    print('get student watch here outside if & for loop, school ID is -->${schoolId}');
    QueryBuilder<ParseObject> queryStudent = QueryBuilder<ParseObject>(ParseObject('Student'));
    if (schoolId == null || schoolId.isEmpty){
      return [];
    }
    queryStudent.whereContains('schoolName', schoolId);
    final ParseResponse apiResponse = await queryStudent.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}
