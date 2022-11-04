import 'package:flutter/material.dart';
import 'dart:async';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:studentvaccine/pages/schoolPage.dart';
import 'package:studentvaccine/pages/studentPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'bZXe9WuVy4T6aW9a5cUxw3hUQkOOfFbMJOg64RdH';
  final keyClientKey = 'JFnEKNQTyRCNoeSgVYLXnU9tzhBxx7vM6fR3rjwP';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl, clientKey: keyClientKey, debug: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.lightBlue,
        fontFamily: 'Georgia',
      ),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: HomePage(title: 'Title',),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
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
                    child: const Text('Schools'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => schoolPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Drive'),
                    onPressed: () {
                    },
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Reports'),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            Expanded(child: SizedBox(height: 10,),),
          ],
        )
    );
  }
}
