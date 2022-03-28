import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class IrrigationPage extends StatefulWidget {
  final String address;

  const IrrigationPage({Key? key, required this.address}) : super(key: key);

  @override
  State<IrrigationPage> createState() => _IrrigationPageState();
}

class _IrrigationPageState extends State<IrrigationPage> {
  // final oldStartTimeController = TextEditingController();
  // final oldStopTimeController = TextEditingController();
  final startTimeController = TextEditingController();
  final stopTimeController = TextEditingController();
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
      if (inputData["data"] == 1) {
        //reply after new settings sent
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Settings saved')));
      } else if (inputData["data"] == 2) {
        //get saved settings from device
        startTimeController.text = inputData['from'];
        stopTimeController.text = inputData['to'];
      }
    });
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
            title: const Text('Irrigation Timer'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  // const ListTile(
                  //   title: Text('Saved settings'),
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     Expanded(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(4.0),
                  //         child: TextField(
                  //           controller: oldStartTimeController,
                  //           readOnly: true,
                  //           decoration: const InputDecoration(
                  //               label: Text('start time'),
                  //               border: OutlineInputBorder(),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(4.0),
                  //         child: TextField(
                  //           controller: oldStopTimeController,
                  //           readOnly: true,
                  //           decoration: const InputDecoration(
                  //             label: Text('stop time'),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const Divider(color: Colors.grey, thickness: 2,),
                  const ListTile(
                    title: Text('Settings'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: startTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                          label: Text('Start time'),
                          border: OutlineInputBorder()),
                      onTap: () => showTimePicker(
                        builder: (context, child) => MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        ),
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ).then((value) {
                        if (value != null) {
                          setState(
                                () => startTimeController.text =
                                MaterialLocalizations.of(context)
                                    .formatTimeOfDay(
                                  value,
                                  alwaysUse24HourFormat: true,
                                ),
                          );
                        }
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: stopTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        label: Text('Stop time'),
                      ),
                      onTap: () => showTimePicker(
                        builder: (context, child) => MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        ),
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ).then((value) {
                        if (value != null) {
                          setState(
                                () => stopTimeController.text =
                                MaterialLocalizations.of(context)
                                    .formatTimeOfDay(
                                  value,
                                  alwaysUse24HourFormat: true,
                                ),
                          );
                        }
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: OutlinedButton(
                      onPressed: send,
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
                    title: Text(
                        'Select start and stop time for garden irrigation.'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void send() {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(
        ascii.encode(
          jsonEncode(
            {
              'data': 2,
              'from': startTimeController.text + ':0',
              'to': stopTimeController.text + ':0',
            },
          ),
        ),
      );
    }
  }
}
