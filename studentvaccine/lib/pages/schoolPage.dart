import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class schoolPage extends StatefulWidget {
  const schoolPage({Key? key}) : super(key: key);

  @override
  State<schoolPage> createState() => _schoolPageState();
}

class _schoolPageState extends State<schoolPage> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _addressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('School'),
      ),
      body: Column(
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
                labelText: 'School Name',
                labelStyle: TextStyle(color: Colors.blue[900])),
          ),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
                labelText: 'School Address',
                labelStyle: TextStyle(color: Colors.blue[900])),
          ),

        ],
      ),
    );
  }
}
