import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController{

  final FlutterBlue _blue = FlutterBlue.instance;

  Future<void> scanDevices(context) async{
    var result = await _blue.isOn;
    log("Result $result");
    if(!result){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please On your Device Bluetooth')));
    }
    var blePermission = await Permission.bluetoothScan.status;
    if(blePermission.isDenied){
      if(await Permission.bluetoothScan.request().isGranted){
        if(await Permission.bluetoothConnect.request().isGranted){
          _blue.startScan(timeout: const Duration(seconds: 10));
          _blue.stopScan();
        }
      }
    }
    else{
      _blue.startScan(timeout: const Duration(seconds: 10));
      _blue.stopScan();
    }
  }


  Stream<List<ScanResult>> get scanResults => _blue.scanResults;


}