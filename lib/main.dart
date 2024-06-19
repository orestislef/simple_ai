import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  OpenAI.baseUrl = 'http://192.168.24.21:1234';
  OpenAI.apiKey = 'lm-studio';
  OpenAI.showLogs = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lef Chat',
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
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final List<OpenAIChatCompletionChoiceMessageModel> _chatContext = [];
  bool _isGenerating = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lef Chat'),
        actions: [
          ElevatedButton(
              onPressed: _isGenerating ? null : _newChat,
              child: const Text('New Chat')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    bool isUser = _messages[index]['role'] == 'user';
                    return Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[200] : Colors.grey[200],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(isUser ? 2 : -2, 2),
                                blurRadius: 6.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                            minWidth: MediaQuery.of(context).size.width * 0.3,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                    isUser ? Icons.person : Icons.smart_toy),
                                title:
                                    SelectableText(_messages[index]['text']!),
                                subtitle: Text(
                                  _messages[index]['timestamp']!,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                trailing: isUser
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: _messages[index]['text']!));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Copied to clipboard!'),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.copy,
                                          size: 20,
                                        ),
                                      ),
                              ),
                              // _isGenerating &&
                              //         !isUser &&
                              //         index == _messages.length - 1
                              //     ? const LinearProgressIndicator()
                              //     : const SizedBox(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    );
                  }),
            ),
          ),
          if (_isGenerating) const LinearProgressIndicator(),
          Padding(
              padding:
                  const EdgeInsets.only(bottom: 4.0, left: 10.0, right: 10.0),
              child: TextFormField(
                minLines: 1,
                maxLines: 3,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                controller: _messageController,
                decoration: InputDecoration(
                  hintText:
                      _isGenerating ? 'Generating...' : 'Type anything here..',
                  border: const UnderlineInputBorder(),
                  suffix: IconButton(
                    onPressed: _isGenerating ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
                onFieldSubmitted: (value) {
                  _sendMessage();
                },
                textInputAction: TextInputAction.send,
              )),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      String userMessage = _messageController.text;
      _addMessage(userMessage, 'user');
      _chatContext.add(OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            userMessage,
          ),
        ],
        role: OpenAIChatMessageRole.user,
      ));

      setState(() {
        _isGenerating = true;
        _messageController.clear();
      });

      try {
        OpenAI.instance.model.list().then((models) async {
          if (models.isEmpty) {
            setState(() {
              _isGenerating = false;
            });
            return;
          }
          OpenAIModelModel? selectedModel;
          if (models.length > 1) {
            await showDialog(
              context: context,
              builder: (builder) {
                return AlertDialog(
                  content: Column(
                    children: [
                      const Text('Choose a model:'),
                      const SizedBox(height: 10.0),
                      ListView.builder(
                          itemCount: models.length,
                          itemBuilder: (builder, index) {
                            OpenAIModelModel model = models[index];
                            return ListTile(
                              title: Text(model.id),
                              subtitle: Text(model.ownedBy),
                              onTap: () {
                                selectedModel = model;
                                Navigator.pop(context, model);
                              },
                            );
                          }),
                    ],
                  ),
                );
              },
            );
          } else {
            selectedModel = models.first;
          }
          if (selectedModel == null) {
            throw Exception('No model selected');
          }
          OpenAI.instance.chat
              .createStream(
            model: selectedModel!.id,
            messages: _chatContext,
            temperature: 0.8,
            maxTokens: -1,
          )
              .listen(
            (openAiStreamChatCompletionModel) {
              if (openAiStreamChatCompletionModel.choices[0].finishReason ==
                  "stop") {
                _chatContext.add(OpenAIChatCompletionChoiceMessageModel(
                  content: [
                    OpenAIChatCompletionChoiceMessageContentItemModel.text(
                      _messages.last['text'] ?? '',
                    ),
                  ],
                  role: OpenAIChatMessageRole.assistant,
                ));
                setState(() {
                  _isGenerating = false;
                });
                return;
              }

              if (_messages.isEmpty || _messages.last['role'] != 'ai') {
                _addMessage(
                  openAiStreamChatCompletionModel
                      .choices[0].delta.content!.first!.text!,
                  'ai',
                );
              } else {
                setState(() {
                  _messages.last['text'] = (_messages.last['text'] ?? '') +
                      openAiStreamChatCompletionModel
                          .choices[0].delta.content!.first!.text!;
                });
              }
              _scrollToBottom();
            },
          ).onError((error) {
            setState(() {
              _isGenerating = false;
              _addMessage("Error: ${error.toString()}", 'error');
            });
          });
        });
      } catch (e) {
        setState(() {
          _isGenerating = false;
          _addMessage("Error: $e", 'error');
        });
      }
    }
  }

  void _newChat() {
    if (_isGenerating) {
      return;
    }
    setState(() {
      _messages.clear();
      _chatContext.clear();
    });
  }

  void _addMessage(String text, String role) {
    String timestamp = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    setState(() {
      _messages.add({'text': text, 'role': role, 'timestamp': timestamp});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
