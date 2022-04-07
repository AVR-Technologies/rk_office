import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class AnthemPage extends StatefulWidget {
  final String address;

  const AnthemPage({Key? key, required this.address}) : super(key: key);

  @override
  State<AnthemPage> createState() => _AnthemPageState();
}

class _AnthemPageState extends State<AnthemPage> {
  // final oldTimeController = TextEditingController();
  final timeController = TextEditingController();
  BluetoothConnection? connection;

  @override
  void initState() {
    super.initState();
    connect();
  }

  @override
  dispose() {
    disconnect();
    super.dispose();
  }

  connect() async {
    connection = await BluetoothConnection.toAddress(widget.address);
    connection!.input!.listen((event) {
        var inputData = jsonDecode(ascii.decode(event));
        if (inputData["data"] == 1) { // reply after new settings sent
          timeController.text = inputData['at'];
          ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(const SnackBar(content: Text('Settings saved')));
        } else if (inputData["data"] == 2) { // get saved settings from device
          timeController.text = inputData['at'];
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(const SnackBar(content: Text('Settings read from device')));
        } else if(inputData["data"] == 3){  // clock updated response
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(const SnackBar(content: Text('Clock updated')));
        }
      },
    );

    sendClockTime();
    sendCurrentConfigReadRequest();

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
        leading: Image.asset('assets/rk_logo.png'),
        title: const Text('RK Associates - Smart Office'),
      ),
      body: connection == null ? const Center(
        child: CircularProgressIndicator(),
      ) : !connection!.isConnected ? const Center(
        child: Icon(Icons.error_outline_rounded),
      ) : Column(
        children: [
          AppBar(
            // automaticallyImplyLeading: false,
            leading: Container(),
            shape: const Border(),
            title: const Text('National Anthem Timer'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListView(
                children: [
                  // const ListTile(
                  //   title: Text('Saved settings'),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(4.0),
                  //   child: TextField(
                  //     enabled: false,
                  //     controller: oldTimeController,
                  //     readOnly: true,
                  //     decoration: const InputDecoration(
                  //       label: Text('start time'),
                  //     ),
                  //   ),
                  // ),
                  // const Divider(color: Colors.grey, thickness: 2,),
                  const ListTile(
                    title: Text('Settings'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: timeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        label: Text('start time'),
                      ),
                      onTap: () {
                        showTimePicker(
                          builder: (context, child) => MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true,),
                            child: child!,
                          ),
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((value) {
                          if (value != null) {
                            setState(() => timeController.text = MaterialLocalizations.of(context).formatTimeOfDay(
                              value,
                              alwaysUse24HourFormat: true,
                            ),);
                          }
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: OutlinedButton(
                      onPressed: sendNewConfig,
                      child: const Text('SAVE'),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Divider(),
                  ),
                  const ListTile(
                    dense: true,
                    leading: Icon(Icons.error_outline),
                    title: Text('Anthem will play for 1 minute, and then other media will play.',),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendNewConfig() {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(
        ascii.encode(
          jsonEncode({
            'data': 1,
            'at': timeController.text + ':0',
          },),
        ),
      );
    }
  }
  void sendClockTime(){
    if (connection != null && connection!.isConnected) {
      Future.delayed(
        const Duration(seconds: 1), ()=> connection!.output.add(
        ascii.encode(
          jsonEncode({
            'data': 3,
            'time': DateFormat('yyyy:MM:dd:HH:mm:ss').format(DateTime.now()),
          },),
        ),
      ),);
    }
  }
  void sendCurrentConfigReadRequest(){

    if (connection != null && connection!.isConnected) {
      Future.delayed(
        const Duration(seconds: 3), () =>
          connection!.output.add(
            ascii.encode(
              jsonEncode({
                'data': 2,
              },),
            ),
          ),);
    }
  }
}
