import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../main.dart';

const List<String> vaccineTypes = <String>['Covishield', 'Cowaxin'];
const List<String> vaccinationStatus = <String>['Registered', 'Vaccinated'];

class updateStudent extends StatefulWidget {
   const updateStudent({super.key, required this.studentId});

  final String studentId;

  @override
  State<updateStudent> createState() => _updateStudentState(studentId);
}

class _updateStudentState extends State<updateStudent> {
  ParseUser? currentUser;

  List<String> drives = <String>[];
  String dropdownValue = vaccineTypes.first;
  String drivedate = "";
  String status = vaccinationStatus.first;
  String studentObjectId = "";

  _updateStudentState(String studentId) {
    studentObjectId = studentId;
    drives.add("");
    drivedate = drives.first;
  }


  Future<ParseUser?> getUser() async {
    currentUser = await ParseUser.currentUser() as ParseUser?;
    return currentUser;
  }

  Future<List<ParseObject>> getAvailableDrives() async {
    QueryBuilder<ParseObject> queryDrive =
        QueryBuilder<ParseObject>(ParseObject('Drive'));
    ParseResponse apiResponse = await queryDrive.query();
    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Vaccine Status'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              FutureBuilder<ParseUser?>(
                  future: getUser(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      default:
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Hello, ${snapshot.data!.username}'),
                          ),
                        );
                    }
                  }),
              Container(
                child: Text("Student details"),
              ),
              FutureBuilder<String?>(
                  future: getStudentName(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      default:
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(snapshot.data!),
                          ),
                        );
                    }
                  }),
              Container(
                child: Row(children: <Widget>[
                  Expanded(
                      child: ListTile(
                    contentPadding: EdgeInsets.all(6),
                    title: const Text('Vaccine Type'),
                    trailing: DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      items: vaccineTypes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  )),
                ]),
              ),
              Container(
                child: Row(children: <Widget>[
                  Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(6),
                        title: const Text('Select drive date'),
                      )),
                  Expanded(
                      child: FutureBuilder<List<ParseObject>>(
                          future: getAvailableDrives(),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return Center(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              default:
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                        "Error or continue to perform to get data..."),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: Text("No Data... !!"),
                                  );
                                } else {
                                  for (var dt in snapshot.data!) {
                                    final date = dt.get<DateTime>('DoD')!;
                                    if (!drives.contains(date.toString().substring(0,10))) {
                                      drives.add(
                                          date.toString().substring(0, 10));
                                    }
                                  }
                                  return DropdownButton<String>(
                                    value: drivedate,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 16,
                                    style:
                                    const TextStyle(color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        drivedate = value!;
                                      });
                                    },
                                    items: drives.map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }
                                        ).toList(),
                                  );
                                }
                            }
                          })),
                ]),
              ),
              Container(
                child: Row(children: <Widget>[
                  Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(6),
                        title: const Text('Vaccination Status'),
                        trailing: DropdownButton<String>(
                          value: status,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              status = value!;
                            });
                          },
                          items: vaccinationStatus
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      )),
                ]),
              ),
              Container(
                child: ElevatedButton.icon(
                    onPressed: updateStudentVaccineDetails,
                    icon: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    label: Text('Update')),
              ),
            ],
          )),
    );
  }

  Future<String> getStudentName() async {
    final QueryBuilder<ParseObject> student  = QueryBuilder(ParseObject('Student'));
    student.whereContains('objectId', studentObjectId);
    final ParseResponse apiResponse = await student.query();
    var studentName = (apiResponse.results?.first as ParseObject).get<String>('Name');
    return studentName!;
  }


  void updateStudentVaccineDetails() async {
    print('update button pressed');
    if (dropdownValue.isEmpty || drivedate.isEmpty || status.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Mandatory field is Empty"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await updateStudentVaccine(dropdownValue, drivedate, status, studentObjectId);
    Message.showSuccess(
      context: context,
      message: 'Student vaccine details updated',
    );
    setState(() {
      dropdownValue = vaccineTypes.first;
      drivedate = drives.first;
      status = vaccinationStatus.first;
    });
  }

  Future<void> updateStudentVaccine(String type, String date, String status, String studentId) async {
    final QueryBuilder<ParseObject> student  = QueryBuilder(ParseObject('Student'));
    student.whereContains('objectId', studentId);
    final ParseResponse apiResponse = await student.query();
    if (apiResponse.success && apiResponse.results != null && apiResponse.count ==1) {
      for (var o in apiResponse.results!) {
        final student = ParseObject('Vaccine')
          ..set('VaccineName', type)
          ..set('Status', status)
          ..set('DriveDate', date)
          ..set('StudentId', (ParseObject('Student')..objectId = (o as ParseObject).get<String>('objectId')).toPointer());
        await student.save();
      }
    }
  }
}
