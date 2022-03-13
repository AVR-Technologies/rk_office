import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class AnthemPage extends StatefulWidget{
  final String address;
  const AnthemPage({Key? key, required this.address}) : super(key: key);

  @override
  State<AnthemPage> createState() => _AnthemPageState();
}

class _AnthemPageState extends State<AnthemPage> {
  TimeOfDay timeOfDay = TimeOfDay.now();
  final timeController = TextEditingController();
  BluetoothConnection? connection;

  @override
  void initState() {
    super.initState();
    connect();
  }

  @override
  dispose(){
    disconnect();
    super.dispose();
  }

  connect() async {
    connection = await BluetoothConnection.toAddress(widget.address);
    setState(() {});
  }

  disconnect() {
    if (connection != null && connection!.isConnected) {
      connection!.close();
      connection!.dispose();
    }
  }
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anthem Control'),
      ),
      body: connection == null ? const Center(
        child: CircularProgressIndicator(),
      ) : !connection!.isConnected ? const Center(
        child: Icon(Icons.error_outline_rounded),
      ) : ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: timeController,
              readOnly: true,
              decoration: const InputDecoration(
                label: Text('Select start time'),
                border: OutlineInputBorder(),
              ),
              onTap: (){
                showTimePicker(
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  ),
                  context: context,
                  initialTime: TimeOfDay.now(),
                ).then((value)  {
                  if(value != null) {
                    setState((){
                      timeOfDay = value;
                      timeController.text = MaterialLocalizations.of(context).formatTimeOfDay(value);
                    });
                  }
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: (){
                if(connection != null && connection!.isConnected){
                  connection!.output.add(ascii.encode(
                    jsonEncode({
                      'data': 1,
                      'at': '${timeOfDay.hour}:${timeOfDay.minute}:00',
                    },),
                  ),);
                }
              },
              child: const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}