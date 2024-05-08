import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testmqtt/mqttservice/settings.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final MqttController mqttController = Get.put(MqttController(), permanent: true);

    return GetMaterialApp(
      title: 'MQTT and GetX Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MQTT and GetX Example'),
        ),
        body: Column(
          children: [
            Obx(() =>ElevatedButton(
              onPressed:()=> {mqttController.connect()}, //mqttController.isConnected.value ? mqttController.disconnect : mqttController.connect,
              child: Text(mqttController.isConnected.value ? 'Disconnect' : 'Connect'),
            )),
            TextField(
              onSubmitted: (value) {
                mqttController.sendCommand(value);
              },
              decoration: const InputDecoration(hintText: 'Type a message'),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: mqttController.messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(mqttController.messages[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}