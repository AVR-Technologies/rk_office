import 'package:flutter/material.dart';
import '../pages/anthem_page.dart';
import '../pages/irrigation_page.dart';
import '../pages/shutter_page.dart';

class Routes{
  Routes._();
  static const homePage = '/home_page';
  static const irrigationPage = '/irrigation_page';
  static const shutterPage = '/shutter_page';
  static const anthemPage = '/anthem_page';
  static Route? routesWithAddress(settings){
      switch (settings.name){
        case Routes.irrigationPage :
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => IrrigationPage( address: args,),
          );
        case Routes.anthemPage :
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => AnthemPage( address: args,),
          );
        case Routes.shutterPage:
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ShutterPage( address: args,),
          );
        default:
      }
      return null;
    }
}