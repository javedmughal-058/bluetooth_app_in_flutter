import 'dart:developer';
import 'package:bluetooth_app_in_flutter/bluetooth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final bluetoothController = Get.put(BluetoothController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Scan App'),
        actions: [
          IconButton(onPressed: ()=> bluetoothController.scanDevices(context), icon: const Icon(Icons.bluetooth))
        ],
      ),
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (BluetoothController controller){
          return Center(
            child: StreamBuilder<List<ScanResult>>(
              stream: controller.scanResults,
              builder: (context, snapshot){
              if(snapshot.hasData){
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                      final data = snapshot.data![index];
                      if(data.advertisementData.connectable){
                        return Card(
                          child: ListTile(
                            onTap: () async {
                              List<BluetoothService> services =  await data.device.discoverServices();
                              log(services[0].toString());
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            // leading: const Icon(Icons.bluetooth),
                            // title: const Icon(Icons.bluetooth),
                            subtitle:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(data.device.name),
                                Text(data.device.id.id.toString()),
                                Text(data.advertisementData.connectable.toString()),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () async => await data.device.connect(),
                                        icon: const Icon(Icons.bluetooth_connected_outlined)),
                                    IconButton(
                                        onPressed: () async => await data.device.disconnect(),
                                        icon: const Icon(Icons.remove_circle_outline)),
                                  ],
                                ),
                                StreamBuilder(
                                    stream: data.device.state,
                                    builder: (context, _snap){
                                      if(_snap.hasData){
                                        return  Text(_snap.data == BluetoothDeviceState.connected ? "Connected" : "Disconnected");
                                      }
                                      else{
                                        return const SizedBox();
                                      }
                                    }),

                              ],
                            ),
                          ),
                        );
                      }
                      else{
                        return const SizedBox();
                      }


                    }),
                  );
                }
              else{
                return const Text('No Device Founded..!');
              }
            }),
          );
        },
      ),
    );
  }
}
