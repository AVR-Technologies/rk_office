import 'package:flutter/material.dart';
import 'package:rk_office/constants/routes.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('RK Office'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('RK anthem'),
            onTap: ()=> Navigator.of(context).pushNamed(Routes.anthemPage, arguments: "94:3C:C6:25:AE:C2"), //todo: replace arguments with actual address
          ),
          ListTile(
            leading: const Icon(Icons.grass),
            title: const Text('RK irrigation'),
            onTap: ()=> Navigator.of(context).pushNamed(Routes.irrigationPage, arguments: "11:22:33:44:55:67"), //todo: replace arguments with actual address
          ),
          ListTile(
            leading: const Icon(Icons.door_front_door),
            title: const Text('RK shutter'),
            onTap: ()=> Navigator.of(context).pushNamed(Routes.shutterPage, arguments: "11:22:33:44:55:68"), //todo: replace arguments with actual address
          ),
        ],
      ),
    );
  }
}
