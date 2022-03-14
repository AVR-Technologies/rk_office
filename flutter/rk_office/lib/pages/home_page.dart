import 'package:flutter/material.dart';
import '../constants/routes.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var devices = <Device>[
    Device(icon: Icons.music_note, name: 'RK anthem', path: Routes.anthemPage, address: "94:3C:C6:25:AE:C2",),
    Device(icon: Icons.grass, name: 'RK irrigation', path: Routes.irrigationPage, address: "94:3C:C6:25:AE:C2",),
    Device(icon: Icons.door_front_door, name: 'RK shutter', path: Routes.shutterPage, address: "94:3C:C6:25:AE:C2",),
  ];

  @override
  Widget build(context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('RK Office'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ListView(
          children: [
            const ListTile(
              dense: true,
              selected: true,
              title: Text('DEVICES'),
            ),
            ...devices.map((device) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                leading: Icon(device.icon),
                title: Text(device.name),
                onTap: ()=> Navigator.of(context).pushNamed(device.path, arguments: device.address), //todo: replace arguments with actual address
              ),
            ),),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Divider(),
            ),
            const ListTile(
              dense: true,
              leading: Icon(Icons.error_outline),
              title: Text('Make sure bluetooth is on and then select device to open control panel.'),
            ),
          ],
        ),
      ),
    );
  }
}

class Device {
  final IconData icon;
  final String name;
  final String path;
  final String address;
  Device({required this.icon, required this.name, required this.path, required this.address});
}
