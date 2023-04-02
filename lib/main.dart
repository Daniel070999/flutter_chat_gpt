import 'dart:math';

import 'package:backdrop/backdrop.dart';
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
    String apiEnviar = '';
    if (apiKeyPersonal.isEmpty) {
      apiEnviar = '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';
    } else {
      apiEnviar = apiKeyPersonal;
    }
    var response = await http.post(
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
      chatLog += 'Yo: $message\n';
    });
    final response = await chatWithGPT(message, apiKeyPersonal);
    setState(() {
      chatLog += 'Chat GPT: $response\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BackdropScaffold(
        appBar: BackdropAppBar(
          title: const Text("Chat GPT"),
          centerTitle: true,
          actions: const <Widget>[
            BackdropToggleButton(
              icon: AnimatedIcons.list_view,
            )
          ],
          leading: Icon(Icons.arrow_back_sharp),
        ),
        backLayer: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text("Token personal: "),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: apiController,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        subHeader: const BackdropSubHeader(
          title: Text("Sub Header"),
        ),
        frontLayer: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                reverse: false,
                itemCount: chatLog.split('\n').length,
                itemBuilder: (BuildContext context, int index) {
                  final message = chatLog.split('\n')[index];
                  if (message.isNotEmpty) {
                    final isUserMessage = message.startsWith('Yo: ');
                    final text = message.substring(0);
                    final time = DateTime.now().toString().substring(11, 16);
                    return Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: isUserMessage
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: <Widget>[
                          if (!isUserMessage)
                            const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isUserMessage
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  text,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUserMessage)
                            const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: TextField(
                controller: myController,
                decoration: const InputDecoration(
                  hintText: 'Texto...',
                ),
                onSubmitted: (value) {
                  _handleSubmit(myController.text, apiController.text);
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.send),
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
