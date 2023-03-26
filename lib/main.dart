import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final myController = TextEditingController();
  final apiController = TextEditingController();
  String chatLog = '';
  String apiKey = '';

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    apiKey = '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';
  }

  Future<String> chatWithGPT(String message, String apiKeyPersonal) async {
    String apiEnviar = apiKeyPersonal ?? apiKey;
    print(apiEnviar);
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiEnviar',
      },
      body: '{ '
          '"model": "gpt-3.5-turbo","max_tokens":100,"messages": [{"role": "user", "content": "$message"}]'
          '}',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final choices = data['choices'];
      if (choices.isNotEmpty) {
        print(choices[0]['message']['content']);
        return choices[0]['message']['content'];
      }
    }
    return 'Lo siento, no pude entenderte.';
  }

  void _handleSubmit(String message, String apiKeyPersonal) async {
    myController.clear();
    setState(() {
      chatLog += '--YO: $message\n';
    });
    final response = await chatWithGPT(message, apiKeyPersonal);
    setState(() {
      chatLog += '--elsape_GPT: $response\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('ChatGPT con juegos de azar'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text("Máximo de caracteres a responder:")),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              decoration: InputDecoration(hintText: 'Ejm: 50'),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text("Token personal:")),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: apiController,
                              decoration:
                                  InputDecoration(hintText: 'Ejm: sk-Xy...fYs'),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Text("Url del modelo:")),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText:
                                      'Ejm: https://api.openai.com/v1/chat/completions'),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                reverse: true,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(chatLog),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: TextField(
                controller: myController,
                decoration: InputDecoration(
                  hintText: 'Texto...',
                ),
                onSubmitted: (value) {
                  _handleSubmit(myController.text, apiController.text);
                },
              ),
              trailing: IconButton(
                icon: Icon(Icons.send),
                onPressed: () =>
                    _handleSubmit(myController.text, apiController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
