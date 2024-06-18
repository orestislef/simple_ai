import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  final TextEditingController _controller = TextEditingController();
  final StreamController<String> _streamController = StreamController<String>();
  String _response = '';

  late ScrollController _scrollController;

  Future<void> _sendMessage(String userInput) async {
    const url = 'http://192.168.24.21:1234/v1/chat/completions';
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "model": "LM Studio Community/Meta-Llama-3-8B-Instruct-GGUF",
      "messages": [
        {"role": "user", "content": userInput}
      ],
      "temperature": 0.7,
      "max_tokens": -1,
      "stream": true
    });

    try {
      final request = http.Request('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.body = body;

      final response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) {
        if (value.startsWith('data: ')) {
          final jsonString = value.substring(6);
          final jsonData = jsonDecode(jsonString);
          final content = jsonData['choices'][0]['delta']['content'];
          setState(() {
            _response += content;
          });
          _streamController.add(_response);
        }
      });
    } catch (e) {
      _streamController.add('Error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _streamController.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(labelText: 'Enter your message'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _response = ''; // Clear previous response
                _sendMessage(_controller.text);
              },
              child: const Text('Send'),
            ),
            const SizedBox(height: 20),
            const Text('Response:'),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<String>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());
                    return SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: SelectableText(
                                snapshot.data!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Text('Waiting for response...');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          _scrollController.position.maxScrollExtent);
    }
  }
}
