import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart' as cl;
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttController extends GetxController {
  late MqttServerClient _client;
  MqttServerClient get client => _client;
 final  RxBool _isConnected = false.obs;

  RxBool get isConnected => _isConnected;

  final RxList _messages = [].obs;

  RxList get messages =>  _messages;

@override
  void onInit() {
    super.onInit();
  }

  Future<void> connect() async {
    _client = MqttServerClient.withPort('10.4.148.207', '',1883);
    _client.logging(on: true);
    _client.onConnected = onConnected;
     _client.setProtocolV311();
    _client.onDisconnected = onDisconnected;
    _client.onSubscribed = onSubscribed;
    _client.pongCallback = pong;

    try {
      await _client.connect();
      print('si paso');
    } catch (e) {
      print('Exception: $e');
      _client.disconnect();
    }
  }

  void disconnect() {
    _client.disconnect();
  }

  void onConnected() {
    print('Connected');
    _client.connectionStatus!.state = cl.MqttConnectionState.connected;
    _isConnected.value = true;
    update();
    print('Connected');
    _client.subscribe('test', cl.MqttQos.atLeastOnce);
  }

  void onDisconnected() {
    _isConnected.value = false;
    update();
    print('Disconnected');
  }


  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
     _client.published!.listen((cl.MqttPublishMessage qmsg) {
  Map<String, dynamic> mymsg = jsonDecode(utf8.decode(qmsg.payload.message));
    messages.add(mymsg["data"]);
    print('published.listen');
     String topicName= qmsg.payload.variableHeader?.topicName ?? '';
    print('el mqtt topic is $topicName');
    print('el mensaje completo ${mymsg.toString()}');
  });
  }
  void sendCommand( String mymsg){
    final builder = cl.MqttClientPayloadBuilder();
    builder.addString("{\"data\": \"${mymsg}\"}");
    _client.publishMessage("test", cl.MqttQos.exactlyOnce, builder.payload!);    
}

  void pong() {
    print('Ping response client callback invoked');
  }

  Future<void> publish(String message, String topic) async {
    
    final builder = cl.MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, cl.MqttQos.atLeastOnce, builder.payload!);
  }

  void subscribe(String topic) {
    _client.subscribe(topic, cl.MqttQos.atLeastOnce);
  }

  void unsubscribe(String topic) {
    _client.unsubscribe(topic);
  }

  
}


