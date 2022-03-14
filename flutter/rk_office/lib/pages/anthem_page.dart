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
      ) : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  label: Text('Select start time'),
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
                      setState(()=> timeController.text = MaterialLocalizations.of(context).formatTimeOfDay(value, alwaysUse24HourFormat: true,));
                    }
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: OutlinedButton(
                onPressed: send,
                child: const Text('Send'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Divider(),
            ),
            const ListTile(
              dense: true,
              leading: Icon(Icons.error_outline),
              title: Text('Anthem will play for 1 minute, and then other media will play.'),
            ),
          ],
        ),
      ),
    );
  }
  void send(){
    if(connection != null && connection!.isConnected){
      connection!.output.add(ascii.encode(
        jsonEncode({
          'data': 1,
          'at': timeController.text + ':0',
        },),
      ),);
    }
  }
}