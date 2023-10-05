import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:mermaid/receive_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

const platform = const MethodChannel('br.com.satty.mermaid/receive');

void main() {
  runApp(MaterialApp(home: MyApp()));

  ReceiveIntent.getInitialIntent().then((intent) {
    if (intent != null) {
      print(jsonEncode(intent.data));
      ReceiveScreen(data: jsonEncode(intent.data));
    }
  });

  ReceiveIntent.receivedIntentStream.listen((intent) {
    if (intent != null) {
      print(jsonEncode(intent.data));
      ReceiveScreen(data: jsonEncode(intent.data));
    }
  });
}

class MyApp extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _urlIntentController = TextEditingController();
  final TextEditingController _urlIntentArgsController =
      TextEditingController();
  final TextEditingController _urlIntentActionController =
      TextEditingController(text: 'action_view');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Abrir Maracutaia'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _urlController,
                decoration: InputDecoration(labelText: 'URL direto'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String url = _urlController.text;
                  _abrirURLPersonalizada(url, context);
                },
                child: Text('Abrir URL Direto'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _urlIntentController,
                decoration: InputDecoration(labelText: 'URL ou package intent'),
              ),
              TextField(
                controller: _urlIntentActionController,
                decoration:
                    InputDecoration(labelText: 'Ação, default action_view'),
              ),
              TextField(
                controller: _urlIntentArgsController,
                decoration:
                    InputDecoration(labelText: 'Args ou Data pode ser vazio'),
              ),
              ElevatedButton(
                onPressed: () {
                  String url = _urlController.text;
                  String action = _urlIntentActionController.text;
                  String args = _urlIntentArgsController.text;
                  _abrirURLIntent(url, action, args, context);
                },
                child: Text('Abrir URL  Intent'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirURLIntent(
      String url, String action, String args, BuildContext context) async {
    AndroidIntent intent;
    if (url.startsWith("http")) {
      if (args.isNotEmpty) {
        intent = AndroidIntent(
          action: action,
          data: url,
          arguments: jsonDecode(args),
        );
      } else {
        intent = AndroidIntent(action: action, data: url);
      }
    } else {
      intent = AndroidIntent(
        action: action,
        package: url,
        data: args,
      );
    }

    await intent.launch();
  }

  void _abrirURLPersonalizada(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _mostrarErro(context, 'Não foi possível abrir a URL: $url');
    }
  }

  void _mostrarErro(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(mensagem),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
