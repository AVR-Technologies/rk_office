import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ShutterPage extends StatefulWidget{
  final String address;
  const ShutterPage({Key? key, required this.address}) : super(key: key);

  @override
  State<ShutterPage> createState() => _ShutterPageState();
}

class _ShutterPageState extends State<ShutterPage> {
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
        title: const Text('Shutter Control'),
      ),
      body: connection == null ? const Center(
        child: CircularProgressIndicator(),
      ) : !connection!.isConnected ? const Center(
        child: Icon(Icons.error_outline_rounded),
      ) : ListView(
        children: [
          OutlinedButton(
            onPressed: (){
              if(connection != null && connection!.isConnected){
                connection!.output.add(ascii.encode(
                  jsonEncode({
                    'data': 3,
                    'on': true,//shutter on
                  },),
                ),);
              }
            },
            child: const Text('Open'),
          ),
          OutlinedButton(
            onPressed: (){
              if(connection != null && connection!.isConnected){
                connection!.output.add(ascii.encode(
                  jsonEncode({
                    'data': 3,
                    'on': false, //shutter off
                  },),
                ),);
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}