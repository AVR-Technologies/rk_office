import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class IrrigationPage extends StatefulWidget{
  final String address;
  const IrrigationPage({Key? key, required this.address}) : super(key: key);

  @override
  State<IrrigationPage> createState() => _IrrigationPageState();
}

class _IrrigationPageState extends State<IrrigationPage> {
  TimeOfDay startTimeOfDay = TimeOfDay.now();
  TimeOfDay stopTimeOfDay = TimeOfDay.now();
  final startTimeController = TextEditingController();
  final stopTimeController = TextEditingController();
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
        title: const Text('Irrigation Control'),
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
              controller: startTimeController,
              readOnly: true,
              decoration: const InputDecoration(
                label: Text('Select start time'),
                border: OutlineInputBorder()
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
                      startTimeOfDay = value;
                      startTimeController.text = MaterialLocalizations.of(context).formatTimeOfDay(value);
                    });
                  }
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: stopTimeController,
              readOnly: true,
              decoration: const InputDecoration(
                  label: Text('Select stop time'),
                  border: OutlineInputBorder()
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
                      stopTimeOfDay = value;
                      stopTimeController.text = MaterialLocalizations.of(context).formatTimeOfDay(value);
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
                      'data': 2,
                      'from': startTimeController.text,
                      'to': stopTimeController.text,
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