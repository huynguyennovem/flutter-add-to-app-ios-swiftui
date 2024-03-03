import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final _methodChannel = const MethodChannel('flutter_channel/counter');
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceInfoString;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _methodChannel.invokeMethod<void>('increaseCounter');
  }

  _handleMethodCall(MethodCall call) {
    if (call.method == 'submitCounter') {
      setState(() {
        _counter = call.arguments as int;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _methodChannel.setMethodCallHandler((call) => _handleMethodCall(call));
    _methodChannel.invokeMethod('getCounter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => SystemNavigator.pop(animated: true),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32.0),
            TextButton(
              onPressed: () async {
                IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
                setState(() {
                  deviceInfoString = iosInfo.utsname.machine;
                });
              },
              child: const Text('Trigger device info plugin'),
            ),
            Text(deviceInfoString ?? 'No device info'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
