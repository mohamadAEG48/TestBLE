import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'dart:async';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  var data;
  var scanSubscription;

  final int waitlength = 400;
  final int buzzlength = 400;

  final String device_id = "C5:6B:28:6C:1C:10";
  final String device_name = "TECO Wearable 1";

  final String service = "713D0000-503E-4C75-BA94-3148F18D941E";
  final String char1 =
      "713D0001-503E-4C75-BA94-3148F18D941E"; //Anzahl der angeschlossenen Motoren (z.B. 4 oder 5)
  final String char2 =
      "713D0002-503E-4C75-BA94-3148F18D941E"; //Maximale Update-Frequenz für Motoren, z.B. 12 (“Updates pro Sekunde”)
  final String char3 =
      "713D0003-503E-4C75-BA94-3148F18D941E"; //schaltet Motoren auf gegebene Stärken

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> connect() async {
    BleManager bleManager = BleManager();
    await bleManager.createClient(); //ready to go!

    bleManager.startPeripheralScan(
      uuids: [
        widget.service,
      ],
    ).listen((scanResult) async {
      //Scan one peripheral and stop scanning
      print("Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult
          .rssi}");

      Peripheral peripheral = scanResult.peripheral;
      peripheral.observeConnectionState(
          emitCurrentValue: true, completeOnDisconnect: true)
          .listen((connectionState) {
        print("Peripheral ${scanResult.peripheral
            .identifier} connection state is $connectionState");
      });
      await peripheral.connect();
      bool connected = await peripheral.isConnected();
      //await peripheral.disconnectOrCancelConnection();
      print("connected");
      //assuming peripheral is connected
      await peripheral.discoverAllServicesAndCharacteristics();
      List<Service> services = await peripheral
          .services(); //getting all services
      List<Characteristic> characteristics1 = await peripheral.characteristics(
          widget.char1);
      List<Characteristic> characteristics2 = await services.firstWhere(
              (service) => service.uuid == widget.service).characteristics();

      //characteristics1 and characteristics2 have the same contents

      peripheral.writeCharacteristic(
          widget.service,
          widget.char3,
          Uint8List.fromList([0xFF]),
          false);

      bleManager.stopPeripheralScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("title"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme
                  .of(context)
                  .textTheme
                  .display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _incrementCounter();
          connect();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}