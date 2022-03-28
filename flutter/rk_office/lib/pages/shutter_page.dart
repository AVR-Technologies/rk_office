import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ShutterPage extends StatefulWidget {
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
  dispose() {
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

  // @override
  // Widget build(context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Shutter Control'),
  //     ),
  //     body: connection == null ? const Center(
  //       child: CircularProgressIndicator(),
  //     ) : !connection!.isConnected ? const Center(
  //       child: Icon(Icons.error_outline_rounded),
  //     ) : ListView(
  //       children: [
  //         OutlinedButton(
  //           onPressed: () {
  //             if (connection != null && connection!.isConnected) {
  //               connection!.output.add(
  //                 ascii.encode(
  //                   jsonEncode(
  //                     {
  //                       'data': 3,
  //                       'on': true, //shutter on
  //                     },
  //                   ),
  //                 ),
  //               );
  //             }
  //           },
  //           child: const Text('Open'),
  //         ),
  //         OutlinedButton(
  //           onPressed: () {
  //             if (connection != null && connection!.isConnected) {
  //               connection!.output.add(
  //                 ascii.encode(
  //                   jsonEncode(
  //                     {
  //                       'data': 3,
  //                       'on': false, //shutter off
  //                     },
  //                   ),
  //                 ),
  //               );
  //             }
  //           },
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //

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
            title: const Text('Shutter Control'),
          ),
          const Spacer(),
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (connection != null && connection!.isConnected) {
                  connection!.output.add(
                    ascii.encode(
                      jsonEncode(
                        {
                          'data': 3,
                          'on': true, //shutter on
                        },
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                        child: Icon(
                          Icons.arrow_upward_outlined,
                          size: 100,
                        )),
                    Center(
                        child: Text(
                          'OPEN',
                          style: Theme.of(context).textTheme.headline6,
                        )),
                    const Center(
                        child: Text('Shutter will move upward'))
                  ],
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (connection != null && connection!.isConnected) {
                  connection!.output.add(
                    ascii.encode(
                      jsonEncode(
                        {
                          'data': 3,
                          'on': false, //shutter off
                        },
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                        child: Icon(
                          Icons.arrow_downward_outlined,
                          size: 100,
                        )),
                    Center(
                        child: Text(
                          'CLOSE',
                          style: Theme.of(context).textTheme.headline6,
                        )),
                    const Center(
                        child: Text('Shutter will move downward'))
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
