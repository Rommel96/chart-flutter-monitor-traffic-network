import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monitor_traffic/charts.dart';
import 'package:monitor_traffic/models/data_ws.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(MaterialApp(
      title: "Traffic Charts",
      theme: ThemeData.dark(),
      home: App(),
    ));

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final channel = IOWebSocketChannel.connect(URL_SERVER);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Traffic Charts"),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.notifications_active), onPressed: null),
              StreamBuilder(
                stream: channel.stream,
                builder: (_, AsyncSnapshot snapshot) {
                  if (snapshot.data != null) {
                    final data = Message.fromJson(jsonDecode(snapshot.data));
                    return Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(
                            Icons.file_download,
                            color: Colors.red,
                          ),
                          title: Text(
                              "${(data.down * 8 * 2 / 1024000).toStringAsFixed(3)}"),
                          trailing: Text("Mbps"),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.file_upload,
                            color: Colors.orangeAccent,
                          ),
                          title: Text(
                              "${(data.up * 8 * 2 / 1024000).toStringAsFixed(3)}"),
                          trailing: Text("Mbps"),
                        ),
                      ],
                    );
                  } else {
                    return CupertinoActivityIndicator();
                  }
                },
              ),
              Expanded(
                child: Chart(),
              ),
            ],
          ),
        ));
  }
}
