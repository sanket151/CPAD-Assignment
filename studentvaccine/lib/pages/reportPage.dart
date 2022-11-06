import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel hide Column;
import 'package:file_saver/file_saver.dart';
import 'package:pdf/widgets.dart' as pw;

const List<String> vaccineTypes = <String>['', 'Covishield', 'Cowaxin'];
const List<String> vaccinationStatus = <String>['', 'Registered', 'Vaccinated'];

class reportPage extends StatefulWidget {
  const reportPage({super.key});

  @override
  State<reportPage> createState() => _reportDownloadState();
}

class _reportDownloadState extends State<reportPage> {
  ParseUser? currentUser;

  List<String> drives = <String>[];
  String dropdownValue = vaccineTypes.first;
  String drivedate = "";
  String status = vaccinationStatus.first;
  String studentObjectId = "";

  _reportDownloadState() {
    drives.add("");
    drivedate = drives.first;
  }

  Future<ParseUser?> getUser() async {
    currentUser = await ParseUser.currentUser() as ParseUser?;
    return currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Vaccination status report'),
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
                child: Text("Choose the filters. If the field is blank, that filter is not applied"),
              ),
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
                                      print("Value is : " + value!);
                                      // This is called when the user selects an item.
                                      setState(() {
                                        drivedate = value;
                                      });
                                    },
                                    items: drives.map<DropdownMenuItem<String>>(
                                            (String value) {
                                          print(drives.length);
                                          print("Value inside is : " + value);
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
                    onPressed: () {
                      generateExcel(dropdownValue, drivedate, status);
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    label: Text('Download excel')),
              ),
              Container(
                child: ElevatedButton.icon(
                    onPressed: () {
                      generatePdf(dropdownValue, drivedate, status);
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    label: Text('Download pdf')),
              ),
            ],
          )),
    );
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

  Future<List<ParseObject>> getVaccinationStatus() async {
    final QueryBuilder<ParseObject> student = QueryBuilder(
        ParseObject('Vaccine'));
    final ParseResponse apiResponse = await student.query();
    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> generateExcel(String dropdownValue, String drivedate, String status) async {
    final QueryBuilder<ParseObject> student = QueryBuilder(
        ParseObject('Vaccine'));
    if (dropdownValue.isNotEmpty) {
      student.whereContains('VaccineName', dropdownValue);
    }
    if (drivedate.isNotEmpty) {
      student.whereContains('DriveDate', drivedate);
    }
    if (status.isNotEmpty) {
      student.whereContains('Status', status);
    }
    final ParseResponse apiResponse = await student.query();
    if (apiResponse.success && apiResponse.results != null) {
      var result = apiResponse.results as List<ParseObject>;

      //Create a Excel document.

      //Creating a workbook.
      final excel.Workbook workbook = excel.Workbook();
      //Accessing via index
      final excel.Worksheet sheet = workbook.worksheets[0];
      sheet.showGridlines = true;

      // Enable calculation for worksheet.
      sheet.enableSheetCalculations();
      sheet.getRangeByName('A1').columnWidth = 13.82;
      sheet.getRangeByName('B1').columnWidth = 13.82;
      sheet.getRangeByName('C1').columnWidth = 13.82;
      sheet.getRangeByName('D1').columnWidth = 13.82;
      sheet.getRangeByName('E1').columnWidth = 13.82;
      sheet.getRangeByName('F1').columnWidth = 13.82;
      sheet.getRangeByName('A1').setText('Sudent Name');
      sheet.getRangeByName('B1').setText('Student Date of Birth');
      sheet.getRangeByName('C1').setText('Student Gender');
      sheet.getRangeByName('D1').setText('Vaccine Name');
      sheet.getRangeByName('E1').setText('Vaccine Status');
      sheet.getRangeByName('F1').setText('Date of Drive');

      int i = 2;

      for (var row in result) {

        var studentId = row.get<ParseObject>('StudentId')?.objectId;

        final QueryBuilder<ParseObject> students = QueryBuilder(
            ParseObject('Student'));

        students.whereContains('objectId', studentId!);

        ParseResponse studentResponse = await students.query();
        var student = studentResponse.results?.first as ParseObject;

        String vname = row.get<String>('VaccineName')!;
        String vstatus = row.get<String>('Status')!;
        String vdrive = row.get<String>('DriveDate')!;
        String? studentName = student.get<String>('Name');
        String? studentGender = student.get<String>('Gender');
        DateTime? studentDoB = student.get<DateTime>('DoB');

        sheet.getRangeByIndex(i, 1).columnWidth = 13.82;
        sheet.getRangeByIndex(i, 2).columnWidth = 13.82;
        sheet.getRangeByIndex(i, 3).columnWidth = 13.82;

        sheet.getRangeByIndex(i, 1).setText(studentName);
        sheet.getRangeByIndex(i, 2).setText(studentDoB.toString());
        sheet.getRangeByIndex(i, 3).setText(studentGender);
        sheet.getRangeByIndex(i, 4).setText(vname);
        sheet.getRangeByIndex(i, 5).setText(vstatus);
        sheet.getRangeByIndex(i, 6).setText(vdrive);
        i++;
      }

      //Save and launch the excel.
      final List<int> bytes = workbook.saveAsStream();
      //Dispose the document.
      workbook.dispose();

      //Save and launch the file.
      Uint8List data = Uint8List.fromList(bytes);
      MimeType type = MimeType.MICROSOFTEXCEL;
      await FileSaver.instance.saveFile(
          'VaccineStatus', data, 'xlsx', mimeType: type);
    }
  }

  Future<void> generatePdf(String dropdownValue, String drivedate, String status) async {
    final QueryBuilder<ParseObject> student = QueryBuilder(
        ParseObject('Vaccine'));
    if (dropdownValue.isNotEmpty) {
      student.whereContains('VaccineName', dropdownValue);
    }
    if (drivedate.isNotEmpty) {
      student.whereContains('DriveDate', drivedate);
    }
    if (status.isNotEmpty) {
      student.whereContains('Status', status);
    }
    final ParseResponse apiResponse = await student.query();
    if (apiResponse.success && apiResponse.results != null) {
      var result = apiResponse.results as List<ParseObject>;

      for (var row in result) {

        var studentId = row.get<ParseObject>('StudentId')?.objectId;

        final QueryBuilder<ParseObject> students = QueryBuilder(
            ParseObject('Student'));

        students.whereContains('objectId', studentId!);

        ParseResponse studentResponse = await students.query();
        var student = studentResponse.results?.first as ParseObject;

        String vname = row.get<String>('VaccineName')!;
        String vstatus = row.get<String>('Status')!;
        String vdrive = row.get<String>('DriveDate')!;
        String? studentName = student.get<String>('Name');
        String? studentGender = student.get<String>('Gender');
        DateTime? studentDoB = student.get<DateTime>('DoB');

      }
      final pdf = pw.Document();

      //Save and launch the file.
      Uint8List data = await pdf.save();
      MimeType type = MimeType.PDF;
      await FileSaver.instance.saveFile(
          'VaccineStatusPdf', data, 'pdf', mimeType: type);
    }
  }
}
