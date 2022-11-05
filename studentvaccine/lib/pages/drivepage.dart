import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class drivePage extends StatefulWidget {
  const drivePage({Key? key}) : super(key: key);

  @override
  State<drivePage> createState() => _drivePageState();
}

class _drivePageState extends State<drivePage> {
  ParseUser? currentUser;

  Future<ParseUser?> getUser() async {
    currentUser = await ParseUser.currentUser() as ParseUser?;
    return currentUser;
  }

  TextEditingController _driveController = TextEditingController();
  TextEditingController _drivedateController = TextEditingController();
  String numOfShots = "";
  DateTime? dateOfDrive = DateTime.now();
  String objectId = "";

  @override
  void dispose() {
    super.dispose();
    _driveController.dispose();
    _drivedateController.dispose();
    numOfShots = "";
    dateOfDrive;
    objectId = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drive details'),
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
            controller: _driveController,
            decoration: InputDecoration(
                labelText: 'Number of shots',
                labelStyle: TextStyle(color: Colors.blue[900])),
          ),
          Container(
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    DateTime? selectedDoD = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 2),
                    );
                    if (selectedDoD == null) return;
                    setState(() {
                      dateOfDrive = selectedDoD;
                    });
                  },
                  child: Text('Date of Drive'),
                ),
                Expanded(
                    child: Text(
                      '${dateOfDrive?.day}/${dateOfDrive?.month}/${dateOfDrive?.year}',
                      textAlign: TextAlign.center,
                    ))
                ],
            ),
          ),
          Container(
            child: ElevatedButton.icon(
                onPressed: () {
                  addDrive(objectId);
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.red,
                  size: 30.0,
                ),
                label: Text('Add')),
          ),
          Container(
            child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _driveController.clear();
                    dateOfDrive = DateTime.now();
                  });
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.red,
                  size: 30.0,
                ),
                label: Text('Clear entry')),
          ),
          Expanded(
              child: Column(
                children: <Widget>[
                  Text('Display vaccination drives here'),
                  Expanded(
                      child: FutureBuilder<List<ParseObject>> (
                          future: getDrive(),
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
                                  return Center(child: Text("No upcoming drives.."),);
                                } else {
                                  return ListView.builder( itemCount: snapshot.data!.length ,
                                      itemBuilder: (context,index){
                                        final varDrive = snapshot.data![index];
                                        final varObjectId = varDrive.get<String>('objectId')!;
                                        final varNumOfShots = varDrive.get<String>('NumOfShots')!;
                                        final varDoD = varDrive.get<DateTime>('DoD');
                                        return ListTile(
                                          title: Text(varDoD.toString().substring(0,10)),
                                          subtitle: Row(
                                            children: <Widget>[
                                              Expanded(child: Text(varNumOfShots))
                                            ],
                                          ),
                                          onTap: () {
                                            if (varDoD != null && varDoD.isBefore(DateTime.now())) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text("Drive is completed"),
                                                duration: Duration(seconds: 2),
                                              ));
                                              return;
                                            }
                                            setState(() {
                                              dateOfDrive = varDoD!;
                                              objectId = varObjectId;
                                              });
                                            _driveController.text = varNumOfShots;
                                           },
                                        );
                                      });
                                }
                            }
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

  void addDrive(String id) async {
    print("ID is : " + id);
    print('add button pressed');
    if (id.isEmpty) {
      if (_driveController.text
          .trim()
          .isEmpty || dateOfDrive == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Mandatory field is Empty"),
          duration: Duration(seconds: 2),
        ));
        return;
      }
      await saveDrive(_driveController.text, dateOfDrive!);
      setState(() {
        _driveController.clear();
        objectId = "";
      });
    } else {
      if (_driveController.text
          .trim()
          .isEmpty || dateOfDrive == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Mandatory field is Empty"),
          duration: Duration(seconds: 2),
        ));
        return;
      }
      var drive = ParseObject('Drive')
        ..objectId = id
        ..set('NumOfShots', _driveController.text)
        ..set('DoD', dateOfDrive);
      await drive.save();
      setState(() {
        _driveController.clear();
        objectId = "";
      });
    }
  }

  Future<void> saveDrive(String numOfShots ,DateTime dod) async {
    final drive = ParseObject('Drive')
      ..set('NumOfShots', numOfShots)
      ..set('DoD', dod);
    await drive.save();
  }

  Future<List<ParseObject>> getDrive() async {
    QueryBuilder<ParseObject> queryTodo =
    QueryBuilder<ParseObject>(ParseObject('Drive'));
    final ParseResponse apiResponse = await queryTodo.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}
