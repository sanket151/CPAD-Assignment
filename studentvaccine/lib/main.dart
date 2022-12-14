import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:studentvaccine/pages/drivepage.dart';
import 'package:studentvaccine/pages/reportPage.dart';
import 'package:studentvaccine/pages/studentPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'bZXe9WuVy4T6aW9a5cUxw3hUQkOOfFbMJOg64RdH';
  final keyClientKey = 'JFnEKNQTyRCNoeSgVYLXnU9tzhBxx7vM6fR3rjwP';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey,
      debug: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<bool> hasUserLogged() async {
    ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      return false;
    }
    //Checks whether the user's session token is valid
    final ParseResponse? parseResponse =
    await ParseUser.getCurrentUserFromServer(currentUser.sessionToken!);

    if (parseResponse?.success == null || !parseResponse!.success) {
      //Invalid session. Logout
      await currentUser.logout();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Vaccination Programme',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
          future: hasUserLogged(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Scaffold(
                  body: Center(
                    child: Container(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator()),
                  ),
                );
              default:
                if (snapshot.hasData && snapshot.data!) {
                  return UserPage();
                } else {
                  return LoginPage();
                }
            }
          }),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Student Vaccination Programme'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 200,
                  child: Image.asset('assets/vaccine-programme.jpg'),
                ),
                Center(
                  child: const Text('Student Vaccination Programme',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: controllerUsername,
                  enabled: !isLoggedIn,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Username'),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: controllerPassword,
                  enabled: !isLoggedIn,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Password'),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 50,
                  child: ElevatedButton(
                    child: const Text('Login'),
                    onPressed: isLoggedIn ? null : () => doUserLogin(),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 50,
                  child: ElevatedButton(
                    child: const Text('Sign Up'),
                    onPressed: () => navigateToSignUp(),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ));
  }

  void doUserLogin() async {
    final username = controllerUsername.text.trim();
    final password = controllerPassword.text.trim();

    final user = ParseUser(username, password, null);

    var response = await user.login();

    if (response.success) {
      navigateToUser();
    } else {
      Message.showError(context: context, message: response.error!.message);
    }
  }

  void navigateToUser() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => UserPage()),
          (Route<dynamic> route) => false,
    );
  }

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }


}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerEmail = TextEditingController();
  final schoolName = TextEditingController();
  final schoolAddress = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Student Vaccination Programme Sign Up'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 200,
                  child: Image.asset('assets/vaccine-programme.jpg'),
                ),
                Center(
                  child: const Text('Student Vaccination Programme',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: const Text('User registration',
                      style: TextStyle(fontSize: 16)),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: controllerUsername,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Username'),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'E-mail'),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: controllerPassword,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Password'),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: schoolName,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'School Name'),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: schoolAddress,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'School Address'),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  height: 50,
                  child: ElevatedButton(
                    child: const Text('Sign Up'),
                    onPressed: () => doUserRegistration(),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void doUserRegistration() async {
    final username = controllerUsername.text.trim();
    final email = controllerEmail.text.trim();
    final password = controllerPassword.text.trim();
    final schoolname = schoolName.text;
    final schooladdress = schoolAddress.text;

    final user = ParseUser.createUser(username, password, email);
    var userresponse = await user.signUp();

    final school = ParseObject('School')
      ..set('Name', schoolname)
      ..set('Address', schooladdress)
      ..set('User', (ParseObject('User')..objectId = user.objectId).toPointer());
    await school.save();

    if (userresponse.success) {
      Message.showSuccess(
          context: context,
          message: 'User & School was successfully created!',
          onPressed: () async {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => UserPage()),
                  (Route<dynamic> route) => false,
            );
          });
    } else {
      Message.showError(context: context, message: userresponse.error!.message);
    }
  }
}

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  ParseUser? currentUser;

  Future<ParseUser?> getUser() async {
    currentUser = await ParseUser.currentUser() as ParseUser?;
    return currentUser;
  }

  @override
  Widget build(BuildContext context) {
    void doUserLogout() async {
      var response = await currentUser!.logout();
      if (response.success) {
        Message.showSuccess(
            context: context,
            message: 'User was successfully logout!',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
              );
            });
      } else {
        Message.showError(context: context, message: response.error!.message);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
        ),
        body: FutureBuilder<ParseUser?>(
            future: getUser(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Container(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator()),
                  );
                default:
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: Text('Hello, ${snapshot.data!.username}')),
                        SizedBox(
                          height: 16,
                        ),
                        Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('Students'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => studentPage()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  flex: 3,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('Drive'),
                                    onPressed: () {
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(builder: (context) => drivePage()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  flex: 3,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('Report'),
                                    onPressed: () {
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(builder: (context) => reportPage()),
                                       );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Container(child: FutureBuilder(
                          future: getStudentCount(),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if(snapshot.hasData){
                              final studentCount = snapshot.data as String;
                              return Text('Total Students in this school are : $studentCount');
                            }
                            return const CircularProgressIndicator();
                          },
                        )),
                        Container(child: FutureBuilder(
                          future: getDriveCount (),
                          builder: (context, AsyncSnapshot<String> snapshot){
                            if(snapshot.hasData){
                              final driveCount = snapshot.data as String;
                              return Text('Total Drives from this school are : $driveCount');
                            }
                            return const CircularProgressIndicator();
                          },
                        )),
                        Container(child: FutureBuilder(
                          future: getRegisterCount (),
                          builder: (context, AsyncSnapshot<String> snapshot){
                            if(snapshot.hasData){
                              final driveCount = snapshot.data as String;
                              return Text('Count of registered Students : $driveCount');
                            }
                            return const CircularProgressIndicator();
                          },
                        )),
                        Container(child: FutureBuilder(
                          future: getVaccinatedCount (),
                          builder: (context, AsyncSnapshot<String> snapshot){
                            if(snapshot.hasData){
                              final driveCount = snapshot.data as String;
                              return Text('Count of vaccinated Students : $driveCount');
                            }
                            return const CircularProgressIndicator();
                          },
                        )),
                        Container(
                          height: 50,
                          child: FloatingActionButton(
                            child: const Icon(Icons.logout_rounded),
                            onPressed: () => doUserLogout(),
                          ),
                        ),
                      ],
                    ),
                  );
              }
            }));
  }

  Future<String> getStudentCount() async{
    final QueryBuilder<ParseObject> school  = QueryBuilder(ParseObject('School'));
    school.whereContains('User', currentUser!.objectId!);
    final ParseResponse schoolResponse = await school.query();
    String schoolId = '';
    if (schoolResponse.success && schoolResponse.results != null && schoolResponse.count ==1) {
      for (var o in schoolResponse.results!) {
        schoolId = (o as ParseObject).get<String>('objectId').toString();
      }
    }
    if (schoolId == null || schoolId.isEmpty){
      return '';
    }
    QueryBuilder<ParseObject> queryTodo =
    QueryBuilder<ParseObject>(ParseObject('Student'))..whereContains('schoolName', schoolId);
    final ParseResponse apiResponse = await queryTodo.count();
    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.count.toString();
    } else {
      return '';
    }
  }

  Future<String> getDriveCount () async {
    final QueryBuilder<ParseObject> driveCount = QueryBuilder(ParseObject('Drive'))..whereContains('User', currentUser!.objectId!);
    final ParseResponse driveCountResponse = await driveCount.count();
    if(driveCountResponse.success && driveCountResponse.result  != null){
      return driveCountResponse.count.toString();
    }else {
      return '';
    }
  }

  Future<String> getRegisterCount() async {
    final QueryBuilder<ParseObject> driveCount = QueryBuilder(ParseObject('Vaccine'))..whereContains('Status', 'Registered');
    final ParseResponse driveCountResponse = await driveCount.count();
    if(driveCountResponse.success && driveCountResponse.result  != null){
      return driveCountResponse.count.toString();
    }else {
      return '';
    }
  }

  Future<String> getVaccinatedCount() async {
    final QueryBuilder<ParseObject> driveCount = QueryBuilder(ParseObject('Vaccine'))..whereContains('Status', 'Vaccinated');
    final ParseResponse driveCountResponse = await driveCount.count();
    if(driveCountResponse.success && driveCountResponse.result  != null){
      return driveCountResponse.count.toString();
    }else {
      return '';
    }
  }

}

// class ResetPasswordPage extends StatefulWidget {
//   @override
//   _ResetPasswordPageState createState() => _ResetPasswordPageState();
// }
//
// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final controllerEmail = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Reset Password'),
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextField(
//                 controller: controllerEmail,
//                 keyboardType: TextInputType.emailAddress,
//                 textCapitalization: TextCapitalization.none,
//                 autocorrect: false,
//                 decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.black)),
//                     labelText: 'E-mail'),
//               ),
//               SizedBox(
//                 height: 8,
//               ),
//               // Container(
//               //   height: 50,
//               //   child: ElevatedButton(
//               //     child: const Text('Reset Password'),
//               //     onPressed: () => doUserResetPassword(),
//               //   ),
//               // )
//             ],
//           ),
//         ));
//   }
//
//   // void doUserResetPassword() async {
//   //   final ParseUser user = ParseUser(null, null, controllerEmail.text.trim());
//   //   final ParseResponse parseResponse = await user.requestPasswordReset();
//   //   if (parseResponse.success) {
//   //     Message.showSuccess(
//   //         context: context,
//   //         message: 'Password reset instructions have been sent to email!',
//   //         onPressed: () {
//   //           Navigator.of(context).pop();
//   //         });
//   //   } else {
//   //     Message.showError(context: context, message: parseResponse.error!.message);
//   //   }
//   // }
// }

class Message {
  static void showSuccess(
      {required BuildContext context,
        required String message,
        VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: Text(message),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showError(
      {required BuildContext context,
        required String message,
        VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(message),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }
}